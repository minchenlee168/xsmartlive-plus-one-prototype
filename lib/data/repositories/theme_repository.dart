import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../theme/remote_theme_model.dart';
import '../dio_client.dart';

class ThemeRepository {
  ThemeRepository(this._dioClient);

  final DioClient _dioClient;

  /// Public endpoint — no auth required.
  Future<RemoteThemeModel> fetchTheme(String merchantId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.theme(merchantId),
        options: Options(headers: {'Authorization': null}),
      );
      return RemoteThemeModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }
}
