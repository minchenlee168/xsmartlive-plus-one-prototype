import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/cart_api.dart';
import '../../../providers/product_provider.dart';
import '../../../theme/app_theme_extension.dart';
import '../../../utils/responsive.dart';

class CartDrawer extends ConsumerWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartApiProvider);
    final appTheme = context.appTheme;

    return Drawer(
      width: Responsive.cappedWidth(
        context,
        ratio: 0.82,
        cap: Responsive.drawerMaxWidth,
      ),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: cartAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  Text(l10n.cartLoadFailed, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.read(cartApiProvider.notifier).refresh(),
                    child: Text(l10n.cartRetry),
                  ),
                ],
              ),
            );
          },
          data: (cart) {
            final items = cart?.items ?? [];
            final total = cart?.total ?? 0.0;
            return Column(
              children: [
                _CartHeader(
                  itemCount: items.fold(0, (s, c) => s + c.quantity),
                  onClose: () => Navigator.of(context).pop(),
                ),
                Divider(color: Colors.grey.shade200, height: 1),
                Expanded(
                  child: items.isEmpty
                      ? const _EmptyCart()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _CartItemTile(
                            item: items[i],
                            onRemove: () => ref
                                .read(cartApiProvider.notifier)
                                .removeItem(items[i].id),
                          ),
                        ),
                ),
                if (items.isNotEmpty) ...[
                  Divider(color: Colors.grey.shade200, height: 1),
                  _CartFooter(
                    subtotal: cart?.subtotal ?? 0.0,
                    discount: cart?.discount ?? 0.0,
                    total: total,
                    appTheme: appTheme,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCount, required this.onClose});

  final int itemCount;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            l10n.cartTitle(itemCount),
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close, color: Colors.grey.shade500, size: 24),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerStatefulWidget {
  const _CartItemTile({required this.item, required this.onRemove});

  final CartApiItem item;
  final VoidCallback onRemove;

  @override
  ConsumerState<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends ConsumerState<_CartItemTile> {
  bool _updating = false;

  Future<void> _changeQty(int delta) async {
    final newQty = widget.item.quantity + delta;
    if (newQty < 1 || _updating) return;
    setState(() => _updating = true);
    try {
      await ref
          .read(cartApiProvider.notifier)
          .updateItem(widget.item.id, quantity: newQty);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final l10n = AppLocalizations.of(context)!;
    final name = item.product.name ?? l10n.cartProductFallback;
    final subtotal = item.unitPrice * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              item.image ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.image_not_supported, color: Colors.grey.shade300, size: 28),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
          const SizedBox(width: 12),
          // Name + quantity controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: _updating ? null : () => _changeQty(-1),
                      enabled: item.quantity > 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _updating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            )
                          : Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E)),
                            ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: _updating ? null : () => _changeQty(1),
                      enabled: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Price + delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.cartItemPrice(subtotal.toStringAsFixed(0)),
                style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(Icons.delete_outline,
                    color: Colors.grey.shade400, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onTap != null;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? Colors.grey.shade300 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: active ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
        ),
      ),
    );
  }
}

class _CartFooter extends StatelessWidget {
  const _CartFooter({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.appTheme,
  });

  final double subtotal;
  final double discount;
  final double total;
  final AppThemeExtension appTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.cartSubtotal,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              Text('\$${subtotal.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.cartDiscount,
                    style:
                        TextStyle(color: Colors.green.shade600, fontSize: 14)),
                Text('-\$${discount.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Colors.green.shade600, fontSize: 14)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.cartTotal,
                  style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              Text(
                '\$${total.toStringAsFixed(0)}',
                style: TextStyle(
                  color: appTheme.primaryGradient.colors.last,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: appTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/checkout');
                },
                child: Text(
                  l10n.cartCheckout,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Color(0xFFD1C4E9), size: 56),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context)!.cartEmpty,
              style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14)),
        ],
      ),
    );
  }
}

