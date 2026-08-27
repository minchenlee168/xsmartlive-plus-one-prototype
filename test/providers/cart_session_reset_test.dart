import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xsmartlive_plus_one/data/repositories/auth_repository.dart';
import 'package:xsmartlive_plus_one/data/repositories/cart_repository.dart';
import 'package:xsmartlive_plus_one/models/cart_api.dart';
import 'package:xsmartlive_plus_one/models/user.dart';
import 'package:xsmartlive_plus_one/providers/auth_provider.dart';
import 'package:xsmartlive_plus_one/providers/product_provider.dart';
import 'package:xsmartlive_plus_one/providers/repository_providers.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────
// Only the methods the providers-under-test actually call are implemented;
// every other member is forwarded to noSuchMethod (and never invoked here).

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.user);
  final User? user;

  @override
  Future<User?> restoreUser() async => user;

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeCartRepository implements CartRepository {
  _FakeCartRepository(this.cart);
  final CartApi cart;
  int fetchCount = 0;

  @override
  Future<CartApi?> fetchCart() async {
    fetchCount++;
    return cart;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

CartApi _cartWithQuantity(int quantity) => CartApi(
      id: 1,
      skuCount: 1,
      subtotal: 0,
      discount: 0,
      total: 0,
      createdAt: '',
      updatedAt: '',
      items: [
        CartApiItem(
          id: 1,
          cartId: 1,
          quantity: quantity,
          unitPrice: 0,
          product: const CartApiProduct(id: 1, name: 'X'),
          createdAt: '',
          updatedAt: '',
        ),
      ],
    );

/// Boots a container that starts logged-in (memberId 1) with a 3-item server
/// cart already fetched. Returns the container + the cart fake so tests can
/// assert how many times the server cart was (re)fetched.
Future<({ProviderContainer container, _FakeCartRepository cartRepo})>
    _bootLoggedIn() async {
  final cartRepo = _FakeCartRepository(_cartWithQuantity(3));
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        _FakeAuthRepository(const User(memberId: 1, name: 'A')),
      ),
      cartRepositoryProvider.overrideWithValue(cartRepo),
    ],
  );

  // Keep the cart providers subscribed so an auth change actually drives a
  // rebuild (a one-shot read would not).
  container.listen(cartApiProvider, (_, __) {});
  container.listen(cartCountProvider, (_, __) {});

  await container.read(authNotifierProvider.future); // restore → logged in
  await container.read(cartApiProvider.future); // fetch server cart
  return (container: container, cartRepo: cartRepo);
}

void main() {
  test('session 過期 → 購物車數量歸零、不再打 fetchCart', () async {
    final (:container, :cartRepo) = await _bootLoggedIn();
    addTearDown(container.dispose);

    // Precondition: badge shows the logged-in member's cart.
    expect(container.read(cartCountProvider), 3);
    expect(cartRepo.fetchCount, 1);

    // Fire the exact signal the Dio interceptor raises on a 401 / code 40000.
    container.read(sessionServiceProvider).notifySessionExpired();
    await Future<void>.delayed(Duration.zero); // let the stream listener run

    // Auth dropped to logged-out…
    expect(container.read(authNotifierProvider).valueOrNull, isNull);

    // …and the server cart rebuilt to null → badge cleared, with NO extra
    // fetchCart (a logged-out fetch would 401).
    await container.read(cartApiProvider.future);
    expect(container.read(cartApiProvider).valueOrNull, isNull);
    expect(container.read(cartCountProvider), 0);
    expect(cartRepo.fetchCount, 1);
  });

  test('登出 → 購物車數量歸零', () async {
    final (:container, :cartRepo) = await _bootLoggedIn();
    addTearDown(container.dispose);

    expect(container.read(cartCountProvider), 3);

    await container.read(authNotifierProvider.notifier).logout();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authNotifierProvider).valueOrNull, isNull);
    await container.read(cartApiProvider.future);
    expect(container.read(cartCountProvider), 0);
    expect(cartRepo.fetchCount, 1); // no logged-out refetch
  });
}
