import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../config/api_constants.dart';
import '../core/errors/app_exception.dart';
import 'session_service.dart';

class DioClient {
  DioClient({required CookieJar cookieJar, SessionService? sessionService}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      // dio_cookie_manager 的 CookieManager 在 web 會 assert
      // （"Don't use the manager in Web environments."）——瀏覽器本身管
      // cookie，不需要也不能用它。因此僅在非 web 掛載；web 預覽改由各頁
      // 的範例資料 fallback 呈現內容。
      if (!kIsWeb) CookieManager(cookieJar),
      _SessionInterceptor(sessionService),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  late final Dio _dio;
  Dio get dio => _dio;
}

/// Detects server-side session expiry.
/// The Laravel auth middleware returns HTTP 200 with code 40000 when the
/// session cookie is missing or expired — it does NOT return HTTP 401.
class _SessionInterceptor extends Interceptor {
  _SessionInterceptor(this._sessionService);

  final SessionService? _sessionService;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data case {'code': 40000}) {
      _sessionService?.notifySessionExpired();
    }
    handler.next(response);
  }
}

AppException dioErrorToAppException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkException('Connection timed out');
    case DioExceptionType.badResponse:
      final code = e.response?.statusCode;
      if (code == 401) return const UnauthorizedException();
      return NetworkException(
        e.response?.data?['message'] as String? ?? 'Server error',
        statusCode: code,
      );
    default:
      if (e.error is AppException) return e.error as AppException;
      return UnknownException(e.message ?? 'Unknown error');
  }
}
