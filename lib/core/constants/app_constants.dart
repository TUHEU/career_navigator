class AppConstants {
  static const String appName = 'Career Navigator';
  static const String appVersion = '2.0.0';

  // API - Update with your server IP
  static const String baseUrl =
      'http://10.157.22.68:5000'; // For Android emulator
  // static const String baseUrl = 'http://localhost:5000'; // For iOS simulator
  // static const String baseUrl = 'http://YOUR_SERVER_IP:5000'; // For production

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache keys
  static const String themeModeKey = 'theme_mode';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // OTP
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 10;

  // Validation
  static const int minPasswordLength = 6;
  static const int minSearchLength = 2;
}

class ApiEndpoints {
  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendCode = '/auth/resend-code';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String deleteAccount = '/auth/delete-account';

  // ============================================================
  // PROFILE ENDPOINTS
  // ============================================================
  static const String getProfile = '/profile/me';
  static const String setupProfile = '/profile/setup';
  static const String updatePicture = '/profile/picture';
  static const String updateJobSeeker = '/profile/job-seeker';
  static const String updateMentor = '/profile/mentor';

  // ============================================================
  // EDUCATION ENDPOINTS
  // ============================================================
  static const String education = '/profile/education';

  // ============================================================
  // WORK EXPERIENCE ENDPOINTS
  // ============================================================
  static const String workExperience = '/profile/work-experience';

  // ============================================================
  // MENTOR ENDPOINTS
  // ============================================================
  static const String mentors = '/mentors';
  static const String mentorDetail = '/mentors';
  static const String mentorBackground = '/mentors/user';

  // ============================================================
  // MENTOR REQUESTS ENDPOINTS
  // ============================================================
  static const String requests = '/requests';
  static const String respondRequest = '/requests';

  // ============================================================
  // JOB ENDPOINTS
  // ============================================================
  static const String jobs = '/jobs';
  static const String myApplications = '/jobs/applications/my';

  // ============================================================
  // NOTIFICATION ENDPOINTS
  // ============================================================
  static const String notifications = '/notifications';
  static const String markNotificationsRead = '/notifications/read';

  // ============================================================
  // CHAT ENDPOINTS
  // ============================================================
  static const String conversations = '/chat/conversations';
  static const String messages = '/chat/messages';

  // ============================================================
  // SEARCH ENDPOINT
  // ============================================================
  static const String search = '/search';

  // ============================================================
  // FEEDBACK ENDPOINT
  // ============================================================
  static const String feedback = '/feedback';

  // ============================================================
  // ADMIN ENDPOINTS
  // ============================================================
  static const String adminUsers = '/admin/users';
  static const String adminUserStatus = '/admin/users';
  static const String adminFeedback = '/admin/feedback';
  static const String adminFeedbackStatus = '/admin/feedback';

  // ============================================================
  // VIDEO CALL ENDPOINTS
  // ============================================================
  static const String videoStartSession = '/video/start-session';
  static const String videoJoinSession = '/video/join-session';
  static const String videoEndSession = '/video/end-session';
  static const String videoSessions = '/video/sessions';
}
