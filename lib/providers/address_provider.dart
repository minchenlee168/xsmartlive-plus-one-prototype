import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address.dart';
import 'repository_providers.dart';

// ── Home Delivery ───────────────────────────────────────────────────────────

class HomeDeliveryAddressesNotifier
    extends AsyncNotifier<List<HomeDeliveryAddress>> {
  @override
  Future<List<HomeDeliveryAddress>> build() async {
    // Web 預覽無法登入取真實地址簿，回退範例宅配地址。
    if (kIsWeb) return _sampleHomeAddresses;
    return ref.read(addressRepositoryProvider).listHomeDelivery();
  }

  Future<void> refresh() async {
    if (kIsWeb) {
      state = const AsyncData(_sampleHomeAddresses);
      return;
    }
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
    if (kIsWeb) return _sampleStorePickups;
    return ref.read(addressRepositoryProvider).listStorePickup();
  }

  Future<void> refresh() async {
    if (kIsWeb) {
      state = const AsyncData(_sampleStorePickups);
      return;
    }
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

// ── 收件地址 prototype 範例資料（web 預覽 / 未登入 fallback）─────────────
const List<HomeDeliveryAddress> _sampleHomeAddresses = [
  HomeDeliveryAddress(
    id: 1,
    memberId: 1,
    countryId: 1,
    countryName: '台灣',
    recipientName: '王小明',
    recipientPhoneCountryCode: '+886',
    recipientPhone: '912345678',
    postalCode: '110',
    city: '台北市',
    district: '信義區',
    addressLine: '忠孝東路五段 100 號 10 樓',
    fullAddress: '110 台北市信義區忠孝東路五段 100 號 10 樓',
    isDefault: true,
    isSupported: true,
    disabled: false,
    unsupportedReason: '',
  ),
  HomeDeliveryAddress(
    id: 2,
    memberId: 1,
    countryId: 1,
    countryName: '台灣',
    recipientName: '陳美麗',
    recipientPhoneCountryCode: '+886',
    recipientPhone: '922111222',
    postalCode: '806',
    city: '高雄市',
    district: '前鎮區',
    addressLine: '中山路一段 50 號 8 樓',
    fullAddress: '806 高雄市前鎮區中山路一段 50 號 8 樓',
    isDefault: false,
    isSupported: false,
    disabled: false,
    unsupportedReason: '目前不提供配送至此地區',
  ),
];

const List<StorePickupAddress> _sampleStorePickups = [
  StorePickupAddress(
    id: 1,
    memberId: 1,
    countryId: 1,
    countryName: '台灣',
    recipientName: '王小明',
    recipientPhoneCountryCode: '+886',
    recipientPhone: '912345678',
    pickupProvider: '7-11',
    pickupStoreCode: '123456',
    pickupStoreName: '鑫工門市',
    pickupStoreAddress: '台北市大安區復興南路一段 200 號',
    isDefault: true,
    isSupported: true,
    disabled: false,
    unsupportedReason: '',
  ),
  StorePickupAddress(
    id: 2,
    memberId: 1,
    countryId: 1,
    countryName: '台灣',
    recipientName: '王小明',
    recipientPhoneCountryCode: '+886',
    recipientPhone: '912345678',
    pickupProvider: '全家',
    pickupStoreCode: '654321',
    pickupStoreName: '平鎮上海店',
    pickupStoreAddress: '新北市板橋區文化路二段 50 號',
    isDefault: false,
    isSupported: true,
    disabled: false,
    unsupportedReason: '',
  ),
];
