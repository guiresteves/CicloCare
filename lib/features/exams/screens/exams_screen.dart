import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/exam.dart';
import '../mock/mock_exam_service.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late List<Exam> _exams;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _exams = MockExamService.instance.getScheduled();

  // ── Confirmar exclusão ───────────────────────────────────
  void _confirmDelete(Exam exam) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          exam.type == ExamType.consultation
              ? 'Excluir consulta'
              : 'Excluir exame',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Deseja excluir "${exam.name}"?\n\nEsta ação não pode ser desfeita.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              MockExamService.instance.delete(exam.id);
              Navigator.pop(context);
              setState(_load);
            },
            child: const Text('Excluir',
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Exames e Consultas'),
        // Sem botão + no AppBar (removido conforme solicitado)
      ),
      body: _exams.isEmpty ? _buildEmpty() : _buildTimeline(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Agendar', style: AppTextStyles.buttonMedium),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  //  TIMELINE
  Widget _buildTimeline() {
    final grouped = <String, List<Exam>>{};
    for (final e in _exams) {
      grouped.putIfAbsent(e.formattedDate, () => []).add(e);
    }
    final dates = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date = dates[i];
        final items = grouped[date]!;
        final exam0 = items.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i > 0) const SizedBox(height: 24),
            _DateHeader(exam: exam0),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Linha do tempo
                      Column(children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: _typeColor(e.value.type),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: _typeColor(e.value.type)
                                    .withOpacity(0.3),
                                blurRadius: 4),
                            ],
                          ),
                        ),
                        if (e.key < items.length - 1 ||
                            i < dates.length - 1)
                          Container(
                              width: 2,
                              height: 90,
                              color: AppColors.primaryMedium),
                      ]),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _ExamCard(
                          exam: e.value,
                          onTap: () => _showDetail(e.value),
                          onEdit: () => _showEditSheet(e.value),
                          onDelete: () => _confirmDelete(e.value),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }

  Color _typeColor(ExamType type) {
    switch (type) {
      case ExamType.exam:         return AppColors.info;
      case ExamType.consultation: return AppColors.morning;
    }
  }

  //  ESTADO VAZIO
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: const BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.science_outlined,
                  color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Nenhum agendamento',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text('Toque em "Agendar" para\ncadastrar seu próximo exame ou consulta.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  //  DETALHE
  void _showDetail(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamDetailSheet(
        exam: exam,
        onEdit: () {
          Navigator.pop(context);
          _showEditSheet(exam);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(exam);
        },
      ),
    );
  }

  //  ADICIONAR
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExamSheet(onSaved: () => setState(_load)),
    );
  }

  //  EDITAR
  void _showEditSheet(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExamSheet(
        exam: exam,
        onSaved: () => setState(_load),
      ),
    );
  }
}

// ── Date Header ───────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final Exam exam;
  const _DateHeader({required this.exam});

  static const _months = [
    '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];
  static const _weekDays = [
    '', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
  ];

  @override
  Widget build(BuildContext context) {
    final isToday = exam.isToday;
    final isTomorrow =
        exam.scheduledDate.difference(DateTime.now()).inDays == 1;

    String label;
    if (isToday)
      label = 'Hoje';
    else if (isTomorrow)
      label = 'Amanhã';
    else
      label =
          '${_weekDays[exam.scheduledDate.weekday]}, ${exam.scheduledDate.day} de ${_months[exam.scheduledDate.month]}';

    return Row(children: [
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary : AppColors.inputBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(
              color:
                  isToday ? AppColors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            )),
      ),
      const SizedBox(width: 10),
      const Expanded(child: Divider()),
    ]);
  }
}

// ── Exam Card ─────────────────────────────────────────────────────────────────
class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExamCard({
    required this.exam,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _color => exam.type == ExamType.consultation
      ? AppColors.morning
      : AppColors.info;

  IconData get _icon => exam.type == ExamType.consultation
      ? Icons.person_outline_rounded
      : Icons.biotech_rounded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_icon, color: _color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam.name,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(exam.typeLabel,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: _color, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(exam.time,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.textPrimary, fontSize: 15)),
                    const SizedBox(width: 12),
                    if (exam.location.isNotEmpty) ...[
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(exam.location,
                            style: AppTextStyles.bodySmall
                                .copyWith(fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ]),
                  if (exam.doctor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(exam.doctor,
                          style: AppTextStyles.bodySmall
                              .copyWith(fontSize: 14)),
                    ]),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 20),
          ]),

          // ── Botões de ação inline ──────────────────────
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(
                  exam.type == ExamType.consultation
                      ? 'Editar consulta'
                      : 'Editar exame',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary, fontSize: 14),
                ),
              ),
            ),
            Container(width: 1, height: 24, color: AppColors.divider),
            Expanded(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(
                  exam.type == ExamType.consultation
                      ? 'Excluir consulta'
                      : 'Excluir exame',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.error, fontSize: 14),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Exam Detail Sheet ─────────────────────────────────────────────────────────
class _ExamDetailSheet extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExamDetailSheet({
    required this.exam,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isConsultation = exam.type == ExamType.consultation;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
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

          Text(exam.name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(exam.typeLabel,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 20),

          _row(Icons.calendar_today_rounded, 'Data', exam.formattedDate),
          _row(Icons.access_time_rounded, 'Horário', exam.time),
          if (exam.location.isNotEmpty)
            _row(Icons.location_on_outlined, 'Local', exam.location),
          if (exam.doctor.isNotEmpty)
            _row(Icons.person_outline_rounded, 'Médico', exam.doctor),
          if (exam.observations.isNotEmpty)
            _row(Icons.notes_rounded, 'Observações', exam.observations),

          const SizedBox(height: 24),

          // Editar
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(
                isConsultation
                    ? 'Editar consulta'
                    : 'Editar exame',
                style: AppTextStyles.buttonMedium,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Excluir
          SizedBox(
            width: double.infinity, height: 54,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(
                isConsultation
                    ? 'Excluir consulta'
                    : 'Excluir exame',
                style: AppTextStyles.buttonMedium
                    .copyWith(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity, height: 54,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fechar',
                  style: AppTextStyles.buttonMedium
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTextStyles.labelSmall),
            Text(value,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
          ]),
        ),
      ]),
    );
  }
}

// ── Add / Edit Exam Sheet ─────────────────────────────────────────────────────
class _AddExamSheet extends StatefulWidget {
  final Exam? exam;
  final VoidCallback onSaved;
  const _AddExamSheet({this.exam, required this.onSaved});

  @override
  State<_AddExamSheet> createState() => _AddExamSheetState();
}

class _AddExamSheetState extends State<_AddExamSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _docCtrl;
  late TextEditingController _obsCtrl;

  // Tipo simplificado: exam ou consultation
  late ExamType _type;
  late DateTime _date;
  late String _time;
  bool _isSaving = false;

  bool get _isEditing => widget.exam != null;

  @override
  void initState() {
    super.initState();
    final e = widget.exam;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _locCtrl  = TextEditingController(text: e?.location ?? '');
    _docCtrl  = TextEditingController(text: e?.doctor ?? '');
    _obsCtrl  = TextEditingController(text: e?.observations ?? '');
    _type = e?.type ?? ExamType.exam;
    _date = e?.scheduledDate ?? DateTime.now().add(const Duration(days: 1));
    _time = e?.time ?? '07:00';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _docCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe o nome')));
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final exam = Exam(
      id: widget.exam?.id ?? MockExamService.instance.generateId(),
      name: _nameCtrl.text.trim(),
      type: _type,
      scheduledDate: _date,
      time: _time,
      location: _locCtrl.text.trim(),
      doctor: _docCtrl.text.trim(),
      observations: _obsCtrl.text.trim(),
    );

    if (_isEditing) {
      MockExamService.instance.update(exam);
      if (_type == ExamType.consultation) {
        // notificação de reagendamento
        MockExamService.instance.markRescheduled(exam);
      } else {
        MockExamService.instance.markRescheduled(exam);
      }
    } else {
      MockExamService.instance.add(exam);
    }

    widget.onSaved();
    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded,
            color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text(
          _isEditing
              ? (_type == ExamType.consultation
                  ? 'Consulta atualizada!'
                  : 'Exame atualizado!')
              : (_type == ExamType.consultation
                  ? 'Consulta agendada!'
                  : 'Exame agendado!'),
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ]),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _pickDate() {
    DateTime temp = _date;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _cupertinoSheet(
        title: 'Data',
        onConfirm: () {
          setState(() => _date = temp);
          Navigator.pop(ctx);
        },
        ctx: ctx,
        child: SizedBox(
          height: 260,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _date,
            minimumDate: DateTime.now(),
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
      ),
    );
  }

  void _pickTime() {
    final p = _time.split(':');
    var h = int.parse(p[0]), m = int.parse(p[1]);
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _cupertinoSheet(
        title: 'Horário',
        onConfirm: () {
          setState(() => _time =
              '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
          Navigator.pop(ctx);
        },
        ctx: ctx,
        child: SizedBox(
          height: 220,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(hours: h, minutes: m),
            itemExtent: 52,
            onTimerDurationChanged: (d) {
              h = d.inHours;
              m = d.inMinutes % 60;
            },
          ),
        ),
      ),
    );
  }

  Widget _cupertinoSheet({
    required String title,
    required VoidCallback onConfirm,
    required BuildContext ctx,
    required Widget child,
  }) =>
      Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              border:
                  Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar',
                        style: TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 17))),
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
                CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onConfirm,
                    child: const Text('OK',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          child,
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
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

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                ),
                Text(
                  _isEditing ? 'Editar Agendamento' : 'Novo Agendamento',
                  style: AppTextStyles.headlineSmall,
                ),
                TextButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text('Salvar',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Tipo simplificado: Exame | Consulta ──────
            Text('Tipo *', style: AppTextStyles.inputLabel),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: _typeBtn(
                  label: 'Exame',
                  icon: Icons.biotech_rounded,
                  selected: _type == ExamType.exam,
                  onTap: () => setState(() => _type = ExamType.exam),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _typeBtn(
                  label: 'Consulta',
                  icon: Icons.person_outline_rounded,
                  selected: _type == ExamType.consultation,
                  onTap: () =>
                      setState(() => _type = ExamType.consultation),
                ),
              ),
            ]),
            const SizedBox(height: 18),

            // Nome
            Text('Nome *', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.inputText,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: _type == ExamType.consultation
                    ? 'Ex: Cardiologista'
                    : 'Ex: Hemograma Completo',
                prefixIcon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 18),

            // Data e Horário
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data *', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: _pickerField(
                          Icons.calendar_today_rounded, _fmtDate(_date)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Horário *', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickTime,
                      child: _pickerField(
                          Icons.access_time_rounded, _time),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 18),

            // Local
            Text('Local (opcional)', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _locCtrl,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Ex: Clínica Santa Clara',
                prefixIcon: Icon(Icons.location_on_outlined,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 18),

            // Médico
            Text('Médico (opcional)', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _docCtrl,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Ex: Dr. João Silva',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 18),

            // Observações
            Text('Observações (opcional)',
                style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _obsCtrl,
              maxLines: 2,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Ex: Jejum de 8 horas...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 28),
                  child: Icon(Icons.notes_rounded,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: AppColors.primaryMedium,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                    : Text(
                        _isEditing ? 'Salvar alterações' : 'Agendar',
                        style: AppTextStyles.buttonLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBtn({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 72,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.inputBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  selected ? AppColors.primary : AppColors.inputBorder,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? AppColors.white : AppColors.textHint,
                  size: 26),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? AppColors.white
                        : AppColors.textSecondary,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                  )),
            ],
          ),
        ),
      );

  Widget _pickerField(IconData icon, String value) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}
