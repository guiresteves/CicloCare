import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/medication.dart';
import 'dose_entry.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATION DOSE CARD
//  Arquivo: lib/features/home/screens/medication_dose_card.dart
// ════════════════════════════════════════════════════════════

class MedicationDoseCard extends StatelessWidget {
  final DoseEntry dose; // _DoseEntry
  final DateTime selectedDay;
  final VoidCallback onTap;

  const MedicationDoseCard({
    super.key,
    required this.dose,
    required this.selectedDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Medication med = dose.med;
    final String time    = dose.time;
    final status = med.statusFor(selectedDay, time);

    final isDone    = status == MedicationStatus.taken;
    final isSkipped = status == MedicationStatus.skipped;
    final isOverdue = status == MedicationStatus.overdue;
    final isDoneOrSkipped = isDone || isSkipped;

    final cardBg     = isDone    ? AppColors.doneLight
                     : isSkipped ? AppColors.warningLight
                     : isOverdue ? AppColors.overdueLight
                     :             AppColors.pendingLight;
    final border     = isDone    ? AppColors.doneBorder
                     : isSkipped ? AppColors.warning.withOpacity(0.4)
                     : isOverdue ? AppColors.overdueBorder
                     :             AppColors.pendingBorder;
    final nameColor  = isDoneOrSkipped ? AppColors.done
                     : isOverdue       ? AppColors.overdue
                     :                   AppColors.textPrimary;
    final timeColor  = isDone    ? AppColors.done
                     : isSkipped ? AppColors.warning
                     : isOverdue ? AppColors.overdue
                     :             AppColors.primary;
    final iconBg     = isDone    ? AppColors.done.withOpacity(0.1)
                     : isSkipped ? AppColors.warningLight
                     : isOverdue ? AppColors.overdueLight
                     :             AppColors.white.withOpacity(0.8);
    final iconColor  = isDone    ? AppColors.done
                     : isSkipped ? AppColors.warning
                     : isOverdue ? AppColors.overdue
                     :             AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            // Ícone
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14)),
              child: isDone
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.done, size: 28)
                  : isSkipped
                      ? const Icon(Icons.skip_next_rounded,
                          color: AppColors.warning, size: 28)
                      : Icon(Icons.medication_rounded,
                          color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          med.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: nameColor,
                            decoration: isDoneOrSkipped
                                ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.done,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                      // Horário
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDone    ? AppColors.doneLight
                               : isSkipped ? AppColors.warningLight
                               : isOverdue ? AppColors.overdueLight
                               :             AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: timeColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDoneOrSkipped)
                              Icon(Icons.access_time_rounded,
                                size: 13, color: timeColor),
                            if (!isDoneOrSkipped)
                              const SizedBox(width: 3),
                            Text(time,
                              style: AppTextStyles.cardBadge.copyWith(
                                color: timeColor,
                                decoration: isDoneOrSkipped
                                    ? TextDecoration.lineThrough : null,
                                decorationColor: AppColors.done,
                              )),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(med.dosage,
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: isDoneOrSkipped
                          ? AppColors.textHint : AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _badge(med.frequency, isDoneOrSkipped),
                      const SizedBox(width: 6),
                      _badge(med.type, isDoneOrSkipped),
                      const Spacer(),
                      // Status label
                      _statusLabel(status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, bool faded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: faded ? AppColors.doneLight : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
        style: AppTextStyles.cardBadge.copyWith(
          color: faded ? AppColors.done : AppColors.primary,
          fontSize: 11,
        )),
    );
  }

  Widget _statusLabel(MedicationStatus status) {
    String label;
    Color color;
    switch (status) {
      case MedicationStatus.taken:
        label = '✓ Tomado'; color = AppColors.done;    break;
      case MedicationStatus.skipped:
        label = '↷ Pulado'; color = AppColors.warning;  break;
      case MedicationStatus.overdue:
        label = '! Atrasado'; color = AppColors.overdue; break;
      default:
        label = 'Pendente'; color = AppColors.primary;  break;
    }
    return Text(label,
      style: AppTextStyles.labelSmall.copyWith(
        color: color, fontWeight: FontWeight.w700));
  }
}