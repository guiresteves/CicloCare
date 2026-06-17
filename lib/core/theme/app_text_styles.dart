import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.5, height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.25,
  );

  // Títulos
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.35,
  );

  // Corpo
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textHint, letterSpacing: 0.5,
  );

  // Botões
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.white, letterSpacing: 0.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.white, letterSpacing: 0.2,
  );

  // Campos de formulário
  static const TextStyle inputLabel = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  // App Bar
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  // Cards
  static const TextStyle cardTitle = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle cardBadge = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  // Calendário
  static const TextStyle calendarDay = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800,
    color: AppColors.white,
  );

  static const TextStyle calendarLabel = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Bottom Nav
  static const TextStyle bottomNavLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Seção
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: 0.1,
  );

  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}