import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/banner.dart';
import '../../models/search_keyword.dart';
import '../../models/store_collection.dart';
import '../../models/store_marquee.dart';
import '../../models/stream_board_item.dart';
import '../dio_client.dart';

class ContentRepository {
  ContentRepository(this._dioClient);

  final DioClient _dioClient;

  Future<List<StoreBanner>> fetchStoreBanners() async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.bannerList);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) return [];
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => StoreBanner.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  Future<List<StreamBoardItem>> fetchStreamBoards() async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.streamBoardList);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) return [];
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => StreamBoardItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  /// 2026-05 spec rev — `storeMarquee/list` now returns at most a single
  /// active marquee shaped as `{ data: StoreMarqueeResource } | null`
  /// (previously `[StoreMarquee...]`). Caller still receives a list so the
  /// UI ListView wiring doesn't change; emit 0 or 1 entries.
  Future<List<StoreMarquee>> fetchStoreMarquees() async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.storeMarqueeList);
      final body = response.data;
      if (body is! Map<String, dynamic>) return const [];
      if (body['success'] == false) return const [];
      final data = body['data'];
      if (data == null) return const [];
      // New shape: single object.
      if (data is Map<String, dynamic>) {
        return [StoreMarquee.fromJson(data)];
      }
      // Legacy shape: array of objects.
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(StoreMarquee.fromJson)
            .toList(growable: false);
      }
      return const [];
    } on DioException {
      return const [];
    }
  }

  Future<List<SearchKeyword>> fetchKeywords() async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.keywordList);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) return [];
      final data = body['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => SearchKeyword.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  // ── Store Collection (主題館 — B8) ───────────────────────────────────────

  /// POST /storeCollection/list — list active themed catalogues for the store.
  /// Backend declares the response as a bare `array of items: []` so accept
  /// either `{ data: [...] }` or `[...]` and skip non-map entries safely.
  Future<List<StoreCollection>> fetchStoreCollections() async {
    try {
      final response =
          await _dioClient.dio.post(ApiConstants.storeCollections);
      final body = response.data;
      final list = _extractList(body);
      return list
          .whereType<Map<String, dynamic>>()
          .map(StoreCollection.fromJson)
          .toList();
    } on DioException {
      return [];
    }
  }

  /// GET /storeCollection/{id} — items inside a specific 主題館.
  /// Returns the raw list (model is intentionally lenient — caller can
  /// re-shape into ProductCard later). Useful for the detail page.
  Future<List<Map<String, dynamic>>> fetchStoreCollectionItems(int id) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.storeCollection(id));
      final body = response.data;
      final list = _extractList(body);
      return list.whereType<Map<String, dynamic>>().toList();
    } on DioException {
      return [];
    }
  }

  /// Common envelope unwrap — returns the inner list whether the backend
  /// answered with `[...]`, `{ data: [...] }`, or `{ success: true, data: [...] }`.
  List<dynamic> _extractList(dynamic body) {
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) return const [];
      final data = body['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        if (inner is List) return inner;
      }
    }
    return const [];
  }
}
