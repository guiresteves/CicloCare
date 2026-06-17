import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/medication.dart';
import 'dose_entry.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATION DOSE CARD
//  Arquivo: lib/features/home/screens/medication_dose_card.dart
//
//  Acessibilidade melhorada:
//  • Fontes maiores (mínimo 16px)
//  • Espaçamento generoso
//  • Alto contraste
//  • Área de toque ampla (min 64px de altura)
// ════════════════════════════════════════════════════════════

class MedicationDoseCard extends StatelessWidget {
  final DoseEntry dose;
  final DateTime selectedDay;
  final VoidCallback onTap;

  const MedicationDoseCard({
    super.key,
    required this.dose,
    required this.selectedDay,
    required this.onTap,
  });

  IconData get _categoryIcon {
    switch (dose.med.category) {
      case MedicationCategory.remedio:
        return Icons.medication_rounded;
      case MedicationCategory.exame:
        return Icons.biotech_rounded;
      case MedicationCategory.consulta:
        return Icons.medical_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Medication med = dose.med;
    final String time    = dose.time;
    final status = med.statusFor(selectedDay, time);

    final isDone        = status == MedicationStatus.taken;
    final isSkipped     = status == MedicationStatus.skipped;
    final isOverdue     = status == MedicationStatus.overdue;
    final isDoneOrSkipped = isDone || isSkipped;

    final cardBg    = isDone    ? AppColors.doneLight
                    : isSkipped ? AppColors.warningLight
                    : isOverdue ? AppColors.overdueLight
                    :             AppColors.pendingLight;
    final border    = isDone    ? AppColors.doneBorder
                    : isSkipped ? AppColors.warning.withOpacity(0.4)
                    : isOverdue ? AppColors.overdueBorder
                    :             AppColors.pendingBorder;
    final nameColor = isDoneOrSkipped ? AppColors.done
                    : isOverdue       ? AppColors.overdue
                    :                   AppColors.textPrimary;
    final timeColor = isDone    ? AppColors.done
                    : isSkipped ? AppColors.warning
                    : isOverdue ? AppColors.overdue
                    :             AppColors.primary;
    final iconBg    = isDone    ? AppColors.done.withOpacity(0.12)
                    : isSkipped ? AppColors.warningLight
                    : isOverdue ? AppColors.overdueLight
                    :             AppColors.white.withOpacity(0.9);
    final iconColor = isDone    ? AppColors.done
                    : isSkipped ? AppColors.warning
                    : isOverdue ? AppColors.overdue
                    :             AppColors.primary;

    return Semantics(
      label: '${med.name}, ${med.dosage}, horário $time, '
          'status ${_statusSemantics(status)}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(minHeight: 80),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              // Ícone grande para melhor visualização
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(16)),
                child: isDone
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.done, size: 32)
                    : isSkipped
                        ? const Icon(Icons.skip_next_rounded,
                            color: AppColors.warning, size: 32)
                        : Icon(_categoryIcon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome + horário
                    Row(children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 18,
                            color: nameColor,
                            decoration: isDoneOrSkipped
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.done,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Badge de horário
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDone    ? AppColors.doneLight
                               : isSkipped ? AppColors.warningLight
                               : isOverdue ? AppColors.overdueLight
                               :             AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: timeColor.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDoneOrSkipped) ...[
                              Icon(Icons.access_time_rounded,
                                  size: 15, color: timeColor),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              time,
                              style: AppTextStyles.cardBadge.copyWith(
                                color: timeColor,
                                fontSize: 15,
                                decoration: isDoneOrSkipped
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.done,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),

                    // Dosagem
                    Text(
                      med.dosage,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: 16,
                        color: isDoneOrSkipped
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Badges + status
                    Row(children: [
                      _badge(med.categoryLabel, isDoneOrSkipped),
                      const SizedBox(width: 8),
                      _badge(med.frequency, isDoneOrSkipped),
                      const Spacer(),
                      _statusLabel(status),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, bool faded) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: faded ? AppColors.doneLight : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.cardBadge.copyWith(
            color: faded ? AppColors.done : AppColors.primary,
            fontSize: 13,
          ),
        ),
      );

  Widget _statusLabel(MedicationStatus status) {
    String label;
    Color color;
    switch (status) {
      case MedicationStatus.taken:
        label = '✓ Concluído';
        color = AppColors.done;
        break;
      case MedicationStatus.skipped:
        label = '↷ Pulado';
        color = AppColors.warning;
        break;
      case MedicationStatus.overdue:
        label = '! Atrasado';
        color = AppColors.overdue;
        break;
      default:
        label = 'Pendente';
        color = AppColors.primary;
        break;
    }
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
          color: color, fontWeight: FontWeight.w700, fontSize: 14),
    );
  }

  String _statusSemantics(MedicationStatus s) {
    switch (s) {
      case MedicationStatus.taken:   return 'concluído';
      case MedicationStatus.skipped: return 'pulado';
      case MedicationStatus.overdue: return 'atrasado';
      default:                       return 'pendente';
    }
  }
}