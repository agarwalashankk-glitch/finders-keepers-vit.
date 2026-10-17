import 'package:flutter/material.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/main_navigation_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/my_reports_screen.dart';
import '../features/claims/my_claims_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String myReports = '/my-reports';
  static const String myClaims = '/my-claims';
  static const String notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case myReports:
        return MaterialPageRoute(builder: (_) => const MyReportsScreen());
      case myClaims:
        return MaterialPageRoute(builder: (_) => const MyClaimsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
    }
  }
}
