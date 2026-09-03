import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/analytics/screen_view_logger.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/coupons/coupon_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/flash_sale_screen.dart';
import '../screens/live/live_room_screen.dart';
import '../screens/live/live_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/forgot_password_screen.dart';
import '../screens/login/register_screen.dart' show RegisterScreen;
import '../screens/main_shell.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/address_book_screen.dart';
import '../screens/profile/bind_mobile_screen.dart';
import '../screens/profile/bonus_screen.dart';
import '../screens/profile/following_screen.dart';
import '../screens/profile/change_mobile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/third_party_screen.dart';
import '../screens/profile/language_picker_screen.dart';
import '../screens/profile/theme_picker_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/shop/checkout_screen.dart';
import '../screens/shop/shop_screen.dart';
import '../screens/shop/category_screen.dart';
import '../screens/shop/theme_hall_screen.dart';
import '../screens/support/support_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod auth state → GoRouter's refreshListenable.
/// GoRouter is created ONCE; this notifier triggers redirect re-evaluation
/// whenever auth state changes — without rebuilding the entire router.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AsyncValue<dynamic>>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: listenable,
    redirect: (context, state) {
      // Use ref.read — the listenable already triggered the refresh.
      final authValue = ref.read(authNotifierProvider);

      // While loading the persisted session, stay put (no redirect).
      if (authValue.isLoading) return null;

      final isLoggedIn   = authValue.valueOrNull != null;
      final loc          = state.matchedLocation;
      final isAuthRoute  = loc == '/login' || loc == '/register' ||
          loc == '/forgot-password';

      // 預覽（web）跳過登入守衛，直接進內頁瀏覽畫面。
      if (!isLoggedIn && !isAuthRoute) return kIsWeb ? null : '/login';
      if (isLoggedIn  &&  isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ScreenViewLogger(
                onView: (ref) =>
                    ref.read(analyticsServiceProvider).logHomeView(),
                child: const HomeScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/live',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: LiveScreen()),
          ),
          GoRoute(
            path: '/shop',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ShopScreen()),
          ),
          GoRoute(
            path: '/cart',
            pageBuilder: (context, state) => NoTransitionPage(
              child: ScreenViewLogger(
                onView: (ref) => ref
                    .read(analyticsServiceProvider)
                    .logViewCart(ref.read(cartApiProvider).valueOrNull),
                child: const CartScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      // ── Out-of-shell screens (full-screen, no bottom nav) ──
      // Favorites / Notifications used to be tabs, so their bodies have
      // no AppBar of their own. We wrap them in a back-button Scaffold
      // here so the user can return to wherever they came from (typically
      // the Profile menu) without modifying the screen widgets.
      GoRoute(
        path: '/favorites',
        builder: (context, state) => _BackArrowScaffold(
          child: const FavoritesScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => _BackArrowScaffold(
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/coupons',
        builder: (context, state) => const CouponScreen(),
      ),
      GoRoute(
        path: '/bonus',
        builder: (context, state) => const BonusScreen(),
      ),
      GoRoute(
        path: '/following',
        builder: (context, state) => const FollowingScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/shop/category/:id',
        builder: (context, state) =>
            CategoryScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/shop/theme-hall/:index',
        builder: (context, state) => ThemeHallScreen(
          index: int.tryParse(state.pathParameters['index'] ?? '') ?? -1,
        ),
      ),
      GoRoute(
        path: '/flash-sale',
        builder: (context, state) => const FlashSaleScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ScreenViewLogger(
            onView: (ref) =>
                ref.read(analyticsServiceProvider).logViewItem(itemId: id),
            child: ProductDetailScreen(productCardId: id),
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/themes',
        builder: (context, state) => const ThemePickerScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (context, state) => const LanguagePickerScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings/third-party',
        builder: (context, state) => const ThirdPartyScreen(),
      ),
      GoRoute(
        path: '/settings/mobile',
        builder: (context, state) => const ChangeMobileScreen(),
      ),
      // B4: bind mobile flow for accounts that have not bound a number yet.
      GoRoute(
        path: '/settings/bind-mobile',
        builder: (context, state) => const BindMobileScreen(),
      ),
      // B5: change password.
      GoRoute(
        path: '/settings/password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      // 收件地址簿（宅配 / 超商取貨）。
      GoRoute(
        path: '/settings/address',
        builder: (context, state) => const AddressBookScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      // Live room — full-screen route OUTSIDE ShellRoute so the bottom
      // nav is hidden during streaming (immersive viewing).
      GoRoute(
        path: '/live/room/:streamId',
        builder: (context, state) => ScreenViewLogger(
          onView: (ref) => ref
              .read(analyticsServiceProvider)
              .logViewLive(streamId: state.pathParameters['streamId']!),
          child: LiveRoomScreen(
            streamId: state.pathParameters['streamId']!,
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

/// Minimal back-button Scaffold wrapper for screens that ship without their
/// own AppBar (Favorites, Notifications). Stacks an `IconButton(arrow_back)`
/// in the top-left over the screen's body so the route remains poppable
/// even when the user pushed it from the Profile menu.
class _BackArrowScaffold extends StatelessWidget {
  const _BackArrowScaffold({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 8,
            child: Material(
              color: Colors.white.withValues(alpha: 0.85),
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    GoRouter.of(context).go('/home');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
