import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dio_client.dart';
import '../data/session_service.dart';
import '../data/repositories/address_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/bonus_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/checkout_repository.dart';
import '../data/repositories/combo_repository.dart';
import '../data/repositories/coupon_repository.dart';
import '../data/repositories/live_repository.dart';
import '../data/repositories/market_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/purchase_repository.dart';
import '../data/repositories/theme_repository.dart';
import '../data/theme_cache_storage.dart';
import '../data/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final themeCacheStorageProvider =
    Provider<ThemeCacheStorage>((ref) => ThemeCacheStorage());

final sessionServiceProvider = Provider<SessionService>((ref) {
  final service = SessionService();
  ref.onDispose(service.dispose);
  return service;
});

/// Default in-memory jar. Overridden in main() with a [PersistCookieJar]
/// so the laravel_session cookie survives app restarts.
final cookieJarProvider = Provider<CookieJar>((ref) => CookieJar());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    cookieJar: ref.watch(cookieJarProvider),
    sessionService: ref.watch(sessionServiceProvider),
  );
});

final themeRepositoryProvider = Provider<ThemeRepository>(
  (ref) => ThemeRepository(ref.watch(dioClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(dioClientProvider),
    ref.watch(tokenStorageProvider),
    ref.watch(cookieJarProvider),
  ),
);

final liveRepositoryProvider = Provider<LiveRepository>(
  (ref) => LiveRepository(ref.watch(dioClientProvider)),
);

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(dioClientProvider)),
);

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(dioClientProvider)),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(ref.watch(dioClientProvider)),
);

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => CheckoutRepository(ref.watch(dioClientProvider)),
);

final purchaseRepositoryProvider = Provider<PurchaseRepository>(
  (ref) => PurchaseRepository(ref.watch(dioClientProvider)),
);

final couponRepositoryProvider = Provider<CouponRepository>(
  (ref) => CouponRepository(ref.watch(dioClientProvider)),
);

final bonusRepositoryProvider = Provider<BonusRepository>(
  (ref) => BonusRepository(ref.watch(dioClientProvider)),
);

final comboRepositoryProvider = Provider<ComboRepository>(
  (ref) => ComboRepository(ref.watch(dioClientProvider)),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(dioClientProvider)),
);

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(ref.watch(dioClientProvider)),
);
