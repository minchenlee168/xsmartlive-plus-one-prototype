// Models for the new `/address/homeDelivery/*` and `/address/storePickup/*`
// endpoint families introduced in the 2026-04 API spec. Plain Dart classes
// (no Freezed) to match the existing MemberCoupon / ClaimableCoupon
// snake-case-tolerant pattern.

class HomeDeliveryAddress {
  const HomeDeliveryAddress({
    required this.id,
    required this.memberId,
    required this.countryId,
    required this.countryName,
    required this.recipientName,
    required this.recipientPhoneCountryCode,
    required this.recipientPhone,
    required this.postalCode,
    required this.city,
    required this.district,
    required this.addressLine,
    required this.fullAddress,
    required this.isDefault,
    required this.isSupported,
    required this.disabled,
    required this.unsupportedReason,
  });

  final int id;
  final int memberId;
  final int countryId;
  final String countryName;
  final String recipientName;
  final String recipientPhoneCountryCode;
  final String recipientPhone;
  final String postalCode;
  final String city;
  final String district;
  final String addressLine;
  final String fullAddress;
  final bool isDefault;
  final bool isSupported;
  final bool disabled;
  final String unsupportedReason;

  factory HomeDeliveryAddress.fromJson(Map<String, dynamic> json) =>
      HomeDeliveryAddress(
        id: (json['id'] as num).toInt(),
        memberId: (json['member_id'] as num?)?.toInt() ?? 0,
        countryId: (json['country_id'] as num?)?.toInt() ?? 0,
        countryName: json['country_name'] as String? ?? '',
        recipientName: json['recipient_name'] as String? ?? '',
        recipientPhoneCountryCode:
            json['recipient_phone_country_code'] as String? ?? '',
        recipientPhone: json['recipient_phone'] as String? ?? '',
        postalCode: json['postal_code'] as String? ?? '',
        city: json['city'] as String? ?? '',
        district: json['district'] as String? ?? '',
        addressLine: json['address_line'] as String? ?? '',
        fullAddress: json['full_address'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
        isSupported: json['is_supported'] as bool? ?? true,
        disabled: json['disabled'] as bool? ?? false,
        unsupportedReason: json['unsupported_reason'] as String? ?? '',
      );

  /// Returns the recipient's phone in E.164 form.
  String get fullRecipientPhone {
    final code = recipientPhoneCountryCode.trim();
    final phone = recipientPhone.trim();
    if (code.isEmpty) return phone;
    final normalisedCode = code.startsWith('+') ? code : '+$code';
    return '$normalisedCode$phone';
  }
}

class StorePickupAddress {
  const StorePickupAddress({
    required this.id,
    required this.memberId,
    required this.countryId,
    required this.countryName,
    required this.recipientName,
    required this.recipientPhoneCountryCode,
    required this.recipientPhone,
    required this.pickupProvider,
    required this.pickupStoreCode,
    required this.pickupStoreName,
    required this.pickupStoreAddress,
    required this.isDefault,
    required this.isSupported,
    required this.disabled,
    required this.unsupportedReason,
    this.matched = true,
    this.storeSyncStatus = 'not_applicable',
    this.storeSnapshot,
    this.warningMessage,
  });

  final int id;
  final int memberId;
  final int countryId;
  final String countryName;
  final String recipientName;
  final String recipientPhoneCountryCode;
  final String recipientPhone;
  final String pickupProvider;
  final String pickupStoreCode;
  final String pickupStoreName;
  final String pickupStoreAddress;
  final bool isDefault;
  final bool isSupported;
  final bool disabled;
  final String unsupportedReason;

  /// 2026-05 spec rev — whether this saved address is bit-exact to the
  /// current master store row. `false` when the merchant edited the
  /// underlying store snapshot (renamed, moved, etc.) after the buyer
  /// saved it.
  final bool matched;

  /// 2026-05 spec rev — master-store sync state:
  /// `ready` / `not_synced` / `not_found` / `not_applicable`.
  final String storeSyncStatus;

  /// 2026-05 spec rev — frozen normalised store JSON when the master row
  /// has drifted from what the buyer originally saved. Surface alongside
  /// [warningMessage] so the customer can confirm whether to keep using
  /// this address.
  final String? storeSnapshot;

  /// 2026-05 spec rev — checkout-blocking warning when the saved address
  /// can no longer be shipped to (e.g. store decommissioned). `null` when
  /// the address is fine.
  final String? warningMessage;

  factory StorePickupAddress.fromJson(Map<String, dynamic> json) =>
      StorePickupAddress(
        id: (json['id'] as num).toInt(),
        memberId: (json['member_id'] as num?)?.toInt() ?? 0,
        countryId: (json['country_id'] as num?)?.toInt() ?? 0,
        countryName: json['country_name'] as String? ?? '',
        recipientName: json['recipient_name'] as String? ?? '',
        recipientPhoneCountryCode:
            json['recipient_phone_country_code'] as String? ?? '',
        recipientPhone: json['recipient_phone'] as String? ?? '',
        pickupProvider: json['pickup_provider'] as String? ?? '',
        pickupStoreCode: json['pickup_store_code'] as String? ?? '',
        pickupStoreName: json['pickup_store_name'] as String? ?? '',
        pickupStoreAddress: json['pickup_store_address'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
        isSupported: json['is_supported'] as bool? ?? true,
        disabled: json['disabled'] as bool? ?? false,
        unsupportedReason: json['unsupported_reason'] as String? ?? '',
        matched: json['matched'] as bool? ?? true,
        storeSyncStatus:
            json['store_sync_status'] as String? ?? 'not_applicable',
        storeSnapshot: json['store_snapshot'] as String?,
        warningMessage: json['warning_message'] as String?,
      );

  String get fullRecipientPhone {
    final code = recipientPhoneCountryCode.trim();
    final phone = recipientPhone.trim();
    if (code.isEmpty) return phone;
    final normalisedCode = code.startsWith('+') ? code : '+$code';
    return '$normalisedCode$phone';
  }
}

class AddressCountry {
  const AddressCountry({
    required this.countryId,
    required this.countryCode,
    required this.countryName,
  });

  final int countryId;
  final String countryCode;
  final String countryName;

  factory AddressCountry.fromJson(Map<String, dynamic> json) => AddressCountry(
        countryId: (json['country_id'] as num).toInt(),
        countryCode: json['country_code'] as String? ?? '',
        countryName: json['country_name'] as String? ?? '',
      );
}

class StorePickupMethod {
  const StorePickupMethod({
    required this.brand,
    required this.typeLabel,
    required this.shippingMethodDisplayName,
  });

  /// 2026-05 spec rev: backend now exposes the brand label only
  /// (e.g. "7-11", "全家") instead of the underlying provider IDs.
  final String brand;
  final String typeLabel;
  final String shippingMethodDisplayName;

  factory StorePickupMethod.fromJson(Map<String, dynamic> json) =>
      StorePickupMethod(
        brand: json['brand'] as String? ?? '',
        typeLabel: json['type_label'] as String? ?? '',
        shippingMethodDisplayName:
            json['shipping_method_display_name'] as String? ?? '',
      );
}

// ── New endpoint /cart/checkout/shippingOptions (2026-05) ────────────────────
//
// Returns the *top-level* delivery types the store currently supports
// (home / pickup) plus, for pickup, the list of brands the merchant has
// activated (e.g. 7-11, 全家). Replaces the old "store_shipping_method"
// list so the customer never sees the underlying provider codes.

class CartDeliveryType {
  const CartDeliveryType({
    required this.code,
    required this.label,
    required this.available,
    required this.brands,
  });

  /// `home` = 宅配, `pickup` = 超商取貨.
  final String code;
  final String label;
  final bool available;

  /// Pickup-only — list of brand display labels (e.g. ["7-11", "全家"]).
  /// Empty for `home`.
  final List<String> brands;

  factory CartDeliveryType.fromJson(Map<String, dynamic> json) =>
      CartDeliveryType(
        code: json['code'] as String? ?? '',
        label: json['label'] as String? ?? '',
        available: json['available'] as bool? ?? false,
        brands: (json['brands'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(growable: false),
      );
}
