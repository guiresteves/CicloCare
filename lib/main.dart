import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/terms_screen.dart';
import 'features/auth/screens/privacy_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';

void main() {
  runApp(const CicloCareApp());
}

class CicloCareApp extends StatelessWidget {
  const CicloCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CicloCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboarding,
      routes: {
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.terms: (_) => const TermsScreen(),
        AppRoutes.privacy: (_) => const PrivacyScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
      },
    );
  }
}
