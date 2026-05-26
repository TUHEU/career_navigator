// router/app_router.dart
import 'package:flutter/material.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/sign_in_page.dart';
import '../presentation/screens/auth/registration_page.dart';
import '../presentation/screens/auth/email_verification_page.dart';
import '../presentation/screens/auth/profile_setup_page.dart';
import '../presentation/screens/auth/reset_password_page.dart';
import '../presentation/screens/dashboard/job_seeker_dashboard.dart';
import '../presentation/screens/dashboard/mentor_dashboard.dart';
import '../presentation/screens/dashboard/admin_dashboard.dart';
import '../presentation/screens/questionnaire/questionnaire_screen.dart';
import '../presentation/screens/ai/ai_hub_page.dart';
import '../presentation/screens/jobs/job_listings_page.dart';
import '../presentation/screens/chat/chat_page.dart';
import '../presentation/screens/notifications/notifications_page.dart';
import '../presentation/screens/settings/settings_page.dart';
import '../presentation/screens/settings/about_us_page.dart';
import '../presentation/screens/settings/help_faq_page.dart';
import '../presentation/screens/settings/privacy_policy_page.dart';
import '../presentation/screens/settings/send_feedback_page.dart';
import '../presentation/screens/search/search_page.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String profileSetup = '/profile-setup';
  static const String resetPassword = '/reset-password';
  static const String questionnaire = '/questionnaire';
  static const String dashboardSeeker = '/dashboard/seeker';
  static const String dashboardMentor = '/dashboard/mentor';
  static const String dashboardAdmin = '/dashboard/admin';
  static const String aiHub = '/ai';
  static const String jobs = '/jobs';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String aboutUs = '/settings/about';
  static const String helpFaq = '/settings/help';
  static const String privacyPolicy = '/settings/privacy';
  static const String sendFeedback = '/settings/feedback';
  static const String search = '/search';
}

Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>? ?? {};
  switch (settings.name) {
    case AppRoutes.splash:
      return _fade(const SplashScreen());
    case AppRoutes.signIn:
      return _slide(const SignInPage());
    case AppRoutes.register:
      return _slide(const RegistrationPage());
    case AppRoutes.verifyEmail:
      return _slide(
        EmailVerificationPage(email: args['email'] as String? ?? ''),
      );
    case AppRoutes.profileSetup:
      return _slide(const ProfileSetupPage());
    case AppRoutes.resetPassword:
      return _slide(ResetPasswordPage(email: args['email'] as String? ?? ''));
    case AppRoutes.questionnaire:
      return _slide(const QuestionnaireScreen());
    case AppRoutes.dashboardSeeker:
      return _fade(const JobSeekerDashboard());
    case AppRoutes.dashboardMentor:
      return _fade(const MentorDashboard());
    case AppRoutes.dashboardAdmin:
      return _fade(const AdminDashboard());
    case AppRoutes.aiHub:
      return _slide(const AIHubPage());
    case AppRoutes.jobs:
      return _slide(const JobListingsPage());
    case AppRoutes.chat:
      return _slide(
        ChatPage(
          conversationId: args['conversationId'] as int? ?? 0,
          recipientId: args['recipientId'] as int? ?? 0,
          recipientName: args['recipientName'] as String? ?? 'Unknown',
        ),
      );
    case AppRoutes.notifications:
      return _slide(const NotificationsPage());
    case AppRoutes.settings:
      return _slide(const SettingsPage());
    case AppRoutes.aboutUs:
      return _slide(const AboutUsPage());
    case AppRoutes.helpFaq:
      return _slide(const HelpFaqPage());
    case AppRoutes.privacyPolicy:
      return _slide(const PrivacyPolicyPage());
    case AppRoutes.sendFeedback:
      return _slide(const SendFeedbackPage());
    case AppRoutes.search:
      return _slide(const SearchPage());
    default:
      return _fade(const SplashScreen());
  }
}

PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 250),
  transitionsBuilder:
      (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
);

PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 280),
  transitionsBuilder:
      (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
        child: child,
      ),
);
