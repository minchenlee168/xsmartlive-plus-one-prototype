import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';
import 'repository_providers.dart';

// ── Home Delivery ───────────────────────────────────────────────────────────

class HomeDeliveryAddressesNotifier
    extends AsyncNotifier<List<HomeDeliveryAddress>> {
  @override
  Future<List<HomeDeliveryAddress>> build() async {
    return ref.read(addressRepositoryProvider).listHomeDelivery();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(addressRepositoryProvider).listHomeDelivery(),
    );
  }

  Future<HomeDeliveryAddress> create({
    required String recipientName,
    required String recipientPhoneCountryCode,
    required String recipientPhone,
    required int countryId,
    required String city,
    required String district,
    required String addressLine,
    String? postalCode,
    bool? isDefault,
  }) async {
    final created = await ref.read(addressRepositoryProvider).createHomeDelivery(
          recipientName: recipientName,
          recipientPhoneCountryCode: recipientPhoneCountryCode,
          recipientPhone: recipientPhone,
          countryId: countryId,
          city: city,
          district: district,
          addressLine: addressLine,
          postalCode: postalCode,
          isDefault: isDefault,
        );
    await refresh();
    return created;
  }

  Future<void> destroy(int id) async {
    await ref.read(addressRepositoryProvider).destroyHomeDelivery(id);
    await refresh();
  }

  Future<void> setDefault(int id) async {
    await ref.read(addressRepositoryProvider).setDefaultHomeDelivery(id);
    await refresh();
  }
}

final homeDeliveryAddressesProvider = AsyncNotifierProvider<
    HomeDeliveryAddressesNotifier, List<HomeDeliveryAddress>>(
  HomeDeliveryAddressesNotifier.new,
);

/// 從 home delivery 清單挑出預設地址；若無 `is_default=true` 的項目，
/// fallback 到清單第一筆，再無則回傳 null。供 checkout 預先帶 recipient 使用。
final defaultHomeDeliveryAddressProvider = Provider<HomeDeliveryAddress?>((ref) {
  final list = ref.watch(homeDeliveryAddressesProvider).valueOrNull;
  if (list == null || list.isEmpty) return null;
  for (final a in list) {
    if (a.isDefault) return a;
  }
  return list.first;
});

final homeDeliveryCountriesProvider =
    FutureProvider<List<AddressCountry>>((ref) {
  return ref.read(addressRepositoryProvider).listHomeDeliveryCountries();
});

// ── Store Pickup ────────────────────────────────────────────────────────────

class StorePickupAddressesNotifier
    extends AsyncNotifier<List<StorePickupAddress>> {
  @override
  Future<List<StorePickupAddress>> build() async {
    return ref.read(addressRepositoryProvider).listStorePickup();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(addressRepositoryProvider).listStorePickup(),
    );
  }

  Future<StorePickupAddress> create({
    required String recipientName,
    required String recipientPhoneCountryCode,
    required String recipientPhone,
    required int countryId,
    required String pickupProvider,
    required String pickupStoreCode,
    required String pickupStoreName,
    required String pickupStoreAddress,
    bool? isDefault,
  }) async {
    final created = await ref.read(addressRepositoryProvider).createStorePickup(
          recipientName: recipientName,
          recipientPhoneCountryCode: recipientPhoneCountryCode,
          recipientPhone: recipientPhone,
          countryId: countryId,
          pickupProvider: pickupProvider,
          pickupStoreCode: pickupStoreCode,
          pickupStoreName: pickupStoreName,
          pickupStoreAddress: pickupStoreAddress,
          isDefault: isDefault,
        );
    await refresh();
    return created;
  }

  Future<void> destroy(int id) async {
    await ref.read(addressRepositoryProvider).destroyStorePickup(id);
    await refresh();
  }

  Future<void> setDefault(int id) async {
    await ref.read(addressRepositoryProvider).setDefaultStorePickup(id);
    await refresh();
  }
}

final storePickupAddressesProvider = AsyncNotifierProvider<
    StorePickupAddressesNotifier, List<StorePickupAddress>>(
  StorePickupAddressesNotifier.new,
);

final storePickupCountriesProvider =
    FutureProvider<List<AddressCountry>>((ref) {
  return ref.read(addressRepositoryProvider).listStorePickupCountries();
});

/// Default store pickup address — same fallback logic as the home variant.
final defaultStorePickupAddressProvider = Provider<StorePickupAddress?>((ref) {
  final list = ref.watch(storePickupAddressesProvider).valueOrNull;
  if (list == null || list.isEmpty) return null;
  for (final a in list) {
    if (a.isDefault) return a;
  }
  return list.first;
});

final storePickupMethodsProvider =
    FutureProvider<List<StorePickupMethod>>((ref) {
  return ref.read(addressRepositoryProvider).listStorePickupMethods();
});
