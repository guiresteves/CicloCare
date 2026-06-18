import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/exam.dart';
import '../mock/mock_exam_service.dart';

// ════════════════════════════════════════════════════════════
//  EXAM ACTION MODAL — CicloCare
//  Arquivo: lib/features/exams/screens/exam_action_modal.dart
//
//  Modal de confirmação ao tocar em um ExamDoseCard na Home.
//  Comportamento por status:
//  • scheduled (pendente/atrasado) → confirmar realização ou cancelar
//  • completed                     → botão "Desfazer"
//  • cancelled                     → botão "Desfazer"
// ════════════════════════════════════════════════════════════

class ExamActionModal extends StatelessWidget {
  final Exam exam;
  final VoidCallback onAction;

  const ExamActionModal({
    super.key,
    required this.exam,
    required this.onAction,
  });

  bool get _isConsultation => exam.type == ExamType.consultation;
  bool get _isDone         => exam.status == ExamStatus.completed;
  bool get _isCancelled    => exam.status == ExamStatus.cancelled;
  bool get _isOverdue      => exam.status == ExamStatus.scheduled && exam.isPast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
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
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mini card do exame
          _MiniExamCard(exam: exam),
          const SizedBox(height: 20),

          // Aviso de atraso
          if (_isOverdue && !_isDone && !_isCancelled) ...[
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
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.overdue)),
                        const SizedBox(height: 4),
                        Text(
                          'Estava agendado para ${exam.time}.\nRegistre o que ocorreu abaixo.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.overdue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Título
          Text(
            _titleText,
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),

          // Subtítulo
          Text(
            _subtitleText,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Botões de ação
          ..._buildActions(context),

          const SizedBox(height: 10),
          _ActionBtn(
            label: 'Fechar',
            color: AppColors.white,
            textColor: AppColors.textSecondary,
            border: true,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ── Textos dinâmicos ─────────────────────────────────────

  String get _titleText {
    if (_isDone)      return 'Deseja desfazer a conclusão?';
    if (_isCancelled) return 'Deseja desfazer o cancelamento?';
    return _isConsultation
        ? 'Deseja confirmar que compareceu à consulta?'
        : 'Deseja confirmar que realizou este exame?';
  }

  String get _subtitleText {
    if (_isDone || _isCancelled) {
      return _isConsultation
          ? 'A consulta voltará para a lista de agendamentos.'
          : 'O exame voltará para a lista de agendamentos.';
    }
    return _isConsultation
        ? 'Confirme sua presença na consulta.'
        : 'Confirme apenas após realizar o exame.';
  }

  // ── Botões por estado ────────────────────────────────────

  List<Widget> _buildActions(BuildContext context) {
    // Já concluído ou cancelado → apenas "Desfazer"
    if (_isDone || _isCancelled) {
      return [
        _ActionBtn(
          label: 'Desfazer',
          color: AppColors.primary,
          textColor: AppColors.white,
          onTap: () {
            exam.status = ExamStatus.scheduled;
            MockExamService.instance.update(exam);
            Navigator.pop(context);
            onAction();
          },
        ),
      ];
    }

    // Pendente / atrasado
    if (_isConsultation) {
      return [
        _ActionBtn(
          label: '✓  Compareci',
          color: AppColors.primary,
          textColor: AppColors.white,
          onTap: () {
            MockExamService.instance.markCompleted(exam);
            Navigator.pop(context);
            onAction();
          },
        ),
        const SizedBox(height: 10),
        _ActionBtn(
          label: 'Não compareci',
          color: AppColors.error,
          textColor: AppColors.white,
          onTap: () {
            MockExamService.instance.markNotAttended(exam);
            Navigator.pop(context);
            onAction();
          },
        ),
      ];
    }

    // Exame comum
    return [
      _ActionBtn(
        label: '✓  Realizado',
        color: AppColors.primary,
        textColor: AppColors.white,
        onTap: () {
          MockExamService.instance.markCompleted(exam);
          Navigator.pop(context);
          onAction();
        },
      ),
      const SizedBox(height: 10),
      _ActionBtn(
        label: 'Cancelar exame',
        color: AppColors.error,
        textColor: AppColors.white,
        onTap: () {
          MockExamService.instance.markCancelled(exam);
          Navigator.pop(context);
          onAction();
        },
      ),
    ];
  }
}

// ════════════════════════════════════════════════════════════
//  MINI EXAM CARD
// ════════════════════════════════════════════════════════════
class _MiniExamCard extends StatelessWidget {
  final Exam exam;
  const _MiniExamCard({required this.exam});

  IconData get _icon => exam.type == ExamType.consultation
      ? Icons.medical_services_rounded
      : Icons.biotech_rounded;

  @override
  Widget build(BuildContext context) {
    final isDone = exam.status == ExamStatus.completed;

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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exam.name,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 17,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.done,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                exam.typeLabel,
                style: AppTextStyles.cardSubtitle.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Row(children: [
                _chip(Icons.calendar_today_rounded, exam.formattedDate),
                const SizedBox(width: 6),
                _chip(Icons.access_time_rounded, exam.time),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _chip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.cardBadge
                  .copyWith(color: AppColors.primary, fontSize: 13)),
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
                ? const BorderSide(color: AppColors.divider, width: 1.5)
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
