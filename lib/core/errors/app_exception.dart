// core/errors/app_exception.dart
// Typed exceptions used across the app instead of raw Exception('string').
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.msg = 'Network error. Check your connection.']);
}

class AuthException extends AppException {
  const AuthException([super.msg = 'Authentication required.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.msg, {this.statusCode});
}

class NotFoundException extends AppException {
  const NotFoundException([super.msg = 'Resource not found.']);
}

class ValidationException extends AppException {
  const ValidationException(super.msg);
}
