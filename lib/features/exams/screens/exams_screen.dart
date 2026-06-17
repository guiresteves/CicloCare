import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/exam.dart';
import '../mock/mock_exam_service.dart';

// ════════════════════════════════════════════════════════════
//  EXAMS SCREEN — CicloCare
//  Arquivo: lib/features/exams/screens/exams_screen.dart
//
//  Alteração 4:
//  • Exibe SOMENTE exames agendados (não concluídos)
//  • Sem medicamentos
//  • Timeline moderna com agrupamento por data
//  • Cadastro com campos: nome, tipo, data, horário,
//    local, médico, observações
//  • Cards com destaque em data/horário
// ════════════════════════════════════════════════════════════

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

  void _load() {
    _exams = MockExamService.instance.getScheduled();
  }

  void _confirmCancel(Exam exam) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar exame',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: Text(
          'Deseja cancelar "${exam.name}"?',
          style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              exam.status = ExamStatus.cancelled;
              MockExamService.instance.update(exam);
              Navigator.pop(context);
              setState(_load);
            },
            child: const Text('Cancelar exame',
              style: TextStyle(color: Colors.white, fontSize: 15))),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
              color: AppColors.primary, size: 26),
            onPressed: _showAddSheet,
            tooltip: 'Agendar exame',
          ),
        ],
      ),
      body: _exams.isEmpty
          ? _buildEmpty()
          : _buildTimeline(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Agendar', style: AppTextStyles.buttonMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TIMELINE
  // ════════════════════════════════════════════════════════
  Widget _buildTimeline() {
    // Agrupa por data
    final grouped = <String, List<Exam>>{};
    for (final e in _exams) {
      grouped.putIfAbsent(e.formattedDate, () => []).add(e);
    }
    final dates = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date  = dates[i];
        final items = grouped[date]!;
        final exam0 = items.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (i > 0) const SizedBox(height: 24),

            // ── Cabeçalho de data ────────────────────────
            _DateHeader(exam: exam0),
            const SizedBox(height: 12),

            // ── Cards do dia ─────────────────────────────
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
                        border: Border.all(color: AppColors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _typeColor(e.value.type).withOpacity(0.3),
                            blurRadius: 4),
                        ],
                      ),
                    ),
                    if (e.key < items.length - 1 || i < dates.length - 1)
                      Container(
                        width: 2,
                        height: 80,
                        color: AppColors.primaryMedium),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ExamCard(
                      exam: e.value,
                      onTap: () => _showDetail(e.value),
                      onCancel: () => _confirmCancel(e.value),
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
      case ExamType.laboratorial:  return AppColors.info;
      case ExamType.imaging:       return AppColors.night;
      case ExamType.clinical:      return AppColors.primary;
      case ExamType.consultation:  return AppColors.morning;
    }
  }

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
                color: AppColors.primaryLight,
                shape: BoxShape.circle),
              child: const Icon(Icons.science_outlined,
                color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            Text('Nenhum exame agendado',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text('Toque em "Agendar" para\ncadastrar seu próximo exame.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DETALHE DO EXAME
  // ════════════════════════════════════════════════════════
  void _showDetail(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamDetailSheet(
        exam: exam,
        onMarkDone: () {
          exam.status = ExamStatus.completed;
          MockExamService.instance.update(exam);
          setState(_load);
        },
        onCancel: () => _confirmCancel(exam),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  ADICIONAR EXAME
  // ════════════════════════════════════════════════════════
  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExamSheet(
        onSaved: () => setState(_load),
      ),
    );
  }
}

// ── Date Header ───────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final Exam exam;
  const _DateHeader({required this.exam});

  static const _months   = ['','Jan','Fev','Mar','Abr','Mai','Jun',
                             'Jul','Ago','Set','Out','Nov','Dez'];
  static const _weekDays = ['','Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];

  @override
  Widget build(BuildContext context) {
    final isToday    = exam.isToday;
    final isTomorrow = exam.scheduledDate.difference(DateTime.now()).inDays == 1;

    String label;
    if (isToday)         label = 'Hoje';
    else if (isTomorrow) label = 'Amanhã';
    else label = '${_weekDays[exam.scheduledDate.weekday]}, '
                 '${exam.scheduledDate.day} de '
                 '${_months[exam.scheduledDate.month]}';

    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary : AppColors.inputBg,
          borderRadius: BorderRadius.circular(20)),
        child: Text(label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isToday ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w700)),
      ),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
    ]);
  }
}

// ── Exam Card ─────────────────────────────────────────────────────────────────
class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  const _ExamCard({required this.exam, required this.onTap, required this.onCancel});

  Color get _color {
    switch (exam.type) {
      case ExamType.laboratorial:  return AppColors.info;
      case ExamType.imaging:       return AppColors.night;
      case ExamType.clinical:      return AppColors.primary;
      case ExamType.consultation:  return AppColors.morning;
    }
  }

  IconData get _icon {
    switch (exam.type) {
      case ExamType.laboratorial:  return Icons.biotech_rounded;
      case ExamType.imaging:       return Icons.image_search_rounded;
      case ExamType.clinical:      return Icons.medical_services_rounded;
      case ExamType.consultation:  return Icons.person_outline_rounded;
    }
  }

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
            BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Ícone com cor do tipo
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
              child: Icon(_icon, color: _color, size: 26),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome + tipo
                  Text(exam.name,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                      child: Text(exam.typeLabel,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _color, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 8),

                  // Data e horário em destaque
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                      size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(exam.time,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary)),
                    const SizedBox(width: 12),
                    if (exam.location.isNotEmpty) ...[
                      const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(exam.location,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                  if (exam.doctor.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_outline_rounded,
                        size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(exam.doctor,
                        style: AppTextStyles.bodySmall),
                    ]),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
              color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Exam Detail Sheet ─────────────────────────────────────────────────────────
class _ExamDetailSheet extends StatelessWidget {
  final Exam exam;
  final VoidCallback onMarkDone;
  final VoidCallback onCancel;
  const _ExamDetailSheet({
    required this.exam, required this.onMarkDone, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 44, height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 20),

          Text(exam.name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(exam.typeLabel,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
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

          // Botão concluir
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                onMarkDone();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text('Marcar como realizado',
                style: AppTextStyles.buttonMedium),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 54,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                Navigator.pop(context);
                onCancel();
              },
              child: Text('Cancelar exame',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.error)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 54,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fechar',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.textSecondary)),
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
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.primary, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall),
            Text(value, style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ])),
      ]),
    );
  }
}

// ── Add Exam Sheet ────────────────────────────────────────────────────────────
class _AddExamSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _AddExamSheet({required this.onSaved});

  @override
  State<_AddExamSheet> createState() => _AddExamSheetState();
}

class _AddExamSheetState extends State<_AddExamSheet> {
  final _nameCtrl = TextEditingController();
  final _locCtrl  = TextEditingController();
  final _docCtrl  = TextEditingController();
  final _obsCtrl  = TextEditingController();

  ExamType _type      = ExamType.laboratorial;
  DateTime _date      = DateTime.now().add(const Duration(days: 1));
  String _time        = '07:00';
  bool _isSaving      = false;

  static const _typeLabels = ['Laboratorial','Imagem','Clínico','Consulta'];
  static const _typeIcons  = [
    Icons.biotech_rounded,
    Icons.image_search_rounded,
    Icons.medical_services_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _locCtrl.dispose();
    _docCtrl.dispose(); _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do exame')));
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 500));

    MockExamService.instance.add(Exam(
      id: MockExamService.instance.generateId(),
      name: _nameCtrl.text.trim(),
      type: _type,
      scheduledDate: _date,
      time: _time,
      location: _locCtrl.text.trim(),
      doctor: _docCtrl.text.trim(),
      observations: _obsCtrl.text.trim(),
    ));

    widget.onSaved();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Text('Exame agendado!',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  void _pickDate() {
    DateTime temp = _date;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetToolbar('Data do Exame', () {
            setState(() => _date = temp);
            Navigator.pop(ctx);
          }, ctx),
          SizedBox(height: 260,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _date,
              minimumDate: DateTime.now(),
              maximumDate: DateTime(2100),
              onDateTimeChanged: (d) => temp = d)),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ]),
      ),
    );
  }

  void _pickTime() {
    final p = _time.split(':');
    var h = int.parse(p[0]), m = int.parse(p[1]);
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetToolbar('Horário', () {
            setState(() => _time =
              '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}');
            Navigator.pop(ctx);
          }, ctx),
          SizedBox(height: 220,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: Duration(hours: h, minutes: m),
              itemExtent: 52,
              onTimerDurationChanged: (d) { h = d.inHours; m = d.inMinutes % 60; })),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ]),
      ),
    );
  }

  Widget _sheetToolbar(String title, VoidCallback onConfirm, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar',
            style: TextStyle(color: CupertinoColors.systemRed, fontSize: 17))),
        Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onConfirm,
          child: const Text('OK',
            style: TextStyle(color: AppColors.primary,
              fontSize: 17, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + header
            Center(child: Container(
              width: 44, height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(3)))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
              Text('Agendar Exame', style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: _isSaving ? null : _save,
                child: Text('Salvar',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary))),
            ]),
            const SizedBox(height: 20),

            // Nome
            Text('Nome do exame *', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: AppTextStyles.inputText,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Ex: Hemograma Completo',
                prefixIcon: Icon(Icons.science_outlined,
                  color: AppColors.primary))),
            const SizedBox(height: 18),

            // Tipo
            Text('Tipo', style: AppTextStyles.inputLabel),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ExamType.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final t   = ExamType.values[i];
                  final sel = t == _type;
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.inputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? AppColors.primary : AppColors.inputBorder)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_typeIcons[i],
                            color: sel ? AppColors.white : AppColors.textHint,
                            size: 24),
                          const SizedBox(height: 4),
                          Text(_typeLabels[i],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: sel ? AppColors.white : AppColors.textSecondary,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Data e Hora
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data *', style: AppTextStyles.inputLabel),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.inputBorder)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(_fmtDate(_date),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Horário *', style: AppTextStyles.inputLabel),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.inputBorder)),
                      child: Row(children: [
                        const Icon(Icons.access_time_rounded,
                          color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(_time,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 18),

            // Local
            Text('Local (opcional)', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _locCtrl,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Ex: Lab. Santa Clara',
                prefixIcon: Icon(Icons.location_on_outlined,
                  color: AppColors.primary))),
            const SizedBox(height: 18),

            // Médico
            Text('Médico responsável (opcional)', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(
              controller: _docCtrl,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Ex: Dr. João Silva',
                prefixIcon: Icon(Icons.person_outline_rounded,
                  color: AppColors.primary))),
            const SizedBox(height: 18),

            // Observações
            Text('Observações (opcional)', style: AppTextStyles.inputLabel),
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
                    color: AppColors.primary)))),
            const SizedBox(height: 28),

            // Botão
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: AppColors.primaryMedium),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                    : Text('Agendar Exame', style: AppTextStyles.buttonLarge)),
            ),
          ],
        ),
      ),
    );
  }
}
