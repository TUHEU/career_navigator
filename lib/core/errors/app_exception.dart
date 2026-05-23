// core/errors/app_exception.dart
// Typed exceptions used across the app instead of raw Exception('string').
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}
class NetworkException extends AppException {
  const NetworkException([String msg = 'Network error. Check your connection.']) : super(msg);
}
class AuthException extends AppException {
  const AuthException([String msg = 'Authentication required.']) : super(msg);
}
class ServerException extends AppException {
  final int? statusCode;
  const ServerException(String msg, {this.statusCode}) : super(msg);
}
class NotFoundException extends AppException {
  const NotFoundException([String msg = 'Resource not found.']) : super(msg);
}
class ValidationException extends AppException {
  const ValidationException(String msg) : super(msg);
}
