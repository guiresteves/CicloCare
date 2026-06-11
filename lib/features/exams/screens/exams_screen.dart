import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/exam.dart';
import '../mock/mock_exam_service.dart';

// ════════════════════════════════════════════════════════════
//  EXAMS SCREEN
//  Arquivo: lib/features/exams/screens/exams_screen.dart
// ════════════════════════════════════════════════════════════

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});
  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming  = MockExamService.instance.getUpcoming();
    final completed = MockExamService.instance.getCompleted();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exames e Consultas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTextStyles.labelLarge,
          tabs: const [
            Tab(text: 'Próximos'),
            Tab(text: 'Histórico'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddExamSheet(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Próximos ────────────────────────────────────
          upcoming.isEmpty
              ? _buildEmpty('Nenhum exame agendado',
                  'Toque em + para agendar um exame')
              : _buildTimeline(upcoming),

          // ── Histórico ───────────────────────────────────
          completed.isEmpty
              ? _buildEmpty('Nenhum exame concluído',
                  'Os exames realizados aparecerão aqui')
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: completed.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ExamCard(
                    exam: completed[i],
                    onTap: () => _showExamDetail(completed[i]),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExamSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Agendar', style: AppTextStyles.buttonMedium),
      ),
    );
  }

  // ── Timeline de próximos exames ──────────────────────────
  Widget _buildTimeline(List<Exam> exams) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: exams.length,
      itemBuilder: (_, i) {
        final exam = exams[i];
        final showDateHeader = i == 0 ||
            exams[i - 1].scheduledDate.day != exam.scheduledDate.day;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader) ...[
              if (i > 0) const SizedBox(height: 20),
              _DateHeader(date: exam.scheduledDate),
              const SizedBox(height: 10),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha do tempo
                Column(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle),
                    ),
                    if (i < exams.length - 1)
                      Container(
                        width: 2, height: 80,
                        color: AppColors.primaryMedium),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ExamCard(
                    exam: exam,
                    onTap: () => _showExamDetail(exam),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.science_outlined,
              color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  void _showExamDetail(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamDetailModal(exam: exam, onUpdate: () => setState(() {})),
    );
  }

  void _showAddExamSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExamModal(onAdd: () => setState(() {})),
    );
  }
}

// ── Date Header ───────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  static const _months = ['','Jan','Fev','Mar','Abr','Mai','Jun',
      'Jul','Ago','Set','Out','Nov','Dez'];
  static const _weekDays = ['','Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];

  @override
  Widget build(BuildContext context) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month;

    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary : AppColors.inputBg,
          borderRadius: BorderRadius.circular(20)),
        child: Text(
          isToday
              ? 'Hoje — ${date.day} ${_months[date.month]}'
              : '${_weekDays[date.weekday]}, ${date.day} ${_months[date.month]}',
          style: AppTextStyles.labelMedium.copyWith(
            color: isToday ? AppColors.white : AppColors.textSecondary)),
      ),
    ]);
  }
}

// ── Exam Card ─────────────────────────────────────────────────────────────────
class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onTap;
  const _ExamCard({required this.exam, required this.onTap});

  Color get _typeColor {
    switch (exam.type) {
      case ExamType.laboratorial:  return AppColors.info;
      case ExamType.imaging:       return AppColors.night;
      case ExamType.clinical:      return AppColors.primary;
      case ExamType.consultation:  return AppColors.morning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = exam.status == ExamStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            // Ícone tipo
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
              child: Icon(_typeIcon, color: _typeColor, size: 26),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam.name,
                    style: AppTextStyles.cardTitle.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.done)),
                  const SizedBox(height: 3),
                  if (exam.doctor.isNotEmpty)
                    Text(exam.doctor, style: AppTextStyles.cardSubtitle),
                  const SizedBox(height: 6),
                  Row(children: [
                    _chip(Icons.calendar_today_rounded, exam.formattedDate),
                    const SizedBox(width: 6),
                    _chip(Icons.access_time_rounded, exam.time),
                    if (exam.location.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _chip(Icons.location_on_outlined, exam.location),
                    ],
                  ]),
                ],
              ),
            ),

            const SizedBox(width: 8),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDone ? AppColors.successLight : AppColors.infoLight,
                borderRadius: BorderRadius.circular(20)),
              child: Text(exam.statusLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDone ? AppColors.success : AppColors.info,
                  fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _typeIcon {
    switch (exam.type) {
      case ExamType.laboratorial:  return Icons.science_rounded;
      case ExamType.imaging:       return Icons.image_search_rounded;
      case ExamType.clinical:      return Icons.medical_services_outlined;
      case ExamType.consultation:  return Icons.person_outline_rounded;
    }
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
      ]),
    );
  }
}

// ── Exam Detail Modal ─────────────────────────────────────────────────────────
class _ExamDetailModal extends StatelessWidget {
  final Exam exam;
  final VoidCallback onUpdate;
  const _ExamDetailModal({required this.exam, required this.onUpdate});

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
          Text(exam.typeLabel, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 20),
          _detailRow(Icons.calendar_today_rounded, 'Data', exam.formattedDate),
          _detailRow(Icons.access_time_rounded, 'Horário', exam.time),
          if (exam.location.isNotEmpty)
            _detailRow(Icons.location_on_outlined, 'Local', exam.location),
          if (exam.doctor.isNotEmpty)
            _detailRow(Icons.person_outline_rounded, 'Médico', exam.doctor),
          if (exam.observations.isNotEmpty)
            _detailRow(Icons.notes_rounded, 'Obs.', exam.observations),
          const SizedBox(height: 24),
          if (exam.status == ExamStatus.scheduled)
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  exam.status = ExamStatus.completed;
                  MockExamService.instance.update(exam);
                  onUpdate();
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
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

  Widget _detailRow(IconData icon, String label, String value) {
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
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.labelSmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}

// ── Add Exam Modal ────────────────────────────────────────────────────────────
class _AddExamModal extends StatefulWidget {
  final VoidCallback onAdd;
  const _AddExamModal({required this.onAdd});

  @override
  State<_AddExamModal> createState() => _AddExamModalState();
}

class _AddExamModalState extends State<_AddExamModal> {
  final _nameCtrl  = TextEditingController();
  final _locCtrl   = TextEditingController();
  final _docCtrl   = TextEditingController();
  final _obsCtrl   = TextEditingController();
  ExamType _type   = ExamType.laboratorial;
  DateTime _date   = DateTime.now().add(const Duration(days: 1));
  String _time     = '07:00';

  @override
  void dispose() {
    _nameCtrl.dispose(); _locCtrl.dispose();
    _docCtrl.dispose(); _obsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
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
    widget.onAdd();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                  style: TextStyle(color: Colors.black54, fontSize: 16))),
              Text('Novo Exame', style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: _save,
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
              decoration: const InputDecoration(hintText: 'Ex: Hemograma Completo')),
            const SizedBox(height: 16),

            // Tipo
            Text('Tipo', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ExamType.values.map((t) {
              final labels = ['Laboratorial','Imagem','Clínico','Consulta'];
              final sel = t == _type;
              return GestureDetector(
                onTap: () => setState(() => _type = t),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.inputBg,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(labels[t.index],
                    style: AppTextStyles.labelMedium.copyWith(
                      color: sel ? AppColors.white : AppColors.textSecondary))),
              );
            }).toList()),
            const SizedBox(height: 16),

            // Local / Médico
            Text('Local', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(controller: _locCtrl, style: AppTextStyles.inputText,
              decoration: const InputDecoration(hintText: 'Ex: Lab. Santa Clara')),
            const SizedBox(height: 16),

            Text('Médico', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(controller: _docCtrl, style: AppTextStyles.inputText,
              decoration: const InputDecoration(hintText: 'Ex: Dr. João Silva')),
            const SizedBox(height: 16),

            Text('Observações', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            TextField(controller: _obsCtrl, maxLines: 2,
              style: AppTextStyles.inputText,
              decoration: const InputDecoration(
                hintText: 'Ex: Jejum de 8 horas...')),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
                onPressed: _save,
                child: Text('Agendar Exame', style: AppTextStyles.buttonLarge))),
          ],
        ),
      ),
    );
  }
}