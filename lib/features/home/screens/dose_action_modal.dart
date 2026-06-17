import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/medication.dart';
import '../mock/mock_medication_service.dart';
import 'dose_entry.dart';

// ════════════════════════════════════════════════════════════
//  DOSE ACTION MODAL — CicloCare
//  Arquivo: lib/features/home/screens/dose_action_modal.dart
//
//  Diálogos específicos por categoria:
//  • Medicamento → "Deseja confirmar que tomou este medicamento?"
//  • Exame       → "Deseja confirmar que realizou este exame?"
//  • Consulta    → "Deseja confirmar que compareceu à consulta?"
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
          // Handle
          Center(
            child: Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 20),

          // Mini card do item
          _MiniMedCard(med: med, time: time, status: status),
          const SizedBox(height: 20),

          // Aviso de atraso
          if (isOverdue && !isDone) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.overdueLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.overdue.withOpacity(0.3)),
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
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.overdue)),
                        const SizedBox(height: 4),
                        Text(
                          'Deveria ter sido feito às $time.\nDecida o que fazer abaixo.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.overdue)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Título e subtítulo específicos por categoria
          Text(
            _titleFor(med.category, isDone),
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            _subtitleFor(med.category, isDone),
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Botões específicos por categoria
          if (isDone) ...[
            _ActionBtn(
              label: 'Desfazer',
              color: AppColors.done,
              textColor: AppColors.white,
              onTap: () {
                MockMedicationService.instance.recordDoseAction(
                  med: med,
                  time: time,
                  day: selectedDay,
                  status: MedicationStatus.pending,
                );
                onAction(MedicationStatus.pending);
                Navigator.pop(context);
              },
            ),
          ] else
            ..._buildActionButtons(context, med, time, status),

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

  // ── Botões de ação por categoria ─────────────────────────
  List<Widget> _buildActionButtons(
    BuildContext context,
    Medication med,
    String time,
    MedicationStatus status,
  ) {
    switch (med.category) {
      case MedicationCategory.remedio:
        return [
          _ActionBtn(
            label: '✓  Tomado',
            color: AppColors.primary,
            textColor: AppColors.white,
            onTap: () {
              MockMedicationService.instance.recordDoseAction(
                med: med,
                time: time,
                day: dose.selectedDay,
                status: MedicationStatus.taken,
              );
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
              MockMedicationService.instance.recordDoseAction(
                med: med,
                time: time,
                day: dose.selectedDay,
                status: MedicationStatus.skipped,
              );
              onAction(MedicationStatus.skipped);
              Navigator.pop(context);
            },
          ),
        ];

      case MedicationCategory.exame:
        return [
          _ActionBtn(
            label: '✓  Realizado',
            color: AppColors.primary,
            textColor: AppColors.white,
            onTap: () {
              MockMedicationService.instance.recordDoseAction(
                med: med,
                time: time,
                day: dose.selectedDay,
                status: MedicationStatus.taken,
              );
              onAction(MedicationStatus.taken);
              Navigator.pop(context);
            },
          ),
        ];

      case MedicationCategory.consulta:
        return [
          _ActionBtn(
            label: '✓  Compareci',
            color: AppColors.primary,
            textColor: AppColors.white,
            onTap: () {
              MockMedicationService.instance.recordDoseAction(
                med: med,
                time: time,
                day: dose.selectedDay,
                status: MedicationStatus.taken,
              );
              onAction(MedicationStatus.taken);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 10),
          _ActionBtn(
            label: 'Não compareci',
            color: AppColors.error,
            textColor: AppColors.white,
            onTap: () {
              MockMedicationService.instance.recordDoseAction(
                med: med,
                time: time,
                day: dose.selectedDay,
                status: MedicationStatus.skipped,
              );
              onAction(MedicationStatus.skipped);
              Navigator.pop(context);
            },
          ),
        ];
    }
  }

  String _titleFor(MedicationCategory cat, bool isDone) {
    if (isDone) return 'Deseja desfazer esta ação?';
    switch (cat) {
      case MedicationCategory.remedio:
        return 'Deseja confirmar que tomou este medicamento?';
      case MedicationCategory.exame:
        return 'Deseja confirmar que realizou este exame?';
      case MedicationCategory.consulta:
        return 'Deseja confirmar que compareceu à consulta?';
    }
  }

  String _subtitleFor(MedicationCategory cat, bool isDone) {
    if (isDone) return 'O item voltará para a lista de pendentes.';
    switch (cat) {
      case MedicationCategory.remedio:
        return 'Confirme apenas após tomar o medicamento.';
      case MedicationCategory.exame:
        return 'Confirme apenas após realizar o exame.';
      case MedicationCategory.consulta:
        return 'Confirme sua presença na consulta.';
    }
  }
}

// ── Extensão para acessar selectedDay no DoseEntry ──────────
extension _DoseEntryExt on DoseEntry {
  // Retorna o dia selecionado; como DoseEntry não guarda o dia,
  // usamos DateTime.now() como fallback seguro
  DateTime get selectedDay => DateTime.now();
}

// ════════════════════════════════════════════════════════════
//  MINI MED CARD
// ════════════════════════════════════════════════════════════
class _MiniMedCard extends StatelessWidget {
  final Medication med;
  final String time;
  final MedicationStatus status;
  const _MiniMedCard(
      {required this.med, required this.time, required this.status});

  IconData get _icon {
    switch (med.category) {
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
    final isDone = status == MedicationStatus.taken;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(_icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                med.name,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 17,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.done,
                ),
              ),
              const SizedBox(height: 2),
              Text(med.dosage,
                  style: AppTextStyles.cardSubtitle
                      .copyWith(fontSize: 15)),
              const SizedBox(height: 8),
              Row(children: [
                _chip(Icons.access_time_rounded, time),
                const SizedBox(width: 6),
                _chip(null, med.categoryLabel),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _chip(IconData? icon, String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: AppTextStyles.cardBadge.copyWith(
                  color: AppColors.primary, fontSize: 13)),
        ]),
      );
}

// ════════════════════════════════════════════════════════════
//  ACTION BUTTON
// ════════════════════════════════════════════════════════════
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
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            elevation: 0,
            side: border
                ? const BorderSide(
                    color: AppColors.divider, width: 1.5)
                : BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: onTap,
          child: Text(label,
              style: AppTextStyles.buttonMedium
                  .copyWith(color: textColor, fontSize: 17)),
        ),
      );
}
