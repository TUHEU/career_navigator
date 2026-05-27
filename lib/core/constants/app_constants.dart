// core/constants/app_constants.dart
class AppConstants {
  AppConstants._();
  static const String appName    = 'Career Navigator';
  static const String appVersion = '2.0.0';

  // ── API URL — update this before building for production ──
  static const String baseUrl = 'http://192.168.1.191:5000';
  // static const String baseUrl = 'http://10.0.2.2:5000';    // Android emulator
  // static const String baseUrl = 'http://localhost:5000';    // iOS simulator
  // static const String baseUrl = 'http://YOUR_VPS_IP:5000'; // Production

  static const int    defaultPageSize = 20;
  static const int    maxPageSize     = 50;

  static const String themeModeKey    = 'theme_mode';
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout    = Duration(seconds: 30);

  static const int otpLength         = 6;
  static const int minPasswordLength = 8;
  static const int minSearchLength   = 2;
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register        = '/auth/register';
  static const String verifyEmail     = '/auth/verify-email';
  static const String resendCode      = '/auth/resend-code';
  static const String login           = '/auth/login';
  static const String refresh         = '/auth/refresh';
  static const String forgotPassword  = '/auth/forgot-password';
  static const String resetPassword   = '/auth/reset-password';
  static const String changePassword  = '/auth/change-password';
  static const String deleteAccount   = '/auth/delete-account';

  // Profile
  static const String getProfile      = '/profile/me';
  static const String setupProfile    = '/profile/setup';
  static const String updatePicture   = '/upload/picture';
  static const String updateJobSeeker = '/profile/job-seeker';
  static const String updateMentor    = '/profile/mentor';
  static const String education       = '/profile/education';
  static const String workExperience  = '/profile/work-experience';

  // People
  static const String mentors         = '/mentors';
  static const String users           = '/users';
  static const String requests        = '/requests';
  static const String search          = '/search';

  // Jobs
  static const String jobs            = '/jobs';
  static const String myApplications  = '/jobs/applications/my';

  // Notifications
  static const String notifications         = '/notifications';
  static const String markNotificationsRead = '/notifications/read';

  // Chat
  static const String conversations   = '/chat/conversations';
  static const String messages        = '/chat/messages';

  // AI — proxy through backend (key stays server-side, never in app)
  static const String aiStream        = '/ai/stream';

  // Feedback & Reviews
  static const String feedback        = '/feedback';
  static String mentorReviews(int id) => '/mentors/$id/reviews';

  // Admin
  static const String adminUsers      = '/admin/users';
  static const String adminFeedback   = '/admin/feedback';
  static const String adminJobs       = '/admin/jobs';
  static const String adminStats      = '/admin/stats';
}
