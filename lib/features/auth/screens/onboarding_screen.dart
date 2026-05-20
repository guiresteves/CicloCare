import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../widgets/auth_button.dart';
import '../widgets/ciclocare_logo.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              const CicloCareLogo(size: 110),

              const SizedBox(height: 32),

              // Título
              const Text(
                'CicloCare',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtítulo
              const Text(
                'Cuide da sua saúde de forma simples\ne inteligente, onde estiver.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 3),

              // Botão Começar
              AuthButton(
                text: 'Começar',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
