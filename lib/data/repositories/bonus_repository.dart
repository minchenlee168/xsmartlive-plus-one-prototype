import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/bonus.dart';
import '../dio_client.dart';

class BonusRepository {
  BonusRepository(this._dioClient);

  final DioClient _dioClient;

  Future<BonusBalance> fetchBalance() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.bonusBalance);
      return BonusBalance.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<BonusUsage> spend({
    required int purchaseId,
    required int pointUsed,
    String? note,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.bonusSpend,
        data: {
          'purchase_id': purchaseId,
          'point_used': pointUsed,
          if (note != null) 'note': note,
        },
      );
      return BonusUsage.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// GET /bonus/history — merged earning + usage feed, sorted by created_at
  /// desc. All filters optional. Backend caps [pageSize] at 100; we
  /// forward whatever the caller supplied without re-clamping so a 422 from
  /// the server stays loud rather than getting masked.
  Future<List<BonusHistory>> fetchHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? pageSize,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.bonusHistory,
        queryParameters: {
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
          if (pageSize != null) 'page_size': pageSize,
        },
      );
      final body = response.data;
      final list = body is List
          ? body
          : (body is Map<String, dynamic>
              ? (body['data'] as List<dynamic>? ?? const [])
              : const []);
      return list
          .whereType<Map<String, dynamic>>()
          .map(BonusHistory.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }
}
