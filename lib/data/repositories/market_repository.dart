import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/market.dart';
import '../../models/social_post_market.dart';
import '../dio_client.dart';

class MarketRepository {
  MarketRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<Market>> fetchMarkets() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.markets);
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list
          .map((e) => Market.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<Market> fetchMarket(int id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.market(id));
      final body = response.data as Map<String, dynamic>;
      return Market.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// GET /market/groupPost — 社團貼文賣場列表 (B11).
  /// Tolerates either a bare `[...]` or `{ data: [...] }` envelope.
  Future<List<SocialPostMarket>> fetchGroupPostMarkets({int? pageSize}) =>
      _fetchSocialMarkets(ApiConstants.marketGroupPosts, pageSize);

  /// GET /market/fanPagePost — 粉絲團貼文賣場列表 (B11).
  Future<List<SocialPostMarket>> fetchFanPagePostMarkets({int? pageSize}) =>
      _fetchSocialMarkets(ApiConstants.marketFanPagePosts, pageSize);

  Future<List<SocialPostMarket>> _fetchSocialMarkets(
    String url,
    int? pageSize,
  ) async {
    try {
      final response = await _dioClient.dio.get(
        url,
        queryParameters: {
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
          .map(SocialPostMarket.fromJson)
          .toList();
    } on DioException {
      return [];
    }
  }
}
