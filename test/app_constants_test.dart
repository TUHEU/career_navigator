// test/app_constants_test.dart — tests core/constants/app_constants.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('appName set', () => expect(AppConstants.appName, 'Career Navigator'));
    test('baseUrl is http(s)', () {
      expect(AppConstants.baseUrl, startsWith('http'));
      expect(AppConstants.baseUrl, isNotEmpty);
    });
    test('otpLength is 6', () => expect(AppConstants.otpLength, 6));
    test('minPasswordLength is 8', () => expect(AppConstants.minPasswordLength, 8));
    test('page sizes sane', () {
      expect(AppConstants.defaultPageSize, greaterThan(0));
      expect(AppConstants.maxPageSize, greaterThanOrEqualTo(AppConstants.defaultPageSize));
    });
    test('timeouts positive', () {
      expect(AppConstants.connectionTimeout.inSeconds, greaterThan(0));
      expect(AppConstants.receiveTimeout.inSeconds, greaterThan(0));
    });
  });

  group('ApiEndpoints', () {
    test('auth endpoints start with /auth', () {
      expect(ApiEndpoints.login, startsWith('/auth'));
      expect(ApiEndpoints.register, startsWith('/auth'));
      expect(ApiEndpoints.verifyEmail, startsWith('/auth'));
      expect(ApiEndpoints.forgotPassword, startsWith('/auth'));
    });
  });
}
