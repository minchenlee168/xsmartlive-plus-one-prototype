import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../models/purchase.dart';
import '../../providers/purchase_provider.dart';
import '../../theme/app_theme_extension.dart';

/// 5 timeline stages shown per fulfillment.
enum _OrderStage { pending, toShip, shipped, delivered, completed }

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
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final items = <({String? status, String label})>[
      (status: null, label: l10n.ordersFilterHintAll),
      (status: 'pending', label: l10n.orderFilterPending),
      (status: 'paid', label: l10n.orderFilterPaid),
      (status: 'shipped', label: l10n.orderFilterShipped),
      (status: 'completed', label: l10n.orderFilterCompleted),
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

  String? _statusLabel(BuildContext context, String? status) {
    if (status == null) return null;
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return l10n.ordersTimelinePending;
      case 'paid':
        return l10n.orderFilterPaid;
      case 'shipped':
        return l10n.ordersTimelineShipped;
      case 'completed':
        return l10n.ordersTimelineCompleted;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final missing = l10n.ordersFieldMissing;
    final rows = <({String label, String value, bool emphasised})>[
      (label: l10n.ordersFieldDate, value: _formatDate(order.createdAt),
          emphasised: false),
      (label: l10n.ordersFieldNumber, value: order.id.toString(),
          emphasised: false),
      (label: l10n.ordersFieldItemCount, value: order.itemCount.toString(),
          emphasised: false),
      (
        label: l10n.ordersFieldTotal,
        value: '\$${order.amount}',
        emphasised: true,
      ),
      (label: l10n.ordersFieldPayment, value: order.paymentMethod ?? missing,
          emphasised: false),
      (label: l10n.ordersFieldShipping, value: order.shippingMethod ?? missing,
          emphasised: false),
      (label: l10n.ordersFieldInvoice, value: missing, emphasised: false),
      (
        label: l10n.ordersFieldStatus,
        value: _statusLabel(context, order.status) ?? missing,
        emphasised: false,
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
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.emphasised,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label：',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appTheme.fg,
            height: 1.4,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: emphasised ? FontWeight.w700 : FontWeight.w400,
              color: emphasised ? appTheme.danger : appTheme.fg,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailToggleRow extends StatelessWidget {
  const _DetailToggleRow({required this.expanded, required this.onToggle});

  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            child: Container(
              height: 33,
              decoration: BoxDecoration(
                color: appTheme.bgElev,
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
                border: Border.all(color: appTheme.divider),
                boxShadow: appTheme.elevation1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10.5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.ordersDetailToggle,
                      style: TextStyle(
                        fontSize: 14,
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: appTheme.fgMuted,
                  ),
                ],
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.ordersItemQtySuffix(item.quantity),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  _OrderStage _activeStage() {
    if (orderStatus == 'completed') return _OrderStage.completed;
    switch (fulfillment.status) {
      case 0:
        // `0` = 待處理 → map to 待付款 when order still unpaid, else 待出貨
        if (orderStatus == 'pending') return _OrderStage.pending;
        return _OrderStage.toShip;
      case 1:
      case 2:
        return _OrderStage.shipped;
      case 3:
        return _OrderStage.delivered;
    }
    return _OrderStage.pending;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final active = _activeStage();
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
                  l10n.ordersPendingPackage,
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
              vertical: 10,
            ),
            child: _Timeline(
              active: active,
              pendingAt: fulfillment.paidAt ?? orderCreatedAt,
              shippedAt: fulfillment.shippedAt,
              deliveredAt: fulfillment.deliveredAt,
              completedAt: fulfillment.completedAt,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.active,
    required this.pendingAt,
    required this.shippedAt,
    required this.deliveredAt,
    required this.completedAt,
  });

  final _OrderStage active;
  final String? pendingAt;
  final String? shippedAt;
  final String? deliveredAt;
  final String? completedAt;

  String _fmtShort(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stages = <({_OrderStage stage, String label, String icon, String? timestamp})>[
      (
        stage: _OrderStage.pending,
        label: l10n.ordersTimelinePending,
        icon: 'assets/icons/orders/credit-card.svg',
        timestamp: _fmtShort(pendingAt),
      ),
      (
        stage: _OrderStage.toShip,
        label: l10n.ordersTimelineToShip,
        icon: 'assets/icons/orders/box.svg',
        timestamp: null,
      ),
      (
        stage: _OrderStage.shipped,
        label: l10n.ordersTimelineShipped,
        icon: 'assets/icons/orders/truck.svg',
        timestamp: _fmtShort(shippedAt),
      ),
      (
        stage: _OrderStage.delivered,
        label: l10n.ordersTimelineDelivered,
        icon: 'assets/icons/orders/check.svg',
        timestamp: _fmtShort(deliveredAt),
      ),
      (
        stage: _OrderStage.completed,
        label: l10n.ordersTimelineCompleted,
        icon: 'assets/icons/orders/check.svg',
        timestamp: _fmtShort(completedAt),
      ),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stages.length; i++)
          Expanded(
            flex: i == stages.length - 1 ? 0 : 1,
            child: _TimelineEvent(
              label: stages[i].label,
              icon: stages[i].icon,
              isActive: stages[i].stage == active,
              isLast: i == stages.length - 1,
              timestamp: stages[i].stage == active ? stages[i].timestamp : null,
            ),
          ),
      ],
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isLast,
    required this.timestamp,
  });

  final String label;
  final String icon;
  final bool isActive;
  final bool isLast;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final markerColor = isActive
        ? appTheme.brandPalette.tone500
        : const Color(0xFFCBD5E1);
    final iconColor = isActive ? Colors.white : const Color(0xFF94A3B8);
    final labelColor =
        isActive ? const Color(0xFF334155) : const Color(0xFF94A3B8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                icon,
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: labelColor,
            fontStyle: isActive && timestamp != null && timestamp!.isNotEmpty
                ? FontStyle.italic
                : FontStyle.normal,
          ),
        ),
        if (timestamp != null && timestamp!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              timestamp!,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: labelColor,
              ),
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
