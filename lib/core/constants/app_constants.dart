class AppConstants {
  static const String appName = 'Career Navigator';
  static const String appVersion = '2.0.0';

  // API - Update with your server IP
  static const String baseUrl = 'http://10.0.2.2:5000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:5000'; // For iOS simulator
  // static const String baseUrl = 'http://YOUR_SERVER_IP:5000'; // For production

  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  static const String themeModeKey = 'theme_mode';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int otpLength = 6;
  static const int minPasswordLength = 6;
  static const int minSearchLength = 2;
}

class ApiEndpoints {
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendCode = '/auth/resend-code';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String deleteAccount = '/auth/delete-account';

  static const String getProfile = '/profile/me';
  static const String setupProfile = '/profile/setup';
  static const String updatePicture = '/profile/picture';
  static const String updateJobSeeker = '/profile/job-seeker';
  static const String updateMentor = '/profile/mentor';

  static const String education = '/profile/education';
  static const String workExperience = '/profile/work-experience';

  static const String mentors = '/mentors';
  static const String requests = '/requests';

  static const String jobs = '/jobs';
  static const String myApplications = '/jobs/applications/my';

  static const String notifications = '/notifications';
  static const String markNotificationsRead = '/notifications/read';

  static const String conversations = '/chat/conversations';
  static const String messages = '/chat/messages';

  static const String search = '/search';
  static const String feedback = '/feedback';

  static const String adminUsers = '/admin/users';
  static const String adminFeedback = '/admin/feedback';
}
