import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/address.dart';
import '../dio_client.dart';

/// Wraps the address-management endpoint families:
///   - `/address/homeDelivery/*` (home delivery addresses)
///   - `/address/storePickup/*` (store pickup addresses)
class AddressRepository {
  AddressRepository(this._dioClient);

  final DioClient _dioClient;

  // ── Home Delivery ─────────────────────────────────────────────────────────

  Future<List<HomeDeliveryAddress>> listHomeDelivery() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.homeDeliveryAddresses);
      return _parseList(response.data, HomeDeliveryAddress.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<HomeDeliveryAddress> createHomeDelivery({
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
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.homeDeliveryAddresses,
        data: {
          'recipient_name': recipientName,
          'recipient_phone_country_code': recipientPhoneCountryCode,
          'recipient_phone': recipientPhone,
          'country_id': countryId,
          'city': city,
          'district': district,
          'address_line': addressLine,
          if (postalCode != null) 'postal_code': postalCode,
          if (isDefault != null) 'is_default': isDefault,
        },
      );
      return _parseOne(response.data, HomeDeliveryAddress.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<void> destroyHomeDelivery(int id) async {
    try {
      await _dioClient.dio.post(ApiConstants.homeDeliveryDestroy(id));
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<void> setDefaultHomeDelivery(int id) async {
    try {
      await _dioClient.dio.post(ApiConstants.homeDeliveryDefault(id));
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<List<AddressCountry>> listHomeDeliveryCountries() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.homeDeliveryCountries);
      return _parseList(response.data, AddressCountry.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Store Pickup ──────────────────────────────────────────────────────────

  Future<List<StorePickupAddress>> listStorePickup() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.storePickupAddresses);
      return _parseList(response.data, StorePickupAddress.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<StorePickupAddress> createStorePickup({
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
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.storePickupAddresses,
        data: {
          'recipient_name': recipientName,
          'recipient_phone_country_code': recipientPhoneCountryCode,
          'recipient_phone': recipientPhone,
          'country_id': countryId,
          'pickup_provider': pickupProvider,
          'pickup_store_code': pickupStoreCode,
          'pickup_store_name': pickupStoreName,
          'pickup_store_address': pickupStoreAddress,
          if (isDefault != null) 'is_default': isDefault,
        },
      );
      return _parseOne(response.data, StorePickupAddress.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<void> destroyStorePickup(int id) async {
    try {
      await _dioClient.dio.post(ApiConstants.storePickupDestroy(id));
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<void> setDefaultStorePickup(int id) async {
    try {
      await _dioClient.dio.post(ApiConstants.storePickupDefault(id));
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<List<AddressCountry>> listStorePickupCountries() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.storePickupCountries);
      return _parseList(response.data, AddressCountry.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<List<StorePickupMethod>> listStorePickupMethods() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.storePickupMethods);
      return _parseList(response.data, StorePickupMethod.fromJson);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<T> _parseList<T>(
    dynamic body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = body is Map<String, dynamic>
        ? (body['data'] ?? body)
        : body;
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }

  T _parseOne<T>(
    dynamic body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (body is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        message: 'Invalid address response',
      );
    }
    final data = body['data'] ?? body;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        message: 'Invalid address response',
      );
    }
    return fromJson(data);
  }
}
