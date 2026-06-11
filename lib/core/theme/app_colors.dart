import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  APP COLORS — CicloCare
//  Arquivo: lib/core/theme/app_colors.dart
// ════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── Primária ─────────────────────────────────────────────
  static const Color primary        = Color(0xFF2DA87A);
  static const Color primaryDark    = Color(0xFF1E8A60);
  static const Color primaryLight   = Color(0xFFE8F8F2);
  static const Color primaryMedium  = Color(0xFFB2E8D2);

  // ── Neutros ──────────────────────────────────────────────
  static const Color white          = Color(0xFFFFFFFF);
  static const Color background     = Color(0xFFF8FAFB);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color divider        = Color(0xFFEEF0F3);

  // ── Texto ────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF111827);
  static const Color textSecondary  = Color(0xFF4B5563);
  static const Color textHint       = Color(0xFF9CA3AF);
  static const Color textDisabled   = Color(0xFFD1D5DB);

  // ── Input ────────────────────────────────────────────────
  static const Color inputBg        = Color(0xFFF3F4F6);
  static const Color inputBorder    = Color(0xFFE5E7EB);

  // ── Estados de medicamento ───────────────────────────────
  static const Color pending        = Color(0xFF2DA87A);
  static const Color pendingLight   = Color(0xFFEBFAF3);
  static const Color pendingBorder  = Color(0xFF6FCF97);

  static const Color overdue        = Color(0xFFB94040);
  static const Color overdueLight   = Color(0xFFFFF0F0);
  static const Color overdueBorder  = Color(0xFFE57373);

  static const Color done           = Color(0xFF6B7280);
  static const Color doneLight      = Color(0xFFF3F4F6);
  static const Color doneBorder     = Color(0xFFD1D5DB);

  // ── Semânticas ───────────────────────────────────────────
  static const Color error          = Color(0xFFDC2626);
  static const Color errorLight     = Color(0xFFFEE2E2);
  static const Color warning        = Color(0xFFD97706);
  static const Color warningLight   = Color(0xFFFEF3C7);
  static const Color success        = Color(0xFF059669);
  static const Color successLight   = Color(0xFFD1FAE5);
  static const Color info           = Color(0xFF2563EB);
  static const Color infoLight      = Color(0xFFDBEAFE);

  // ── Períodos do dia ──────────────────────────────────────
  static const Color morning        = Color(0xFFF59E0B);
  static const Color morningLight   = Color(0xFFFEF9EE);
  static const Color afternoon      = Color(0xFF2DA87A);
  static const Color afternoonLight = Color(0xFFEBFAF3);
  static const Color night          = Color(0xFF4F46E5);
  static const Color nightLight     = Color(0xFFEEF2FF);

  // ── Gradientes ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2DA87A), Color(0xFF1E8A60)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2DA87A), Color(0xFF3DBE8B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}