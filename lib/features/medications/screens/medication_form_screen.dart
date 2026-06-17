import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/medication.dart';
import '../../home/mock/mock_medication_service.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATION FORM SCREEN — CicloCare
//  Arquivo: lib/features/medications/screens/medication_form_screen.dart
//
//  Alteração 3:
//  • Formulário exclusivo para medicamentos (sem exames/consultas)
//  • UI/UX moderna com seções bem separadas
//  • Pickers iOS para dosagem, frequência, horário e período
//  • Feedback visual de salvamento
//  • Campos: Nome, Dosagem, Frequência, Horários, Início,
//    Término, Observações
// ════════════════════════════════════════════════════════════

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;
  const MedicationFormScreen({super.key, this.medication});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _obsCtrl  = TextEditingController();

  // Listas dos pickers
  static const _types      = ['CP','ML','GTS','MG','UI','MCG'];
  static const _quantities = ['0,5','1','1,5','2','2,5','3','4','5','10','15','20'];
  static const _units      = ['comprimido(s)','cápsula(s)','ml','gotas','mg','unidade(s)'];
  static const _freqLabels = [
    '1x ao dia','2x ao dia','3x ao dia','4x ao dia',
    'A cada 6h','A cada 8h','A cada 12h','Se necessário'
  ];
  static const _freqValues = [
    '1X AO DIA','2X DIA','3X DIA','4X DIA',
    'A CADA 6H','A CADA 8H','A CADA 12H','SE NECESSÁRIO'
  ];
  static const _timesPerDayMap = [1, 2, 3, 4, 4, 3, 2, 1];

  late int _typeIndex;
  late int _qtyIndex;
  late int _unitIndex;
  late int _freqIndex;
  late int _timesPerDay;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<String> _times;

  bool _isSaving = false;
  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;

    _nameCtrl.text = med?.name        ?? '';
    _obsCtrl.text  = med?.observations ?? '';

    _typeIndex   = _types.indexWhere((t) => t == (med?.type ?? 'CP')).clamp(0, _types.length - 1);
    _qtyIndex    = 1;
    _unitIndex   = 0;
    _freqIndex   = _freqValues.indexWhere((f) => f == (med?.frequency ?? '')).clamp(0, _freqValues.length - 1);
    _timesPerDay = med?.timesPerDay ?? 1;
    _startDate   = med?.startDate   ?? DateTime.now();
    _endDate     = med?.endDate     ?? DateTime.now().add(const Duration(days: 30));
    _times       = med?.times != null
        ? List.from(med!.times)
        : Medication.generateTimes(_timesPerDay);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Simula delay de salvamento
    await Future.delayed(const Duration(milliseconds: 600));

    final med = Medication(
      id:           widget.medication?.id ?? MockMedicationService.instance.generateId(),
      name:         _nameCtrl.text.trim(),
      dosage:       '${_quantities[_qtyIndex]} ${_units[_unitIndex]}',
      frequency:    _freqValues[_freqIndex],
      timesPerDay:  _timesPerDay,
      times:        List.from(_times),
      type:         _types[_typeIndex],
      category:     MedicationCategory.remedio, // sempre remédio neste formulário
      observations: _obsCtrl.text.trim(),
      startDate:    _startDate,
      endDate:      _endDate,
      statusMap:    Map<String, MedicationStatus>.from(
                      widget.medication?.statusMap ?? {}),
    );

    if (_isEditing) {
      MockMedicationService.instance.update(med);
    } else {
      MockMedicationService.instance.add(med);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Feedback visual de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text(
            _isEditing
                ? 'Medicamento atualizado!'
                : 'Medicamento adicionado!',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Editar Remédio' : 'Novo Remédio',
          style: AppTextStyles.appBarTitle),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary))),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text('Salvar',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [

            // ════════════════════════════════════════════
            //  1. IDENTIFICAÇÃO
            // ════════════════════════════════════════════
            _SectionCard(
              icon: Icons.medication_rounded,
              title: 'Identificação',
              children: [
                _FieldLabel('Nome do medicamento *'),
                TextFormField(
                  controller: _nameCtrl,
                  style: AppTextStyles.inputText,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Dipirona 500 mg',
                    prefixIcon: Icon(Icons.medication_outlined,
                      color: AppColors.primary)),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Informe o nome do medicamento' : null,
                ),
                const SizedBox(height: 16),

                _FieldLabel('Tipo'),
                _PickerTile(
                  icon: Icons.category_outlined,
                  label: _types[_typeIndex],
                  subtitle: 'Forma farmacêutica',
                  onTap: () => _showListPicker(
                    title: 'Tipo',
                    items: _types,
                    selected: _typeIndex,
                    onSelect: (i) => setState(() => _typeIndex = i),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ════════════════════════════════════════════
            //  2. DOSAGEM
            // ════════════════════════════════════════════
            _SectionCard(
              icon: Icons.colorize_rounded,
              title: 'Dosagem',
              children: [
                _FieldLabel('Quantidade e unidade'),
                _PickerTile(
                  icon: Icons.colorize_rounded,
                  label: '${_quantities[_qtyIndex]} ${_units[_unitIndex]}',
                  subtitle: 'Toque para ajustar',
                  onTap: _showDosagePicker,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ════════════════════════════════════════════
            //  3. FREQUÊNCIA E HORÁRIOS
            // ════════════════════════════════════════════
            _SectionCard(
              icon: Icons.repeat_rounded,
              title: 'Frequência e Horários',
              children: [
                _FieldLabel('Com que frequência?'),
                _PickerTile(
                  icon: Icons.repeat_rounded,
                  label: _freqLabels[_freqIndex],
                  subtitle: _freqValues[_freqIndex],
                  onTap: () => _showListPicker(
                    title: 'Frequência',
                    items: _freqLabels,
                    selected: _freqIndex,
                    onSelect: (i) => setState(() {
                      _freqIndex   = i;
                      _timesPerDay = _timesPerDayMap[i];
                      _times       = Medication.generateTimes(_timesPerDay);
                    }),
                  ),
                ),

                if (_times.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FieldLabel('Horários (${_times.length})'),
                  ..._times.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PickerTile(
                      icon: Icons.access_time_rounded,
                      label: e.value,
                      subtitle: '${e.key + 1}ª dose do dia',
                      onTap: () => _showTimePicker(e.key),
                    ),
                  )),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ════════════════════════════════════════════
            //  4. PERÍODO DE TRATAMENTO
            // ════════════════════════════════════════════
            _SectionCard(
              icon: Icons.date_range_rounded,
              title: 'Período de Tratamento',
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Data de início'),
                        _PickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: _fmt(_startDate),
                          subtitle: 'Início',
                          onTap: () => _showDatePicker(isStart: true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Data de término'),
                        _PickerTile(
                          icon: Icons.event_rounded,
                          label: _fmt(_endDate),
                          subtitle: 'Término',
                          onTap: () => _showDatePicker(isStart: false),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 14),

                // Resumo do período
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(
                      'Duração total: ${_endDate.difference(_startDate).inDays} dias de tratamento',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600))),
                  ]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ════════════════════════════════════════════
            //  5. OBSERVAÇÕES
            // ════════════════════════════════════════════
            _SectionCard(
              icon: Icons.notes_rounded,
              title: 'Observações',
              children: [
                TextFormField(
                  controller: _obsCtrl,
                  maxLines: 3,
                  style: AppTextStyles.inputText,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Ex: Tomar após as refeições, com bastante água...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Botão principal ───────────────────────────
            SizedBox(
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryMedium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white))
                    : Text(
                        _isEditing
                            ? 'Salvar alterações'
                            : 'Adicionar medicamento',
                        style: AppTextStyles.buttonLarge),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Formatação de data ───────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  // ── Picker genérico de lista ──────────────────────────────
  void _showListPicker({
    required String title,
    required List<String> items,
    required int selected,
    required Function(int) onSelect,
  }) {
    int temp = selected;
    _showSheet(
      title: title,
      onConfirm: () { onSelect(temp); Navigator.pop(context); },
      child: SizedBox(
        height: 220,
        child: CupertinoPicker(
          itemExtent: 52,
          scrollController: FixedExtentScrollController(initialItem: selected),
          onSelectedItemChanged: (i) => temp = i,
          children: items.map((it) => Center(
            child: Text(it, style: const TextStyle(fontSize: 18)))).toList(),
        ),
      ),
    );
  }

  // ── Picker de dosagem (duplo) ─────────────────────────────
  void _showDosagePicker() {
    int q = _qtyIndex, u = _unitIndex;
    _showSheet(
      title: 'Dosagem',
      onConfirm: () {
        setState(() { _qtyIndex = q; _unitIndex = u; });
        Navigator.pop(context);
      },
      child: SizedBox(
        height: 220,
        child: Row(children: [
          Expanded(flex: 2, child: CupertinoPicker(
            itemExtent: 52,
            scrollController: FixedExtentScrollController(initialItem: _qtyIndex),
            onSelectedItemChanged: (i) => q = i,
            children: _quantities.map((it) => Center(
              child: Text(it, style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700)))).toList(),
          )),
          Expanded(flex: 3, child: CupertinoPicker(
            itemExtent: 52,
            scrollController: FixedExtentScrollController(initialItem: _unitIndex),
            onSelectedItemChanged: (i) => u = i,
            children: _units.map((it) => Center(
              child: Text(it, style: const TextStyle(fontSize: 17)))).toList(),
          )),
        ]),
      ),
    );
  }

  // ── Picker de horário ─────────────────────────────────────
  void _showTimePicker(int index) {
    final parts = _times[index].split(':');
    var h = int.parse(parts[0]), m = int.parse(parts[1]);
    _showSheet(
      title: 'Horário ${index + 1}',
      onConfirm: () {
        setState(() => _times[index] =
            '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}');
        Navigator.pop(context);
      },
      child: SizedBox(
        height: 220,
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: Duration(hours: h, minutes: m),
          itemExtent: 56,
          onTimerDurationChanged: (d) {
            h = d.inHours;
            m = d.inMinutes % 60;
          },
        ),
      ),
    );
  }

  // ── Picker de data ────────────────────────────────────────
  void _showDatePicker({required bool isStart}) {
    DateTime temp = isStart ? _startDate : _endDate;
    _showSheet(
      title: isStart ? 'Data de Início' : 'Data de Término',
      onConfirm: () {
        setState(() {
          if (isStart) {
            _startDate = temp;
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(days: 1));
            }
          } else {
            if (temp.isAfter(_startDate)) _endDate = temp;
          }
        });
        Navigator.pop(context);
      },
      child: SizedBox(
        height: 260,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: temp,
          minimumDate: isStart
              ? DateTime(2020)
              : _startDate.add(const Duration(days: 1)),
          maximumDate: DateTime(2100),
          onDateTimeChanged: (d) => temp = d,
        ),
      ),
    );
  }

  // ── Helper: sheet padrão iOS ──────────────────────────────
  void _showSheet({
    required String title,
    required Widget child,
    required VoidCallback onConfirm,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar',
                      style: TextStyle(color: CupertinoColors.systemRed, fontSize: 17))),
                  Text(title,
                    style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: onConfirm,
                    child: const Text('Confirmar',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 17, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
            child,
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares do formulário ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyles.sectionTitle),
        ]),
        const SizedBox(height: 12),
        // Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.inputLabel),
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _PickerTile({
    required this.icon, required this.label,
    required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder)),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
            color: AppColors.textHint, size: 20),
        ]),
      ),
    );
  }
}
