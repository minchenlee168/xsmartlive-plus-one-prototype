sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Session expired. Please log in again.');
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

/// HTTP 422 + code 10007 from the mall login endpoint. The backend collapses
/// every Turnstile failure mode (token missing / expired / replayed / action
/// mismatch / siteverify down) into this single code. UI must refresh the
/// captcha widget to obtain a new token before retrying.
class CaptchaInvalidException extends AppException {
  const CaptchaInvalidException([super.message = 'Captcha verification failed']);
}
