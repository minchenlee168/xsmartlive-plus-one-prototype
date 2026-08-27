import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/combo.dart';
import '../dio_client.dart';

class ComboRepository {
  ComboRepository(this._dioClient);

  final DioClient _dioClient;

  /// GET /store/{store}/combo
  ///
  /// Query params: category_ids[], keyword, order_by (id|created_at),
  /// direction (ASC|DESC|asc|desc)
  Future<List<Combo>> fetchCombos({
    List<int>? categoryIds,
    String? keyword,
    String? orderBy,
    String? direction,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.combos,
        queryParameters: {
          if (categoryIds != null && categoryIds.isNotEmpty)
            'category_ids[]': categoryIds,
          if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
          if (orderBy != null) 'order_by': orderBy,
          if (direction != null) 'direction': direction,
        },
      );
      final list =
          (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return list
          .map((e) => Combo.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  /// GET /store/{store}/combo/{id}
  Future<Combo?> fetchCombo(int id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.combo(id));
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return Combo.fromJson(data);
    } on DioException catch (_) {
      return null;
    }
  }
}
