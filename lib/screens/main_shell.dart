import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../providers/live_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_icons.dart';
import '../theme/app_theme_extension.dart';
import '../widgets/cart_fly_animation.dart';

/// 5-tab shell mirroring the prototype `src/nav.jsx` (default `tabs` style):
/// Home / Live / Shop / Cart / Profile.
///
/// Floating overlays (live-preview thumbnail + CS bubble) are stacked on top
/// of the body on screens where they don't interfere — matches prototype
/// `src/app.jsx`'s `hideFloat` list.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabPaths = ['/home', '/live', '/shop', '/cart', '/profile'];
  static const _tabIcons = [
    AppIcons.home,
    AppIcons.live,
    AppIcons.shop,
    AppIcons.cart,
    AppIcons.me,
  ];
  static const _tabActiveIcons = [
    AppIcons.homeFilled,
    AppIcons.liveFilled,
    AppIcons.shopFilled,
    AppIcons.cartFilled,
    AppIcons.meFilled,
  ];

  // Floating overlays are hidden on these tabs (prototype parity).
  // Cart and Profile tabs hide them so their own sticky bars / scroll
  // content remain unobscured.
  static const _hideFloatPaths = {'/cart'};

  int _currentIndex(String location) {
    for (var i = 0; i < _tabPaths.length; i++) {
      if (location.startsWith(_tabPaths[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _currentIndex(location);
    final cartCount = ref.watch(cartCountProvider);
    final appTheme = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final hideFloat = _hideFloatPaths.contains(location);

    final tabLabels = [
      l10n.navHome,
      l10n.navLive,
      l10n.navShop,
      l10n.navCart,
      l10n.navMe,
    ];

    return Scaffold(
      backgroundColor: appTheme.bg,
      extendBody: false,
      body: Stack(
        children: [
          Positioned.fill(child: child),
          if (!hideFloat)
            const Positioned(
              right: 12,
              bottom: 16,
              child: _FloatingDock(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        // Smaller label font + Material 3's built-in fade so labels like
        // "Live Shopping" / "Siaran Langsung" never wrap to a 2nd line.
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(fontSize: 10, color: appTheme.fg),
          ),
        ),
        child: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: appTheme.bgElev,
        indicatorColor: appTheme.brandPalette.tone100,
        onDestinationSelected: (i) => context.go(_tabPaths[i]),
        destinations: List.generate(_tabPaths.length, (i) {
          final icon = Icon(_tabIcons[i]);
          // Cart tab gets the cart-count badge (was previously on the
          // global header before MainShell switched to 5 tabs).
          final iconWithBadge = (i == 3 && cartCount > 0)
              ? Badge(
                  backgroundColor: appTheme.brandPalette.tone500,
                  label: Text('$cartCount'),
                  child: icon,
                )
              : icon;
          // Anchor cart-fly animations to the cart tab icon and let the
          // wrapper play the receive-bounce when particles arrive.
          final cartFlyAnchored = i == 3
              ? CartFlyAnimation.cartTargetWrapper(child: iconWithBadge)
              : iconWithBadge;
          return NavigationDestination(
            icon: cartFlyAnchored,
            selectedIcon:
                Icon(_tabActiveIcons[i], color: scheme.primary),
            label: tabLabels[i],
          );
        }),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Floating dock — live preview thumbnail + CS bubble (matches prototype)
// ───────────────────────────────────────────────────────────────────────────
class _FloatingDock extends ConsumerStatefulWidget {
  const _FloatingDock();

  @override
  ConsumerState<_FloatingDock> createState() => _FloatingDockState();
}

class _FloatingDockState extends ConsumerState<_FloatingDock> {
  // User-dismissed flag for the live-preview PiP. Resets on next app launch
  // (per-session). If the user wants persistence, swap this for a
  // SharedPreferences-backed Riverpod provider.
  bool _livePreviewDismissed = false;

  @override
  Widget build(BuildContext context) {
    final livePageAsync = ref.watch(livePageProvider);
    final currentLive = livePageAsync.valueOrNull?.currentLive;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (currentLive != null && !_livePreviewDismissed) ...[
          _LivePreviewThumb(
            title: currentLive.title,
            thumbnail: currentLive.thumbnail,
            viewers: currentLive.viewers,
            // Tap → push the full-screen live room for THIS specific
            // session (not just the /live tab).
            onTap: () =>
                context.push('/live/room/${currentLive.id}'),
            onClose: () =>
                setState(() => _livePreviewDismissed = true),
          ),
          const SizedBox(height: 10),
        ],
        _CSBubble(
          label: l10n.homeFloatingCS,
          onTap: () => context.push('/support'),
        ),
      ],
    );
  }
}

class _LivePreviewThumb extends StatelessWidget {
  const _LivePreviewThumb({
    required this.title,
    required this.thumbnail,
    required this.viewers,
    required this.onTap,
    this.onClose,
  });

  final String title;
  final String thumbnail;
  final int viewers;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnail.isNotEmpty)
                  Image.network(thumbnail, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                            'assets/prototype/live_host.jpg',
                            fit: BoxFit.cover,
                          ))
                else
                  Image.asset(
                    'assets/prototype/live_host.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: BoxDecoration(
                        gradient: appTheme.primaryGradient,
                      ),
                    ),
                  ),
                // LIVE badge
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: appTheme.danger,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Viewer count
                if (viewers > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        viewers > 999
                            ? '${(viewers / 1000).toStringAsFixed(1)}k'
                            : '$viewers',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Bottom gradient + host name
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.fromLTRB(5, 14, 5, 4),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xD9000000),
                        ],
                      ),
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
        ),
        // × close badge — overlaps the top-right corner of the thumb so
        // it's tappable without crowding the LIVE / viewer pills inside.
        if (onClose != null)
          Positioned(
            top: -6,
            right: -6,
            child: Material(
              color: Colors.black.withValues(alpha: 0.7),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 1.2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onClose,
                child: const SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(Icons.close,
                      color: Colors.white, size: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CSBubble extends StatelessWidget {
  const _CSBubble({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: appTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 22,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                AppIcons.comment,
                color: Colors.white,
                size: 22,
              ),
            ),
            // Online green dot
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
