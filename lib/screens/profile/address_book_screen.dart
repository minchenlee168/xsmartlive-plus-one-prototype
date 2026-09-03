import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/back_leading_button.dart';
import 'address_form_sheet.dart';

/// 收件地址簿 — 宅配 / 超商取貨雙分頁管理。
///
/// 後端 API（list / create / destroy / setDefault）與 repository、provider
/// 早已就緒，先前缺的就是這個畫面。全部視覺 token 走 `context.appTheme.*`，
/// 與綁定手機 / 修改密碼等個人中心頁面一致。
class AddressBookScreen extends StatelessWidget {
  const AddressBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: appTheme.bg,
        appBar: AppBar(
          leading: const BackLeadingButton(fallbackLocation: '/settings'),
          title: const Text('收件地址'),
          backgroundColor: appTheme.bgElev,
          foregroundColor: appTheme.fg,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          bottom: TabBar(
            labelColor: accent,
            unselectedLabelColor: appTheme.fgMuted,
            indicatorColor: accent,
            // 移除 M3 TabBar 預設底部分隔線（黑/灰線）。
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: '宅配'),
              Tab(text: '超商取貨'),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _HomeDeliveryTab(),
              _StorePickupTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 宅配分頁
// ─────────────────────────────────────────────────────────────────────────
class _HomeDeliveryTab extends ConsumerWidget {
  const _HomeDeliveryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeDeliveryAddressesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetry(
        message: _msg(e),
        onRetry: () =>
            ref.read(homeDeliveryAddressesProvider.notifier).refresh(),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.home_outlined,
            label: '尚未新增宅配地址',
            onAdd: () => _openHomeForm(context),
          );
        }
        return _ListScaffold(
          onAdd: () => _openHomeForm(context),
          children: [
            for (final a in list)
              _HomeDeliveryCard(
                address: a,
                onSetDefault: a.isDefault
                    ? null
                    : () => _run(
                          context,
                          () => ref
                              .read(homeDeliveryAddressesProvider.notifier)
                              .setDefault(a.id),
                          '已設為預設',
                        ),
                onEdit: () => showAddressFormSheet(context,
                    type: AddressFormType.home, editHome: a),
                onDelete: () => _confirmDelete(
                  context,
                  () => ref
                      .read(homeDeliveryAddressesProvider.notifier)
                      .destroy(a.id),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openHomeForm(BuildContext context) {
    showAddressFormSheet(context, type: AddressFormType.home);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 超商取貨分頁
// ─────────────────────────────────────────────────────────────────────────
class _StorePickupTab extends ConsumerWidget {
  const _StorePickupTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(storePickupAddressesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorRetry(
        message: _msg(e),
        onRetry: () =>
            ref.read(storePickupAddressesProvider.notifier).refresh(),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyState(
            icon: Icons.storefront_outlined,
            label: '尚未新增超商取貨門市',
            onAdd: () => _openPickupForm(context),
          );
        }
        return _ListScaffold(
          onAdd: () => _openPickupForm(context),
          children: [
            for (final a in list)
              _StorePickupCard(
                address: a,
                onSetDefault: a.isDefault
                    ? null
                    : () => _run(
                          context,
                          () => ref
                              .read(storePickupAddressesProvider.notifier)
                              .setDefault(a.id),
                          '已設為預設',
                        ),
                onEdit: () => showAddressFormSheet(context,
                    type: AddressFormType.pickup, editPickup: a),
                onDelete: () => _confirmDelete(
                  context,
                  () => ref
                      .read(storePickupAddressesProvider.notifier)
                      .destroy(a.id),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openPickupForm(BuildContext context) {
    showAddressFormSheet(context, type: AddressFormType.pickup);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 共用：列表外框（含底部「新增」按鈕）
// ─────────────────────────────────────────────────────────────────────────
class _ListScaffold extends StatelessWidget {
  const _ListScaffold({required this.children, required this.onAdd});

  final List<Widget> children;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 96 + bottomInset),
          children: children,
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16 + bottomInset,
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('新增地址',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(appTheme.buttonRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 宅配地址卡
// ─────────────────────────────────────────────────────────────────────────
class _HomeDeliveryCard extends StatelessWidget {
  const _HomeDeliveryCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final HomeDeliveryAddress address;
  final VoidCallback? onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _AddressCardShell(
      isDefault: address.isDefault,
      disabled: address.disabled,
      title: address.recipientName,
      phone: address.fullRecipientPhone,
      body: address.fullAddress.isNotEmpty
          ? address.fullAddress
          : [address.city, address.district, address.addressLine]
              .where((s) => s.isNotEmpty)
              .join(' '),
      warning: address.disabled && address.unsupportedReason.isNotEmpty
          ? address.unsupportedReason
          : null,
      onSetDefault: onSetDefault,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 超商取貨地址卡
// ─────────────────────────────────────────────────────────────────────────
class _StorePickupCard extends StatelessWidget {
  const _StorePickupCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final StorePickupAddress address;
  final VoidCallback? onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final store = [address.pickupProvider, address.pickupStoreName]
        .where((s) => s.isNotEmpty)
        .join(' · ');
    // C13 新欄位：門市與最新快照不符 / 已停業時，後端用 warning_message 告知。
    final warning = address.warningMessage?.isNotEmpty == true
        ? address.warningMessage
        : (!address.matched ? '門市資訊已更新，請確認後再使用' : null);

    return _AddressCardShell(
      isDefault: address.isDefault,
      disabled: address.disabled,
      title: address.recipientName,
      phone: address.fullRecipientPhone,
      body: [
        if (store.isNotEmpty) store,
        if (address.pickupStoreCode.isNotEmpty) '門市代號 ${address.pickupStoreCode}',
        if (address.pickupStoreAddress.isNotEmpty) address.pickupStoreAddress,
      ].join('\n'),
      warning: warning,
      onSetDefault: onSetDefault,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 地址卡外殼（宅配 / 超商共用）
// ─────────────────────────────────────────────────────────────────────────
class _AddressCardShell extends StatelessWidget {
  const _AddressCardShell({
    required this.isDefault,
    required this.disabled,
    required this.title,
    required this.phone,
    required this.body,
    required this.warning,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isDefault;
  final bool disabled;
  final String title;
  final String phone;
  final String body;
  final String? warning;
  final VoidCallback? onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(
          color: isDefault ? accent : appTheme.divider,
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: appTheme.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 收件人 + 電話 + 預設標記
          Row(
            children: [
              Text(
                title.isNotEmpty ? title : '—',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: appTheme.fg,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                phone,
                style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
              ),
              const Spacer(),
              if (isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  ),
                  child: Text(
                    '預設',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: disabled ? appTheme.fgMuted : appTheme.fg,
            ),
          ),
          // 警告列（C13 warning_message / matched=false / unsupportedReason）
          if (warning != null && warning!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: appTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 16, color: appTheme.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warning!,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: appTheme.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Divider(height: 20, color: appTheme.divider),
          // 動作列：設為預設 / 刪除
          Row(
            children: [
              if (onSetDefault != null)
                _CardAction(
                  icon: Icons.radio_button_unchecked,
                  label: '設為預設',
                  onTap: onSetDefault!,
                ),
              const Spacer(),
              _CardAction(
                icon: Icons.edit_outlined,
                label: '編輯',
                onTap: onEdit,
              ),
              const SizedBox(width: 16),
              _CardAction(
                icon: Icons.delete_outline,
                label: '刪除',
                color: appTheme.danger,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final c = color ?? appTheme.fgMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: c),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 13, color: c)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 空狀態
// ─────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    required this.onAdd,
  });

  final IconData icon;
  final String label;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: appTheme.muted),
          const SizedBox(height: 14),
          Text(label, style: TextStyle(color: appTheme.fgMuted, fontSize: 14)),
          const SizedBox(height: 18),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('新增地址',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(appTheme.buttonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: TextStyle(color: appTheme.fgMuted, fontSize: 13)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('重試')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 共用 helper
// ─────────────────────────────────────────────────────────────────────────
String _msg(Object e) {
  final raw = e.toString();
  final colon = raw.indexOf(':');
  return colon != -1 ? raw.substring(colon + 1).trim() : raw;
}

Future<void> _run(
  BuildContext context,
  Future<void> Function() action,
  String successMsg,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
    messenger.showSnackBar(
      SnackBar(content: Text(successMsg), duration: const Duration(seconds: 2)),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(_msg(e)), duration: const Duration(seconds: 3)),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  Future<void> Function() action,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('刪除地址'),
      content: const Text('確定要刪除這筆收件地址嗎？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text('刪除',
              style: TextStyle(color: ctx.appTheme.danger)),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    await _run(context, action, '已刪除');
  }
}
