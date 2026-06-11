import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/medication.dart';
import '../../home/mock/mock_medication_service.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATION FORM SCREEN — Adicionar / Editar
//  Arquivo: lib/features/medications/screens/medication_form_screen.dart
// ════════════════════════════════════════════════════════════

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;
  const MedicationFormScreen({super.key, this.medication});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _dosageCtrl= TextEditingController();
  final _obsCtrl   = TextEditingController();

  static const _types       = ['CP','ML','GTS','MG','UI','MCG'];
  static const _quantities  = ['0,5','1','1,5','2','2,5','3','4','5','10','15','20'];
  static const _units       = ['comprimido(s)','cápsula(s)','ml','gotas','mg','unidade(s)'];
  static const _frequencies = ['1X AO DIA','2X DIA','3X DIA','4X DIA','A CADA 6H','A CADA 8H','A CADA 12H','SE NECESSÁRIO'];
  static const _timesPerDayOptions = [1, 2, 3, 4];

  late int _typeIndex;
  late int _qtyIndex;
  late int _unitIndex;
  late int _freqIndex;
  late int _timesPerDay;
  late MedicationCategory _category;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<String> _times;

  bool _isSaving = false;

  bool get _isEditing => widget.medication != null;

  @override
  void initState() {
    super.initState();
    final med = widget.medication;
    _nameCtrl.text  = med?.name      ?? '';
    _dosageCtrl.text= med?.dosage    ?? '';
    _obsCtrl.text   = med?.observations ?? '';

    _typeIndex   = _types.indexWhere((t) => t == (med?.type ?? 'CP')).clamp(0, _types.length - 1);
    _qtyIndex    = 1;
    _unitIndex   = 0;
    _freqIndex   = _frequencies.indexWhere((f) => f == (med?.frequency ?? '')).clamp(0, _frequencies.length - 1);
    _timesPerDay = med?.timesPerDay ?? 1;
    _category    = med?.category    ?? MedicationCategory.remedio;
    _startDate   = med?.startDate   ?? DateTime.now();
    _endDate     = med?.endDate     ?? DateTime.now().add(const Duration(days: 30));
    _times       = med?.times       ?? Medication.generateTimes(_timesPerDay);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final med = Medication(
      id:           widget.medication?.id ?? MockMedicationService.instance.generateId(),
      name:         _nameCtrl.text.trim(),
      dosage:       '${_quantities[_qtyIndex]} ${_units[_unitIndex]}',
      frequency:    _frequencies[_freqIndex],
      timesPerDay:  _timesPerDay,
      times:        List.from(_times),
      type:         _types[_typeIndex],
      category:     _category,
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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Novo Medicamento'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text('Salvar',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Seção: Informações ────────────────────────
            _SectionHeader(title: 'Informações do Medicamento'),
            const SizedBox(height: 14),

            _FormCard(children: [
              // Nome
              _FieldLabel('Nome do medicamento *'),
              TextFormField(
                controller: _nameCtrl,
                style: AppTextStyles.inputText,
                decoration: const InputDecoration(hintText: 'Ex: Dipirona 500 mg'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 18),

              // Tipo (picker)
              _FieldLabel('Tipo'),
              _PickerTile(
                label: _types[_typeIndex],
                icon: Icons.medication_rounded,
                onTap: () => _showPicker(
                  title: 'Tipo de Medicamento',
                  items: _types,
                  selected: _typeIndex,
                  onSelect: (i) => setState(() => _typeIndex = i),
                ),
              ),
              const SizedBox(height: 18),

              // Dosagem (picker duplo)
              _FieldLabel('Dosagem'),
              _PickerTile(
                label: '${_quantities[_qtyIndex]} ${_units[_unitIndex]}',
                icon: Icons.colorize_rounded,
                onTap: _showDosagePicker,
              ),
            ]),

            const SizedBox(height: 20),

            // ── Seção: Frequência ─────────────────────────
            _SectionHeader(title: 'Frequência e Horários'),
            const SizedBox(height: 14),

            _FormCard(children: [
              _FieldLabel('Frequência'),
              _PickerTile(
                label: _frequencies[_freqIndex],
                icon: Icons.repeat_rounded,
                onTap: () => _showPicker(
                  title: 'Frequência',
                  items: _frequencies,
                  selected: _freqIndex,
                  onSelect: (i) => setState(() {
                    _freqIndex   = i;
                    _timesPerDay = _timesPerDayOptions[i.clamp(0, 3)];
                    _times       = Medication.generateTimes(_timesPerDay);
                  }),
                ),
              ),
              const SizedBox(height: 18),

              // Horários gerados
              _FieldLabel('Horários'),
              ..._times.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PickerTile(
                  label: e.value,
                  icon: Icons.access_time_rounded,
                  onTap: () => _showTimePicker(e.key),
                ),
              )),
            ]),

            const SizedBox(height: 20),

            // ── Seção: Categoria ──────────────────────────
            _SectionHeader(title: 'Categoria'),
            const SizedBox(height: 14),

            _FormCard(children: [
              Row(children: [
                _CatBtn('💊 Remédio',  MedicationCategory.remedio,   _category,
                    (v) => setState(() => _category = v)),
                const SizedBox(width: 8),
                _CatBtn('🔬 Exame',    MedicationCategory.exame,     _category,
                    (v) => setState(() => _category = v)),
                const SizedBox(width: 8),
                _CatBtn('🩺 Consulta', MedicationCategory.consulta,  _category,
                    (v) => setState(() => _category = v)),
              ]),
            ]),

            const SizedBox(height: 20),

            // ── Seção: Período ────────────────────────────
            _SectionHeader(title: 'Período de Tratamento'),
            const SizedBox(height: 14),

            _FormCard(children: [
              _FieldLabel('Data de início'),
              _PickerTile(
                label: _fmt(_startDate),
                icon: Icons.calendar_today_rounded,
                onTap: () => _showDatePicker(isStart: true),
              ),
              const SizedBox(height: 14),
              _FieldLabel('Data de término'),
              _PickerTile(
                label: _fmt(_endDate),
                icon: Icons.event_rounded,
                onTap: () => _showDatePicker(isStart: false),
              ),
              const SizedBox(height: 14),
              // Resumo
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Duração: ${_endDate.difference(_startDate).inDays} dias',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary))),
                ]),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Observações ───────────────────────────────
            _SectionHeader(title: 'Observações'),
            const SizedBox(height: 14),

            _FormCard(children: [
              TextFormField(
                controller: _obsCtrl,
                maxLines: 3,
                style: AppTextStyles.inputText,
                decoration: const InputDecoration(
                  hintText: 'Ex: Tomar com água, após as refeições...'),
              ),
            ]),

            const SizedBox(height: 32),

            // Botão salvar
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isEditing ? 'Salvar alterações' : 'Adicionar medicamento',
                  style: AppTextStyles.buttonLarge),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  void _showPicker({
    required String title,
    required List<String> items,
    required int selected,
    required Function(int) onSelect,
  }) {
    int temp = selected;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _CupertinoSheet(
        title: title,
        onConfirm: () { onSelect(temp); Navigator.pop(ctx); },
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
      ),
    );
  }

  void _showDosagePicker() {
    int q = _qtyIndex, u = _unitIndex;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _CupertinoSheet(
        title: 'Dosagem',
        onConfirm: () {
          setState(() { _qtyIndex = q; _unitIndex = u; });
          Navigator.pop(ctx);
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
                  fontSize: 22, fontWeight: FontWeight.w600)))).toList(),
            )),
            Expanded(flex: 3, child: CupertinoPicker(
              itemExtent: 52,
              scrollController: FixedExtentScrollController(initialItem: _unitIndex),
              onSelectedItemChanged: (i) => u = i,
              children: _units.map((it) => Center(
                child: Text(it, style: const TextStyle(fontSize: 18)))).toList(),
            )),
          ]),
        ),
      ),
    );
  }

  void _showTimePicker(int index) {
    final parts = _times[index].split(':');
    var h = int.parse(parts[0]), m = int.parse(parts[1]);
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _CupertinoSheet(
        title: 'Horário ${index + 1}',
        onConfirm: () {
          setState(() => _times[index] =
              '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}');
          Navigator.pop(ctx);
        },
        child: SizedBox(
          height: 220,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: Duration(hours: h, minutes: m),
            itemExtent: 56,
            onTimerDurationChanged: (d) { h = d.inHours; m = d.inMinutes % 60; },
          ),
        ),
      ),
    );
  }

  void _showDatePicker({required bool isStart}) {
    DateTime temp = isStart ? _startDate : _endDate;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _CupertinoSheet(
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
          Navigator.pop(ctx);
        },
        child: SizedBox(
          height: 260,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: temp,
            minimumDate: isStart ? DateTime(2020)
                : _startDate.add(const Duration(days: 1)),
            maximumDate: DateTime(2100),
            onDateTimeChanged: (d) => temp = d,
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
    style: AppTextStyles.sectionTitle);
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
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
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerTile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.inputText)),
          Icon(icon, color: AppColors.primary, size: 20),
        ],
      ),
    ),
  );
}

class _CatBtn extends StatelessWidget {
  final String label;
  final MedicationCategory value;
  final MedicationCategory current;
  final Function(MedicationCategory) onTap;
  const _CatBtn(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.inputBorder)),
          alignment: Alignment.center,
          child: Text(label, textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

class _CupertinoSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onConfirm;
  const _CupertinoSheet({required this.title, required this.child, required this.onConfirm});

  @override
  Widget build(BuildContext context) => Container(
    color: CupertinoColors.systemBackground.resolveFrom(context),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar',
                  style: TextStyle(color: CupertinoColors.systemRed, fontSize: 17))),
              Text(title, style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600)),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onConfirm,
                child: const Text('Confirmar',
                  style: TextStyle(
                    color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
        child,
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    ),
  );
}
