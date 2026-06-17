import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/medication.dart';
import 'dose_entry.dart';

// ════════════════════════════════════════════════════════════
//  DOSE ACTION MODAL
//  Arquivo: lib/features/home/screens/dose_action_modal.dart
// ════════════════════════════════════════════════════════════

class DoseActionModal extends StatelessWidget {
  final DoseEntry dose;
  final DateTime selectedDay;
  final Function(MedicationStatus) onAction;

  const DoseActionModal({
    super.key,
    required this.dose,
    required this.selectedDay,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final Medication med = dose.med;
    final String time    = dose.time;
    final status = med.statusFor(selectedDay, time);
    final isOverdue = status == MedicationStatus.overdue;
    final isDone    = status == MedicationStatus.taken;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 20),

          _MiniMedCard(med: med, time: time, status: status),
          const SizedBox(height: 20),

          if (isOverdue) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.overdueLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.overdue.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_rounded,
                    color: AppColors.overdue, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Atrasado!',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.overdue)),
                        const SizedBox(height: 4),
                        Text(
                          'Deveria ter sido feito às $time.\nDecida o que fazer abaixo.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.overdue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text(
            isDone
                ? 'Deseja desmarcar este item?'
                : 'O que deseja fazer com este item?',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            isDone
                ? 'Ele voltará para a lista de pendentes.'
                : 'Confirme apenas após concluir.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),

          if (isDone) ...[
            _ActionBtn(
              label: 'Desmarcar',
              color: AppColors.done,
              textColor: AppColors.white,
              onTap: () {
                onAction(MedicationStatus.pending);
                Navigator.pop(context);
              },
            ),
          ] else ...[
            _ActionBtn(
              label: '✓  Concluir',
              color: AppColors.primary,
              textColor: AppColors.white,
              onTap: () {
                onAction(MedicationStatus.taken);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _ActionBtn(
              label: 'Pular',
              color: AppColors.warning,
              textColor: AppColors.white,
              onTap: () {
                onAction(MedicationStatus.skipped);
                Navigator.pop(context);
              },
            ),
          ],
          const SizedBox(height: 10),
          _ActionBtn(
            label: 'Cancelar',
            color: AppColors.white,
            textColor: AppColors.textSecondary,
            border: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _MiniMedCard extends StatelessWidget {
  final Medication med;
  final String time;
  final MedicationStatus status;
  const _MiniMedCard({required this.med, required this.time, required this.status});

  IconData get _icon {
    switch (med.category) {
      case MedicationCategory.remedio:  return Icons.medication_rounded;
      case MedicationCategory.exame:    return Icons.biotech_rounded;
      case MedicationCategory.consulta: return Icons.medical_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = status == MedicationStatus.taken;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12)),
            child: Icon(_icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.done,
                  )),
                const SizedBox(height: 2),
                Text(med.dosage, style: AppTextStyles.cardSubtitle),
                const SizedBox(height: 6),
                Row(children: [
                  _chip(Icons.access_time_rounded, time, AppColors.primary),
                  const SizedBox(width: 6),
                  _chip(null, med.categoryLabel, AppColors.primary),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData? icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: AppTextStyles.cardBadge.copyWith(
            color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool border;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          side: border ? const BorderSide(color: AppColors.divider, width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(label,
          style: AppTextStyles.buttonMedium.copyWith(color: textColor)),
      ),
    );
  }
}