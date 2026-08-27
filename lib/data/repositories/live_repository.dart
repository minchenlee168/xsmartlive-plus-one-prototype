import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/live_stream.dart';
import '../../models/mock_data.dart';
import '../dio_client.dart';

class LiveRepository {
  LiveRepository(this._dioClient);

  final DioClient _dioClient;

  /// GET /api/v1/mall/store/{store}/market/live
  /// Returns the first live item from the list, or null if none.
  Future<LiveStream?> fetchCurrentLive({int? pageSize}) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.marketsLive,
        queryParameters: {
          if (pageSize != null) 'page_size': pageSize,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>?) ?? [];
      if (list.isEmpty) {
        return MockData.liveStreams.firstWhere((l) => l.isLive);
      }
      return LiveStream.fromJson(list.first as Map<String, dynamic>);
    } on DioException catch (_) {
      // Fall back to mock data during development.
      return MockData.liveStreams.firstWhere((l) => l.isLive);
    }
  }

  Future<List<LiveStream>> fetchHistoricalLives() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.historicalLives);
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => LiveStream.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return MockData.liveStreams.where((l) => !l.isLive).toList();
    }
  }

  Future<List<LiveComment>> fetchComments(String liveId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.liveComments(liveId));
      final body = response.data as Map<String, dynamic>;
      final list = (body['data'] as List<dynamic>?) ?? [];
      return list
          .map((e) => LiveComment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return MockData.liveComments;
    }
  }
}
