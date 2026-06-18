import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/exam.dart';

// ════════════════════════════════════════════════════════════
//  EXAM DOSE CARD
//  Arquivo: lib/features/exams/screens/exam_dose_card.dart
//
//  Card de exame/consulta com o MESMO padrão visual do
//  MedicationDoseCard (lib/features/home/screens/medication_dose_card.dart):
//  • Fontes maiores (mínimo 16px)
//  • Espaçamento generoso
//  • Alto contraste
//  • Área de toque ampla (min 64px de altura)
// ════════════════════════════════════════════════════════════

class ExamDoseCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;

  const ExamDoseCard({
    super.key,
    required this.exam,
    required this.onTap,
  });

  IconData get _categoryIcon => exam.type == ExamType.consultation
      ? Icons.medical_services_rounded
      : Icons.biotech_rounded;

  @override
  Widget build(BuildContext context) {
    final isDone    = exam.status == ExamStatus.completed;
    final isSkipped = exam.status == ExamStatus.cancelled;
    final isOverdue = exam.status == ExamStatus.scheduled && exam.isPast;
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

    final subtitle = exam.doctor.isNotEmpty && exam.location.isNotEmpty
        ? '${exam.doctor} · ${exam.location}'
        : exam.doctor.isNotEmpty
            ? exam.doctor
            : exam.location.isNotEmpty
                ? exam.location
                : exam.typeLabel;

    return Semantics(
      label: '${exam.name}, ${exam.typeLabel}, horário ${exam.time}, '
          'status ${_statusSemantics(isDone, isSkipped, isOverdue)}',
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
                        ? const Icon(Icons.close_rounded,
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
                          exam.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                              exam.time,
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

                    // Médico/local (ou tipo, se ambos vazios)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: 16,
                        color: isDoneOrSkipped
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Badge + status
                    Row(children: [
                      _badge(exam.typeLabel, isDoneOrSkipped),
                      const Spacer(),
                      _statusLabel(isDone, isSkipped, isOverdue),
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

  Widget _statusLabel(bool isDone, bool isSkipped, bool isOverdue) {
    String label;
    Color color;
    if (isDone) {
      label = '✓ Concluído';
      color = AppColors.done;
    } else if (isSkipped) {
      label = '✕ Cancelado';
      color = AppColors.warning;
    } else if (isOverdue) {
      label = '! Atrasado';
      color = AppColors.overdue;
    } else {
      label = 'Agendado';
      color = AppColors.primary;
    }
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
          color: color, fontWeight: FontWeight.w700, fontSize: 14),
    );
  }

  String _statusSemantics(bool isDone, bool isSkipped, bool isOverdue) {
    if (isDone) return 'concluído';
    if (isSkipped) return 'cancelado';
    if (isOverdue) return 'atrasado';
    return 'agendado';
  }
}
