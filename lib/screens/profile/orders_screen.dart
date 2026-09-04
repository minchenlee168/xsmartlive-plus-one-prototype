import '../../utils/platform_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../models/purchase.dart';
import '../../providers/purchase_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/back_leading_button.dart';

/// 訂單卡的獨立動作按鈕（配送進度/明細改為切換列，不在此列舉）。
enum _OrderAction { inquiry, changeAddress, payInfo }


class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String? _status;
  int _page = 1;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _keyword;

  /// Default query window is the most recent 3 months.
  static DateTime _defaultStart(DateTime end) {
    final m = end.month - 3;
    final year = end.year + (m <= 0 ? -1 : 0);
    final month = ((m - 1) % 12 + 12) % 12 + 1;
    final day = end.day;
    return DateTime(year, month, day);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _endTime = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _startTime = _defaultStart(_endTime);
  }

  Future<void> _openInfoPanel() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => const _InfoPanel(),
    );
  }

  Future<void> _openSearchSheet() async {
    final result = await showModalBottomSheet<_SearchPayload>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SearchSheet(
        initialStart: _startTime,
        initialEnd: _endTime,
        initialKeyword: _keyword,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _startTime = result.start;
        _endTime = result.end;
        _keyword = result.keyword;
        _page = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final filter = (
      status: _status,
      page: _page,
      startTime: _startTime,
      endTime: _endTime,
      mallType: null as int?,
      keyword: _keyword,
    );
    final purchasesAsync = ref.watch(purchasesProvider(filter));

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        leading: const BackLeadingButton(fallbackLocation: '/profile'),
        title: Text(l10n.ordersTitle,
            style: TextStyle(color: appTheme.fg)),
        backgroundColor: appTheme.bgElev,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        foregroundColor: appTheme.fg,
        actions: [
          IconButton(
            tooltip: l10n.ordersSearchTitle,
            icon: const Icon(Icons.search),
            onPressed: _openSearchSheet,
          ),
          IconButton(
            tooltip: l10n.ordersInfoPanelTitle,
            icon: SvgPicture.asset(
              'assets/icons/orders/info-circle.svg',
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                  appTheme.fg, BlendMode.srcIn),
            ),
            onPressed: _openInfoPanel,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(purchasesProvider(filter));
            await ref.read(purchasesProvider(filter).future);
          },
          child: purchasesAsync.when(
            data: (collection) {
              final orders = collection.data;
              final pagination = collection.meta;
              final totalPages =
                  int.tryParse(pagination?.totalPages ?? '1') ?? 1;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _StatusFilter(
                    current: _status,
                    onChanged: (value) => setState(() {
                      _status = value;
                      _page = 1;
                    }),
                  ),
                  const SizedBox(height: 8),
                  _DateRangeSummary(
                    startTime: _startTime,
                    endTime: _endTime,
                  ),
                  if (_keyword != null) ...[
                    const SizedBox(height: 6),
                    _KeywordChip(
                      keyword: _keyword!,
                      onClear: () => setState(() {
                        _keyword = null;
                        _page = 1;
                      }),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (orders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          l10n.orderEmpty,
                          style: TextStyle(color: appTheme.fgMuted),
                        ),
                      ),
                    )
                  else ...[
                    for (final order in orders) ...[
                      _OrderCard(order: order),
                      const SizedBox(height: 8),
                    ],
                    if (totalPages > 1)
                      _PaginationBar(
                        currentPage: _page,
                        totalPages: totalPages,
                        onPageChanged: (page) => setState(() => _page = page),
                      ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(
              message: '$error',
              onRetry: () => ref.invalidate(purchasesProvider(filter)),
            ),
          ),
        ),
      ),
    );
  }
}

/// 「所有訂單」dropdown.
class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.current, required this.onChanged});

  final String? current;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    // 對照設計稿的 10 種狀態（全部 / 待出貨 / 備貨中 / 已出貨 / 已送達 /
    // 已完成 / 退貨中 / 已退貨 / 已換貨 / 已取消）。web 預覽附上各狀態筆數。
    final items = [
      for (final o in kOrderStatusOptions)
        (
          status: o.code,
          label: isWebPreview
              ? '${o.label} (${sampleOrderCount(o.code)})'
              : o.label,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        border: Border.all(color: appTheme.divider),
        boxShadow: appTheme.elevation1,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: current,
          onChanged: onChanged,
          padding: const EdgeInsets.symmetric(horizontal: 10.5),
          dropdownColor: appTheme.bgElev,
          icon: Padding(
            padding: const EdgeInsets.only(right: 10.5),
            child: Icon(Icons.keyboard_arrow_down,
                size: 20, color: appTheme.fgMuted),
          ),
          style: TextStyle(
            color: appTheme.fg,
            fontSize: 14,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<String?>(
                value: item.status,
                child: Text(item.label),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeSummary extends StatelessWidget {
  const _DateRangeSummary({required this.startTime, required this.endTime});

  final DateTime startTime;
  final DateTime endTime;

  String _fmt(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final summary = l10n.ordersDateRangeSummary(_fmt(startTime), _fmt(endTime));

    // Split around the two date tokens so we can highlight them in danger.
    final spans = <TextSpan>[];
    final parts = summary.split(RegExp(r'(\d{4}/\d{2}/\d{2})'));
    final matches = RegExp(r'\d{4}/\d{2}/\d{2}').allMatches(summary).toList();
    var matchIndex = 0;
    for (final part in parts) {
      if (part.isNotEmpty) {
        spans.add(TextSpan(
          text: part,
          style: TextStyle(color: appTheme.fg),
        ));
      }
      if (matchIndex < matches.length) {
        spans.add(TextSpan(
          text: matches[matchIndex].group(0),
          style: TextStyle(color: appTheme.danger),
        ));
        matchIndex++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
          children: spans,
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({required this.order});

  final Purchase order;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _expanded = true;

  void _handleAction(_OrderAction action) {
    switch (action) {
      case _OrderAction.inquiry:
        _openSheet(const _OrderInquirySheet());
      case _OrderAction.changeAddress:
        _openSheet(const _ChangeAddressSheet());
      case _OrderAction.payInfo:
        _openSheet(_PayInfoSheet(order: widget.order));
    }
  }

  void _openSheet(Widget sheet) {
    final appTheme = context.appTheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: appTheme.bgElev,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(appTheme.sheetRadius),
        ),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final appTheme = context.appTheme;

    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        boxShadow: appTheme.elevation1,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderInfoList(order: order),
          const SizedBox(height: 7),
          // 配送進度/明細獨立一列 + 收合按鈕。
          _DetailToggleRow(
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: _expanded
                  ? Padding(
                      key: const ValueKey('expanded'),
                      padding: const EdgeInsets.only(top: 8),
                      child: _OrderDetailBody(
                        orderId: order.id,
                        createdAt: order.createdAt,
                        orderStatus: order.status,
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey('collapsed'),
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          // 三個獨立動作按鈕（配送進度/明細下方）：訂單提問 / 更換地址 /
          // 訂購・付款資訊。
          _OrderActionButtons(
            // 待付款 / 待出貨可更換地址；備貨中及出貨後停用。
            canChangeAddress:
                order.status == 'pending' || order.status == 'paid',
            onSelected: _handleAction,
          ),
        ],
      ),
    );
  }
}

class _OrderInfoList extends StatelessWidget {
  const _OrderInfoList({required this.order});

  final Purchase order;

  String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final missing = l10n.ordersFieldMissing;
    final rows = <({String label, String value, bool emphasised, Widget? trailing})>[
      (label: l10n.ordersFieldDate, value: _formatDate(order.createdAt),
          emphasised: false, trailing: null),
      (label: l10n.ordersFieldNumber, value: order.id.toString(),
          emphasised: false, trailing: null),
      (label: l10n.ordersFieldItemCount, value: order.itemCount.toString(),
          emphasised: false, trailing: null),
      (
        label: l10n.ordersFieldTotal,
        value: '\$${order.amount}',
        emphasised: true,
        // 訂單總額後方的「明細」按鈕 → 開金額明細。
        trailing: _AmountDetailButton(order: order),
      ),
      (label: l10n.ordersFieldPayment, value: order.paymentMethod ?? missing,
          emphasised: false, trailing: null),
      // 付款狀態：放在付款方式下面。
      (
        label: '付款狀態',
        value: _paymentStatusLabel(order.status),
        emphasised: false,
        trailing: null,
      ),
      (label: l10n.ordersFieldShipping, value: order.shippingMethod ?? missing,
          emphasised: false, trailing: null),
      // 配送狀態：與下拉選項一致的貨態文字；多包裹訂單顯示「處理中」。
      (
        label: '配送狀態',
        value: kMultiFulfillmentOrderIds.contains(order.id)
            ? '處理中'
            : orderStatusLabel(order.status),
        emphasised: false,
        trailing: null,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          _InfoRow(
            label: row.label,
            value: row.value,
            emphasised: row.emphasised,
            trailing: row.trailing,
          ),
      ],
    );
  }
}

/// 付款狀態（prototype）：退貨中 → 退款中；已退貨 / 已取消 → 已退款；其餘 → 已付款。
String _paymentStatusLabel(String? status) {
  switch (status) {
    case 'returning':
      return '退款中';
    case 'returned':
    case 'cancelled':
      return '已退款';
    default:
      return '已付款';
  }
}



class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.emphasised,
    this.trailing,
  });

  final String label;
  final String value;
  final bool emphasised;

  /// 選填：內容右側附加元件（例如訂單總額後的「明細」按鈕）。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final valueText = Text(
      value,
      style: TextStyle(
        fontSize: 16,
        fontWeight: emphasised ? FontWeight.w700 : FontWeight.w400,
        color: emphasised ? appTheme.danger : appTheme.fg,
        height: 1.5,
      ),
    );
    return Row(
      // label 與內容以文字基線對齊，讓不同字級的兩段文字看起來在同一行置中。
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$label：',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appTheme.fg,
            height: 1.5,
          ),
        ),
        if (trailing == null)
          Expanded(child: valueText)
        else ...[
          Flexible(child: valueText),
          const SizedBox(width: 10),
          trailing!,
          const Spacer(),
        ],
      ],
    );
  }
}

// ── 金額明細 ────────────────────────────────────────────────────────────────

/// 訂單總額後方的「明細」按鈕。
class _AmountDetailButton extends StatelessWidget {
  const _AmountDetailButton({required this.order});
  final Purchase order;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showAmountBreakdown(context, order),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(Icons.visibility_outlined, size: 18, color: accent),
        ),
      ),
    );
  }
}

/// prototype：由訂單總額推出金額明細（商品小計 / 優惠券 / 運費 / 運費折抵）。
({int subtotal, int coupon, int shipping, int rebate, int total})
    _amountBreakdown(num amount) {
  final total = amount.round();
  // 商品小計滿千折 300（運費與運費折抵相抵）。
  final coupon = total >= 700 ? 300 : 0;
  return (
    subtotal: total + coupon,
    coupon: coupon,
    shipping: 80,
    rebate: 80,
    total: total,
  );
}

void _showAmountBreakdown(BuildContext context, Purchase order) {
  final appTheme = context.appTheme;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: appTheme.bgElev,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AmountBreakdownSheet(order: order),
  );
}

class _AmountBreakdownSheet extends StatelessWidget {
  const _AmountBreakdownSheet({required this.order});
  final Purchase order;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final b = _amountBreakdown(order.amount);
    final bottom = MediaQuery.of(context).padding.bottom;

    Widget line(String label, String value, {bool discount = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 14, color: appTheme.fg)),
              ),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: discount ? appTheme.danger : appTheme.fg)),
            ],
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('金額明細',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: appTheme.fg)),
              ),
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 20, color: appTheme.fgMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          line('商品小計', 'NT\$${b.subtotal}'),
          if (b.coupon > 0)
            line('優惠券（滿千折${b.coupon}）', '-NT\$${b.coupon}',
                discount: true),
          line('運費', 'NT\$${b.shipping}'),
          line('運費折抵', '-NT\$${b.rebate}', discount: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: appTheme.divider),
          ),
          Row(
            children: [
              Expanded(
                child: Text('訂單總額',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: appTheme.fg)),
              ),
              Text('NT\$${b.total}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: accent)),
            ],
          ),
        ],
      ),
    );
  }
}

// 訂單卡三個獨立動作按鈕：訂單提問 / 更換地址 / 訂購・付款資訊。
class _OrderActionButtons extends StatelessWidget {
  const _OrderActionButtons({
    required this.canChangeAddress,
    required this.onSelected,
  });

  /// 待出貨前（待付款 / 待出貨）才可更換地址；備貨中 / 出貨後停用。
  final bool canChangeAddress;
  final ValueChanged<_OrderAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    Widget button(IconData icon, String label,
        {required bool enabled, required VoidCallback onTap}) {
      final color = enabled ? appTheme.fg : appTheme.muted;
      final iconColor = enabled ? appTheme.fgMuted : appTheme.muted;
      return Expanded(
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          child: Container(
            height: 33,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: appTheme.bgElev,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
              boxShadow: appTheme.elevation1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        button(Icons.help_outline, '訂單提問',
            enabled: true, onTap: () => onSelected(_OrderAction.inquiry)),
        const SizedBox(width: 8),
        button(Icons.place_outlined, '更換地址',
            enabled: canChangeAddress,
            onTap: () => onSelected(_OrderAction.changeAddress)),
        const SizedBox(width: 8),
        button(Icons.receipt_long_outlined, '訂購/付款資訊',
            enabled: true, onTap: () => onSelected(_OrderAction.payInfo)),
      ],
    );
  }
}

// 配送進度/明細：獨立一列 + 收合按鈕；展開顯示商品、規格與貨態。
class _DetailToggleRow extends StatelessWidget {
  const _DetailToggleRow({
    required this.expanded,
    required this.onToggle,
  });

  final bool expanded;

  /// 展開 / 收合明細。
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            child: Container(
              height: 33,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.ordersDetailToggle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: appTheme.fg,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            alignment: Alignment.center,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              turns: expanded ? 0.5 : 0,
              child: const Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailBody extends ConsumerWidget {
  const _OrderDetailBody({
    required this.orderId,
    required this.createdAt,
    required this.orderStatus,
  });

  final int orderId;
  final String createdAt;
  final String? orderStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(purchaseDetailProvider(orderId));
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: detailAsync.when(
        data: (detail) {
          if (detail.items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.orderEmpty,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < detail.items.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: i == detail.items.length - 1 ? 0 : 8),
                  child: _DetailItemBlock(
                    item: detail.items[i],
                    orderCreatedAt: createdAt,
                    orderStatus: orderStatus,
                    isLast: i == detail.items.length - 1,
                  ),
                ),
            ],
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline,
                  size: 16, color: Color(0xFFEF4444)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.ordersDetailLoadFailed,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.invalidate(purchaseDetailProvider(orderId)),
                child: Text(l10n.orderRefresh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItemBlock extends StatelessWidget {
  const _DetailItemBlock({
    required this.item,
    required this.orderCreatedAt,
    required this.orderStatus,
    required this.isLast,
  });

  final PurchaseDetailItem item;
  final String orderCreatedAt;
  final String? orderStatus;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = item.productName ?? '';
    final spec = item.variantName;
    final unitPrice = item.unitPrice;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 48,
                  height: 48,
                  color: const Color(0xFFD9D9D9),
                  child: item.imageUrl == null
                      ? null
                      : Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const SizedBox.shrink(),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // 與上方 label 後方內容一致（同字級、同一般字重）。
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155),
                        height: 1.1,
                      ),
                    ),
                    if (spec != null && spec.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.ordersItemSpec(spec),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (unitPrice != null)
                    Text(
                      '\$$unitPrice',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF334155),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.ordersItemQtySuffix(item.quantity),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final fulfillment in item.fulfillments)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _FulfillmentPackage(
                fulfillment: fulfillment,
                orderCreatedAt: orderCreatedAt,
                orderStatus: orderStatus,
              ),
            ),
        ],
      ),
    );
  }
}

class _FulfillmentPackage extends StatelessWidget {
  const _FulfillmentPackage({
    required this.fulfillment,
    required this.orderCreatedAt,
    required this.orderStatus,
  });

  final PurchaseFulfillment fulfillment;
  final String orderCreatedAt;
  final String? orderStatus;

  /// 貨態階段索引：待出貨(0)/備貨中(1)/已出貨(2)/已送達(3)/第五格(4)。
  /// 退貨中/已退貨/已換貨/已取消：第五格改標籤，前四格皆已達成 → 回傳 4。
  /// 尚未付款 / 尚未配箱回傳 -1（整條時間軸呈灰色、header 顯示「尚未配箱」）。
  int _activeIndex() {
    switch (orderStatus) {
      case 'paid':
        return 0;
      case 'preparing':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      case 'completed':
      case 'returning':
      case 'returned':
      case 'exchanged':
      case 'cancelled':
        return 4;
      default:
        return -1; // pending / 其他
    }
  }

  /// 第五格的標籤與圖示依訂單狀態調整（與下拉配送狀態選項一致）。
  /// 一般貨態為「已完成」（check）；退貨/換貨/取消則換成對應狀態文字與圖示。
  ({String label, String? svgIcon, IconData? iconData}) _lastStage() {
    switch (orderStatus) {
      case 'returning':
        return (label: '退貨中', svgIcon: null, iconData: Icons.autorenew);
      case 'returned':
        return (label: '已退貨', svgIcon: null, iconData: Icons.autorenew);
      case 'exchanged':
        return (label: '已換貨', svgIcon: null, iconData: Icons.swap_horiz);
      case 'cancelled':
        return (label: '已取消', svgIcon: null, iconData: Icons.close);
      default:
        return (
          label: '已完成',
          svgIcon: 'assets/icons/orders/check.svg',
          iconData: null,
        );
    }
  }

  /// 依基準時間推算 5 個階段的預估時間（prototype 用，讓每格都有時間顯示）。
  List<String> _stageTimestamps() {
    final base = DateTime.tryParse(fulfillment.paidAt ?? orderCreatedAt)
        ?.toLocal();
    if (base == null) return List.filled(5, '');
    const offsets = [
      Duration.zero,
      Duration(hours: 8),
      Duration(days: 1, hours: 3),
      Duration(days: 2, hours: 22),
      Duration(days: 4, hours: 10),
    ];
    String fmt(DateTime d) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(d.month)}/${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    }

    return [for (final o in offsets) fmt(base.add(o))];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activeIndex = _activeIndex();
    // 已配箱（待出貨起）才有包裹編號；尚未配箱則顯示「尚未配箱」。
    final headerLabel =
        activeIndex >= 0 ? '包裹編號：${fulfillment.id}' : '尚未配箱';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/orders/package-outline.svg',
                width: 14,
                height: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headerLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ),
              Text(
                l10n.ordersPackagePieces(
                    int.tryParse(fulfillment.itemQuantity) ?? 0),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            child: _Timeline(
              activeIndex: activeIndex,
              timestamps: _stageTimestamps(),
              lastStage: _lastStage(),
              onTrackTap: () => showDialog<void>(
                context: context,
                builder: (_) =>
                    _ShippingProgressCard(packageNo: 'F${fulfillment.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.activeIndex,
    required this.timestamps,
    required this.lastStage,
    required this.onTrackTap,
  });

  /// 已到達的最後階段索引；-1 表示尚未配箱（整條灰色）。
  final int activeIndex;

  /// 5 個階段的時間文字（依序：待出貨/備貨中/已出貨/已送達/第五格）。
  final List<String> timestamps;

  /// 第五格內容（依訂單狀態：已完成 / 退貨中 / 已退貨 / 已換貨 / 已取消）。
  final ({String label, String? svgIcon, IconData? iconData}) lastStage;

  /// 點「已出貨（查看配送進度）」時開啟物流配送進度彈窗。
  final VoidCallback onTrackTap;

  // 前四格固定；第五格由 [lastStage] 決定標籤與圖示。
  static const _baseStages =
      <({String label, String svgIcon, bool trackLink})>[
    (label: '待出貨', svgIcon: 'assets/icons/orders/box.svg', trackLink: false),
    (
      label: '備貨中',
      svgIcon: 'assets/icons/orders/package-outline.svg',
      trackLink: false
    ),
    (label: '已出貨', svgIcon: 'assets/icons/orders/truck.svg', trackLink: true),
    (label: '已送達', svgIcon: 'assets/icons/orders/check.svg', trackLink: false),
  ];

  @override
  Widget build(BuildContext context) {
    final stages =
        <({String label, String? svgIcon, IconData? iconData, bool trackLink})>[
      for (final s in _baseStages)
        (
          label: s.label,
          svgIcon: s.svgIcon,
          iconData: null,
          trackLink: s.trackLink
        ),
      (
        label: lastStage.label,
        svgIcon: lastStage.svgIcon,
        iconData: lastStage.iconData,
        trackLink: false,
      ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++)
          Expanded(
            child: _TimelineEvent(
              label: stages[i].label,
              svgIcon: stages[i].svgIcon,
              iconData: stages[i].iconData,
              timestamp: i < timestamps.length ? timestamps[i] : '',
              reached: i <= activeIndex,
              isFirst: i == 0,
              isLast: i == stages.length - 1,
              // 進入本格（左線）／離開本格（右線）的區段是否已完成。
              leftActive: i <= activeIndex,
              rightActive: (i + 1) <= activeIndex,
              // 「已出貨」只要已達成（含已送達之後）都可查看配送進度紀錄。
              showTrackLink: stages[i].trackLink && i <= activeIndex,
              onTrackTap: onTrackTap,
            ),
          ),
      ],
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.label,
    required this.svgIcon,
    required this.iconData,
    required this.timestamp,
    required this.reached,
    required this.isFirst,
    required this.isLast,
    required this.leftActive,
    required this.rightActive,
    required this.showTrackLink,
    required this.onTrackTap,
  });

  final String label;
  // 圓點內圖示：svgIcon（一般貨態）或 iconData（退貨/換貨/取消用 Material icon）。
  final String? svgIcon;
  final IconData? iconData;
  final String timestamp;
  final bool reached;
  final bool isFirst;
  final bool isLast;
  final bool leftActive;
  final bool rightActive;
  final bool showTrackLink;
  final VoidCallback onTrackTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    const grey = Color(0xFF94A3B8);
    const lineGrey = Color(0xFFE2E8F0);
    final labelColor = reached ? const Color(0xFF334155) : grey;

    Widget line(bool show, bool active) => Expanded(
          child: show
              ? Container(height: 2, color: active ? accent : lineGrey)
              : const SizedBox(),
        );

    return Column(
      children: [
        // 時間（圓點上方）— 只有亮燈（已到達）的階段才顯示時間。
        SizedBox(
          height: 15,
          child: Text(
            reached ? timestamp : '',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // 左線 + 圓點 + 右線
        Row(
          children: [
            line(!isFirst, leftActive),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: reached ? accent : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: reached ? accent : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: iconData != null
                  ? Icon(iconData,
                      size: 15, color: reached ? Colors.white : grey)
                  : SvgPicture.asset(
                      svgIcon!,
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                          reached ? Colors.white : grey, BlendMode.srcIn),
                    ),
            ),
            line(!isLast, rightActive),
          ],
        ),
        const SizedBox(height: 6),
        // 標籤（圓點下方）；已出貨為目前階段時，狀態名稱加底線並可點開物流進度。
        if (showTrackLink)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTrackTap,
              child: Column(
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    // 與其他狀態同字色，只多加底線與斜體以示可點。
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                      decorationColor: labelColor,
                    ),
                  ),
                  Text(
                    '查看配送進度',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: labelColor,
            ),
          ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Text(
          l10n.orderLoadFailed,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text(l10n.orderRefresh),
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const baseText = Color(0xFF334155);
    const border = Color(0xFFE2E8F0);
    const danger = Color(0xFFEF4444);

    final rights = [
      l10n.ordersInfoRightsItem1,
      l10n.ordersInfoRightsItem2,
      l10n.ordersInfoRightsItem3,
      l10n.ordersInfoRightsItem4,
      l10n.ordersInfoRightsItem5,
    ];
    final rules = [
      l10n.ordersInfoReturnRule1,
      null, // rule 2 rendered with highlight
    ];
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.78),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: border)),
              ),
              padding: const EdgeInsets.fromLTRB(15.75, 5.25, 5.25, 5.25),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.ordersInfoPanelTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: baseText,
                        height: 1.0,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                        minWidth: 35, minHeight: 35),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    15.75, 12, 15.75, 15.75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < rights.length; i++)
                      _NumberedItem(index: i + 1, text: rights[i]),
                    const SizedBox(height: 8),
                    Text(
                      l10n.ordersInfoReturnTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF050004),
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (var i = 0; i < rules.length; i++)
                      if (rules[i] != null)
                        _NumberedItem(index: i + 1, text: rules[i]!)
                      else
                        _NumberedItem.rich(
                          index: i + 1,
                          spans: [
                            TextSpan(text: l10n.ordersInfoReturnRule2Prefix),
                            TextSpan(
                              text: l10n.ordersTimelineDelivered,
                              style: const TextStyle(color: danger),
                            ),
                            TextSpan(text: l10n.ordersInfoReturnRule2Suffix),
                          ],
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  const _NumberedItem({required this.index, required this.text})
      : spans = null;
  const _NumberedItem.rich({required this.index, required this.spans})
      : text = '';

  final int index;
  final String text;
  final List<TextSpan>? spans;

  @override
  Widget build(BuildContext context) {
    const baseText = Color(0xFF334155);
    const style = TextStyle(
      fontSize: 14,
      color: baseText,
      height: 1.625,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 21,
            child: Text('$index.', style: style),
          ),
          Expanded(
            child: spans == null
                ? Text(text, style: style)
                : RichText(
                    text: TextSpan(style: style, children: spans),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.keyword, required this.onClear});

  final String keyword;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InputChip(
        label: Text(keyword),
        onDeleted: onClear,
        deleteIconColor: const Color(0xFF475569),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        labelStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _SearchPayload {
  const _SearchPayload({
    required this.start,
    required this.end,
    required this.keyword,
  });

  final DateTime start;
  final DateTime end;
  final String? keyword;
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.initialStart,
    required this.initialEnd,
    required this.initialKeyword,
  });

  final DateTime initialStart;
  final DateTime initialEnd;
  final String? initialKeyword;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  late DateTime _start;
  late DateTime _end;
  late final TextEditingController _keywordCtrl;
  String? _error;

  static const _maxRangeDays = 186; // ~6 months
  static const _windowDays = 365 * 2; // 2 years

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
    _keywordCtrl = TextEditingController(text: widget.initialKeyword ?? '');
  }

  @override
  void dispose() {
    _keywordCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(days: _windowDays));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: earliest,
      lastDate: now,
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (picked != null) {
      setState(() {
        _start = DateTime(
            picked.start.year, picked.start.month, picked.start.day);
        _end = DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
        _error = null;
      });
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if (_end.difference(_start).inDays > _maxRangeDays) {
      setState(() => _error = l10n.ordersSearchErrorRangeTooLong);
      return;
    }
    if (now.difference(_start).inDays > _windowDays) {
      setState(() => _error = l10n.ordersSearchErrorOutOfWindow);
      return;
    }
    final keyword = _keywordCtrl.text.trim();
    Navigator.of(context).pop(_SearchPayload(
      start: _start,
      end: _end,
      keyword: keyword.isEmpty ? null : keyword,
    ));
  }

  void _reset() {
    final end = DateTime.now();
    setState(() {
      _end = DateTime(end.year, end.month, end.day, 23, 59, 59);
      _start = _OrdersScreenState._defaultStart(_end);
      _keywordCtrl.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const borderColor = Color(0xFFCBD5E1);
    const baseText = Color(0xFF334155);
    const placeholder = Color(0xFF64748B);
    final primary = context.appTheme.brandPalette.tone500;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.ordersSearchTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: baseText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    color: placeholder,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.ordersSearchDateLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: baseText,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickRange,
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D121217),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_fmt(_start)} - ${_fmt(_end)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: baseText,
                          ),
                        ),
                      ),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border(
                              left: BorderSide(color: borderColor)),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: SvgPicture.asset(
                          'assets/icons/orders/calendar.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                              Color(0xFF475569), BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.ordersSearchDateHelper,
                style: const TextStyle(
                  fontSize: 12,
                  color: baseText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D121217),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10.5),
                      child: TextField(
                        controller: _keywordCtrl,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _submit(),
                        style: const TextStyle(
                            fontSize: 14, color: baseText),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: l10n.ordersSearchKeywordPlaceholder,
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: placeholder,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 3),
                          blurRadius: 1,
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Color(0x24000000),
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                        BoxShadow(
                          color: Color(0x1F000000),
                          offset: Offset(0, 1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Text(
                            l10n.ordersSearchSubmit,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                      color: Color(0xFFEF4444), fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _reset,
                  child: Text(l10n.ordersSearchReset),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          ),
          Text(
            '$currentPage / $totalPages',
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 訂單卡下拉動作的 bottom sheets（訂單提問 / 更換地址 / 訂購·付款資訊）
// 皆為 prototype：送出 / 選擇後以 SnackBar 回饋，尚未串接後端。
// ─────────────────────────────────────────────────────────────────────────
class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 22, color: appTheme.fgMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

// 訂單提問 —— AI 智能客服（待開發）佔位。
class _OrderInquirySheet extends StatelessWidget {
  const _OrderInquirySheet();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _SheetScaffold(
      title: '訂單提問',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: appTheme.bgSubtle,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.support_agent,
                  size: 56, color: appTheme.muted),
            ),
            const SizedBox(height: 16),
            Text(
              'AI 智能客服',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: appTheme.fg,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '(待開發)',
              style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// 更換配送地址 —— 顯示原收件資料，並填入新收件人 / 電話 / 城市區 / 詳細地址。
class _ChangeAddressSheet extends StatefulWidget {
  const _ChangeAddressSheet();

  @override
  State<_ChangeAddressSheet> createState() => _ChangeAddressSheetState();
}

class _ChangeAddressSheetState extends State<_ChangeAddressSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  static const _codes = ['+886', '+852', '+86', '+81', '+82', '+65', '+1'];
  String _phoneCode = '+886';
  String? _city;
  String? _district;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  BoxDecoration _boxDeco(AppThemeExtension t) => BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: Border.all(color: t.divider),
      );

  Widget _lbl(String s, {bool req = false}) {
    final t = context.appTheme;
    final style =
        TextStyle(fontSize: 12, color: t.fgMuted, fontWeight: FontWeight.w600);
    if (!req) return Text(s, style: style);
    return Text.rich(TextSpan(style: style, children: [
      TextSpan(text: s),
      TextSpan(text: ' *', style: TextStyle(color: t.danger)),
    ]));
  }

  Widget _field(TextEditingController c, String hint) {
    final t = context.appTheme;
    return Container(
      decoration: _boxDeco(t),
      child: TextField(
        controller: c,
        style: TextStyle(fontSize: 14, color: t.fg),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: t.fgMuted),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        ),
      ),
    );
  }

  Widget _dd({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    final t = context.appTheme;
    return Container(
      decoration: _boxDeco(t),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: TextStyle(fontSize: 14, color: t.fgMuted)),
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: t.fg),
          dropdownColor: t.bgElev,
          icon: Icon(Icons.keyboard_arrow_down, color: t.fgMuted),
          items: [
            for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
          ],
        ),
      ),
    );
  }

  Widget _readonly(String label, String value) {
    final t = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl(label),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, color: t.fg)),
      ],
    );
  }

  void _confirm() {
    if (_addrCtrl.text.trim().isEmpty) {
      setState(() => _error = '請輸入詳細收件地址');
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已更換配送地址')));
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final districts = _addrCityDistricts[_city] ?? const <String>[];

    return _SheetScaffold(
      title: '更換配送地址',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 原收件資料（唯讀）
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _readonly('原收件人', '陳曉娟')),
                Expanded(
                    child: _readonly('原聯絡電話', '(+886) 912 345 678')),
              ],
            ),
            const SizedBox(height: 14),
            _readonly('原配送地址', '桃園市桃園區南平路 303 號'),
            const SizedBox(height: 16),
            _lbl('新收件人'),
            const SizedBox(height: 6),
            _field(_nameCtrl, ''),
            const SizedBox(height: 14),
            _lbl('新聯絡電話'),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  decoration: _boxDeco(appTheme),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _phoneCode,
                      style: TextStyle(fontSize: 14, color: appTheme.fg),
                      dropdownColor: appTheme.bgElev,
                      onChanged: (v) =>
                          setState(() => _phoneCode = v ?? _phoneCode),
                      items: [
                        for (final c in _codes)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _field(_phoneCtrl, '例如：0912345678')),
              ],
            ),
            const SizedBox(height: 14),
            _lbl('城市 / 區'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _dd(
                    value: _city,
                    hint: '請選擇城市',
                    items: _addrCityDistricts.keys.toList(),
                    onChanged: (v) => setState(() {
                      _city = v;
                      _district = null;
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dd(
                    value: districts.contains(_district) ? _district : null,
                    hint: _city == null ? '請先選城市' : '請選擇區',
                    items: districts,
                    onChanged: districts.isEmpty
                        ? null
                        : (v) => setState(() => _district = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _lbl('詳細收件地址', req: true),
            const SizedBox(height: 6),
            _field(_addrCtrl, '街道、門牌、樓層'),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: appTheme.danger, fontSize: 12)),
            ],
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                      foregroundColor: appTheme.fgMuted),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(appTheme.buttonRadius),
                    ),
                  ),
                  child: const Text('確認更換',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 更換地址用的城市 / 區資料（prototype 涵蓋主要縣市）。
const Map<String, List<String>> _addrCityDistricts = {
  '台北市': ['中正區', '大同區', '中山區', '松山區', '大安區', '萬華區', '信義區', '士林區', '北投區', '內湖區', '南港區', '文山區'],
  '新北市': ['板橋區', '三重區', '中和區', '永和區', '新莊區', '新店區', '土城區', '蘆洲區', '淡水區', '林口區'],
  '桃園市': ['桃園區', '中壢區', '平鎮區', '八德區', '楊梅區', '蘆竹區', '龜山區', '大溪區'],
  '台中市': ['中區', '東區', '南區', '西區', '北區', '北屯區', '西屯區', '南屯區', '大里區', '豐原區'],
  '台南市': ['中西區', '東區', '南區', '北區', '安平區', '安南區', '永康區', '歸仁區'],
  '高雄市': ['楠梓區', '左營區', '鼓山區', '三民區', '苓雅區', '新興區', '前金區', '前鎮區', '鳳山區', '仁武區'],
};

class _PayInfoSheet extends StatefulWidget {
  const _PayInfoSheet({required this.order});
  final Purchase order;

  @override
  State<_PayInfoSheet> createState() => _PayInfoSheetState();
}

class _PayInfoSheetState extends State<_PayInfoSheet> {
  // 姓名遮罩：保留中間、遮首尾（陳曉娟 → *曉*）。
  String _maskName(String name) {
    if (name.length <= 1) return name;
    final chars = name.split('');
    chars[0] = '*';
    chars[chars.length - 1] = '*';
    return chars.join();
  }

  // 手機遮罩：保留前 4 碼與末 3 碼（0912345678 → 0912***678）。
  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 4)}***${phone.substring(phone.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final order = widget.order;

    Widget row(String label, Widget value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(label,
                    style: TextStyle(fontSize: 13, color: appTheme.fgMuted)),
              ),
              Expanded(child: value),
            ],
          ),
        );

    Widget txt(String v, {bool strong = false, Color? color}) => Text(
          v,
          style: TextStyle(
            fontSize: 14,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            color: color ?? appTheme.fg,
          ),
        );

    return _SheetScaffold(
      title: '訂購／付款資訊',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            row('收件人姓名', txt(_maskName('陳曉娟'))),
            row('手機號碼', txt(_maskPhone('0912345678'))),
            row('收件地址', txt('高雄市三民區北平一街 103 號')),
            row('付款方式', txt(order.paymentMethod ?? 'ATM 繳費帳號')),
          ],
        ),
      ),
    );
  }
}

// 彈窗共用：標題列（標題 + 關閉 X）。
Widget _dialogHeader(BuildContext context, String title) {
  final appTheme = context.appTheme;
  return Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: appTheme.fg,
          ),
        ),
      ),
      InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Icon(Icons.close, size: 20, color: appTheme.fgMuted),
        ),
      ),
    ],
  );
}


// ─────────────────────────────────────────────────────────────────────────
// 物流配送進度彈窗（prototype 範例資料，點時間軸「已出貨（查看配送進度）」開啟）。
// ─────────────────────────────────────────────────────────────────────────
class _ShippingProgressCard extends StatelessWidget {
  const _ShippingProgressCard({required this.packageNo});

  final String packageNo;

  static const _rows = <({String status, String time, String unit, String note})>[
    (status: '貨件送達', time: '2026/02/10 08:00', unit: '○○超商', note: '簽收'),
    (status: '配送中', time: '2026/02/10 01:00', unit: '新竹物流', note: ''),
    (status: '轉運作業中', time: '2026/02/09 16:00', unit: '高轉', note: '貨件到站'),
    (status: '取件完成', time: '2026/02/09 13:00', unit: '直營', note: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    Widget headerCell(String t, int flex) => Expanded(
          flex: flex,
          child: Text(t,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: appTheme.fg)),
        );
    Widget cell(String t, int flex, {bool strong = false}) => Expanded(
          flex: flex,
          child: Text(t,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                  color: appTheme.fg)),
        );

    return Dialog(
      backgroundColor: appTheme.bgElev,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _dialogHeader(context, '物流配送進度'),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _LabeledValue(label: '配送方式', value: '新竹物流'),
                    ),
                    Expanded(
                      child: _LabeledValue(label: '出貨單號', value: packageNo),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      headerCell('狀態', 3),
                      headerCell('處理時間', 4),
                      headerCell('負責單位', 3),
                      headerCell('備註', 2),
                    ],
                  ),
                ),
                Divider(height: 1, color: appTheme.divider),
                for (final r in _rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        cell(r.status, 3, strong: true),
                        cell(r.time, 4),
                        cell(r.unit, 3),
                        cell(r.note, 2),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 直式「標籤 + 值」（彈窗內兩欄用）。
class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: appTheme.fgMuted)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, color: appTheme.fg)),
      ],
    );
  }
}
