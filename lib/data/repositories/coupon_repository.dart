import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/api_constants.dart';
import '../../models/claimable_coupon.dart';
import '../../models/coupon.dart';
import '../../models/member_coupon.dart';
import '../dio_client.dart';

class CouponRepository {
  CouponRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<Coupon>> fetchCoupons({int page = 1}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.coupons,
        queryParameters: {'page': page},
      );
      final list = _extractDataList(response.data);
      return list
          .whereType<Map<String, dynamic>>()
          .map(Coupon.fromJson)
          .toList();
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// 2026-05 spec rev — `GET /coupon/member` now accepts an optional
  /// `expired` (bool|null) filter alongside `used`. Caller passes `expired:
  /// true` to fetch only expired coupons (the dedicated 過期 tab) or `false`
  /// to exclude them; pass `null` to leave the filter off.
  Future<List<MemberCoupon>> fetchMemberCoupons({
    bool? used,
    bool? expired,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.coupons,
        queryParameters: {
          // Backend validator expects 0/1, not bool literals.
          if (used != null) 'used': used ? 1 : 0,
          if (expired != null) 'expired': expired ? 1 : 0,
        },
      );
      return _parseList(response.data, MemberCoupon.fromJson, 'MemberCoupon');
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<List<ClaimableCoupon>> fetchClaimableCoupons() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.couponsClaimable);
      return _parseList(
        response.data,
        ClaimableCoupon.fromJson,
        'ClaimableCoupon',
      );
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<void> claimCoupon(int couponId) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.couponClaim,
        data: {'coupon_id': couponId},
      );
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Extracts the inner array from a backend envelope tolerantly:
  ///   • `[...]`                                 → returns as-is
  ///   • `{ success: true, data: [...] }`        → returns `data`
  ///   • `{ data: { data: [...] } }` (double-wrap per OpenAPI schema)
  ///                                              → returns inner `data`
  /// Anything unrecognised returns an empty list rather than crashing.
  static List<dynamic> _extractDataList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is List) return inner;
      }
    }
    return const [];
  }

  /// Parse a backend envelope into a list of [T], skipping any individual
  /// entry that fails to parse instead of failing the whole list.
  static List<T> _parseList<T>(
    dynamic body,
    T Function(Map<String, dynamic>) fromJson,
    String label,
  ) {
    final list = _extractDataList(body);
    final out = <T>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      try {
        out.add(fromJson(item));
      } catch (e, st) {
        debugPrint('[$label] skip malformed entry: $e\n$st\nitem=$item');
      }
    }
    return out;
  }
}
