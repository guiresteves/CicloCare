import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/medication.dart';
import '../mock/mock_medication_service.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATION MODAL — CicloCare
//  Arquivo: lib/features/home/screens/medication_modal.dart
// ════════════════════════════════════════════════════════════

class MedicationModal extends StatefulWidget {
  final Medication? medication;
  final bool isEditing;
  final Function(Medication) onSave;
  final Function(String) onDelete;

  const MedicationModal({
    super.key,
    required this.medication,
    required this.isEditing,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<MedicationModal> createState() => _MedicationModalState();
}

class _MedicationModalState extends State<MedicationModal> {
  static const Color _green      = Color(0xFF2DA87A);
  static const Color _greenLight = Color(0xFFE8F8F2);
  static const Color _white      = Color(0xFFFFFFFF);
  static const Color _red        = Color(0xFFB94040);
  static const Color _bgGrey     = Color(0xFFF3F4F6);
  static const Color _bgGreen    = Color(0xFFDFF5EE);
  static const Color _textDark   = Color(0xFF111827);
  static const Color _textGrey   = Color(0xFF4B5563);

  // ── Opções dos pickers ───────────────────────────────────
  static const List<String> _types       = ['CP','ML','GTS','MG','UI','MCG'];
  static const List<String> _quantities  = ['0,5','1','1,5','2','2,5','3','4','5','10','15','20'];
  static const List<String> _units       = ['comprimido(s)','cápsula(s)','ml','gotas','mg','unidade(s)'];
  static const List<String> _frequencies = ['1X AO DIA','2X DIA','3X DIA','4X DIA','A CADA 6H','A CADA 8H','A CADA 12H','SEM. (1X/SEM)','MENSAL','SE NECESSÁRIO'];

  // ── Estado ───────────────────────────────────────────────
  late bool _isEditing;
  late bool _doseTaken;
  bool _showDeleteConfirm = false;

  late int _selectedHour;
  late int _selectedMinute;
  late int _dosageQtyIndex;
  late int _dosageUnitIndex;
  late int _freqIndex;
  late int _typeIndex;

  // Período
  late DateTime _startDate;
  late DateTime _endDate;

  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing || widget.medication == null;
    _doseTaken = widget.medication?.taken ?? false;

    final timeParts = (widget.medication?.time ?? '08:00').split(':');
    _selectedHour   = int.tryParse(timeParts[0]) ?? 8;
    _selectedMinute = int.tryParse(timeParts[1]) ?? 0;

    final existingDosage = widget.medication?.dosage ?? '';
    _dosageQtyIndex  = _quantities.indexWhere((q) => existingDosage.contains(q));
    _dosageUnitIndex = _units.indexWhere((u) => existingDosage.contains(u));
    if (_dosageQtyIndex  < 0) _dosageQtyIndex  = 1;
    if (_dosageUnitIndex < 0) _dosageUnitIndex = 0;

    final existingFreq = widget.medication?.frequency ?? '';
    _freqIndex = _frequencies.indexWhere((f) => f == existingFreq);
    if (_freqIndex < 0) _freqIndex = 1;

    final existingType = widget.medication?.type ?? 'CP';
    _typeIndex = _types.indexWhere((t) => t == existingType);
    if (_typeIndex < 0) _typeIndex = 0;

    // Período
    _startDate = widget.medication?.startDate ?? DateTime.now();
    _endDate   = widget.medication?.endDate   ?? DateTime.now().add(const Duration(days: 30));

    _nameCtrl = TextEditingController(text: widget.medication?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ── Getters ──────────────────────────────────────────────
  String get _formattedTime =>
      '${_selectedHour.toString().padLeft(2,'0')}:${_selectedMinute.toString().padLeft(2,'0')}';
  String get _formattedDosage    => '${_quantities[_dosageQtyIndex]} ${_units[_dosageUnitIndex]}';
  String get _formattedFrequency => _frequencies[_freqIndex];
  String get _selectedType       => _types[_typeIndex];
  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        left: 24, right: 24, top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 24),

            if (_showDeleteConfirm) ...[
              _buildDeleteConfirm(),
              const SizedBox(height: 20),
            ],

            // ── Medicamento ──────────────────────────────
            _buildNameField(),
            const SizedBox(height: 14),
            _buildPickerField(
              label: 'Dosagem', value: _formattedDosage,
              icon: Icons.colorize_rounded,
              onTap: _isEditing ? _showDosagePicker : null,
            ),
            const SizedBox(height: 14),
            _buildPickerField(
              label: 'Frequência', value: _formattedFrequency,
              icon: Icons.repeat_rounded,
              onTap: _isEditing ? _showFrequencyPicker : null,
            ),
            const SizedBox(height: 14),
            _buildPickerField(
              label: 'Horário', value: _formattedTime,
              icon: Icons.access_time_rounded, isTime: true,
              onTap: _isEditing ? _showTimePicker : null,
            ),

            // ── Período ──────────────────────────────────
            const SizedBox(height: 28),
            _buildSectionDivider('📅  Período de Tratamento'),
            const SizedBox(height: 14),

            _buildPickerField(
              label: 'Início', value: _fmtDate(_startDate),
              icon: Icons.calendar_today_rounded,
              onTap: _isEditing ? () => _showDatePicker(isStart: true) : null,
            ),
            const SizedBox(height: 14),
            _buildPickerField(
              label: 'Término', value: _fmtDate(_endDate),
              icon: Icons.event_rounded,
              onTap: _isEditing ? () => _showDatePicker(isStart: false) : null,
            ),

            // Resumo do período
            const SizedBox(height: 10),
            _buildPeriodSummary(),

            // ── Dose tomada / excluir ────────────────────
            if (!_isEditing && widget.medication != null) ...[
              const SizedBox(height: 20),
              _buildDoseTakenRow(),
              const SizedBox(height: 14),
              _buildDeleteButton(),
            ],

            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  HANDLE
  // ════════════════════════════════════════════════════════
  Widget _buildHandle() => Center(
    child: Container(
      width: 44, height: 5,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
    ),
  );

  // ════════════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final title = widget.medication == null
        ? 'Novo Medicamento'
        : _isEditing ? 'Editar Medicamento' : 'Medicamento';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar', style: TextStyle(color: Colors.black54, fontSize: 17)),
        ),
        Text(title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: _textDark)),
        if (!_isEditing && widget.medication != null)
          TextButton(
            onPressed: () => setState(() => _isEditing = true),
            child: const Text('Editar',
              style: TextStyle(color: _green, fontSize: 17, fontWeight: FontWeight.w700)),
          )
        else
          const SizedBox(width: 72),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  DIVISOR DE SEÇÃO
  // ════════════════════════════════════════════════════════
  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        Text(title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(width: 12),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  RESUMO DO PERÍODO
  // ════════════════════════════════════════════════════════
  Widget _buildPeriodSummary() {
    final days = _endDate.difference(_startDate).inDays;
    final remaining = _endDate.difference(DateTime.now()).inDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: _green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duração total: $days dias',
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: _green),
                ),
                const SizedBox(height: 2),
                Text(
                  remaining > 0
                      ? 'Faltam $remaining dias para o fim do tratamento'
                      : remaining == 0
                          ? 'Último dia do tratamento!'
                          : 'Tratamento encerrado há ${remaining.abs()} dias',
                  style: TextStyle(
                    fontSize: 14,
                    color: remaining < 0 ? _red : _green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CAMPO NOME + BADGE TIPO
  // ════════════════════════════════════════════════════════
  Widget _buildNameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(color: _bgGreen, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              enabled: _isEditing,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: _textDark),
              decoration: const InputDecoration(
                hintText: 'Nome do medicamento',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 18),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: _isEditing ? _showTypePicker : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedType,
                    style: const TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 16)),
                  if (_isEditing) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded, color: _green, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CAMPO PICKER GENÉRICO
  // ════════════════════════════════════════════════════════
  Widget _buildPickerField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
    bool isTime = false,
  }) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(color: _bgGrey, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(label,
                style: const TextStyle(color: _textGrey, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: isTime ? 22 : 16,
                fontWeight: isTime ? FontWeight.w800 : FontWeight.w600,
                color: active ? _green : _textDark,
                letterSpacing: isTime ? 1 : 0,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 10),
              Icon(icon, color: _green, size: 22),
            ],
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  DOSE TOMADA
  // ════════════════════════════════════════════════════════
  Widget _buildDoseTakenRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: _bgGrey, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.3,
            child: Checkbox(
              value: _doseTaken,
              activeColor: _green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: (val) => setState(() => _doseTaken = val ?? false),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Dose Tomada',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textDark)),
          const Spacer(),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.delete_outline, color: _red),
            onPressed: () => setState(() => _showDeleteConfirm = true),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CONFIRMAÇÃO DE EXCLUSÃO
  // ════════════════════════════════════════════════════════
  Widget _buildDeleteConfirm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: _red, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Deseja excluir este\nmedicamento?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: _textDark)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: SizedBox(height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () => setState(() => _showDeleteConfirm = false),
                  child: const Text('Cancelar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ))),
              const SizedBox(width: 14),
              Expanded(child: SizedBox(height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () {
                    widget.onDelete(widget.medication!.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirmar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() => Center(
    child: TextButton(
      onPressed: () => setState(() => _showDeleteConfirm = true),
      child: const Text('Excluir Medicamento',
        style: TextStyle(color: _red, fontSize: 17, fontWeight: FontWeight.w600)),
    ),
  );

  // ════════════════════════════════════════════════════════
  //  BOTÃO CONFIRMAR
  // ════════════════════════════════════════════════════════
  Widget _buildConfirmButton() => SizedBox(
    width: double.infinity, height: 58,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: _handleConfirm,
      child: Text(
        _isEditing ? 'Salvar Medicamento' : 'Concluir',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
      ),
    ),
  );

  // ════════════════════════════════════════════════════════
  //  HELPER — popup padrão iOS
  // ════════════════════════════════════════════════════════
  void _showCupertinoPopup({required String title, required Widget picker, VoidCallback? onConfirm}) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar',
                      style: TextStyle(color: CupertinoColors.systemRed, fontSize: 17)),
                  ),
                  Text(title,
                    style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600, color: CupertinoColors.black)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () { onConfirm?.call(); Navigator.pop(ctx); },
                    child: const Text('Confirmar',
                      style: TextStyle(
                        color: Color(0xFF2DA87A), fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            picker,
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PICKER — HORÁRIO
  // ════════════════════════════════════════════════════════
  void _showTimePicker() {
    var h = _selectedHour, m = _selectedMinute;
    _showCupertinoPopup(
      title: 'Selecionar Horário',
      onConfirm: () => setState(() { _selectedHour = h; _selectedMinute = m; }),
      picker: SizedBox(height: 220,
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: Duration(hours: _selectedHour, minutes: _selectedMinute),
          itemExtent: 56,
          onTimerDurationChanged: (d) { h = d.inHours; m = d.inMinutes % 60; },
        )),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PICKER — DOSAGEM
  // ════════════════════════════════════════════════════════
  void _showDosagePicker() {
    var qty = _dosageQtyIndex, unit = _dosageUnitIndex;
    _showCupertinoPopup(
      title: 'Selecionar Dosagem',
      onConfirm: () => setState(() { _dosageQtyIndex = qty; _dosageUnitIndex = unit; }),
      picker: SizedBox(height: 220,
        child: Row(children: [
          Expanded(flex: 2,
            child: CupertinoPicker(
              itemExtent: 52,
              scrollController: FixedExtentScrollController(initialItem: _dosageQtyIndex),
              onSelectedItemChanged: (i) => qty = i,
              children: _quantities.map((q) =>
                Center(child: Text(q,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)))).toList(),
            )),
          Expanded(flex: 3,
            child: CupertinoPicker(
              itemExtent: 52,
              scrollController: FixedExtentScrollController(initialItem: _dosageUnitIndex),
              onSelectedItemChanged: (i) => unit = i,
              children: _units.map((u) =>
                Center(child: Text(u, style: const TextStyle(fontSize: 18)))).toList(),
            )),
        ])),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PICKER — FREQUÊNCIA
  // ════════════════════════════════════════════════════════
  void _showFrequencyPicker() {
    var idx = _freqIndex;
    _showCupertinoPopup(
      title: 'Selecionar Frequência',
      onConfirm: () => setState(() => _freqIndex = idx),
      picker: SizedBox(height: 220,
        child: CupertinoPicker(
          itemExtent: 52,
          scrollController: FixedExtentScrollController(initialItem: _freqIndex),
          onSelectedItemChanged: (i) => idx = i,
          children: _frequencies.map((f) =>
            Center(child: Text(f,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))).toList(),
        )),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PICKER — TIPO
  // ════════════════════════════════════════════════════════
  void _showTypePicker() {
    var idx = _typeIndex;
    _showCupertinoPopup(
      title: 'Tipo de Dosagem',
      onConfirm: () => setState(() => _typeIndex = idx),
      picker: SizedBox(height: 200,
        child: CupertinoPicker(
          itemExtent: 52,
          scrollController: FixedExtentScrollController(initialItem: _typeIndex),
          onSelectedItemChanged: (i) => idx = i,
          children: _types.map((t) =>
            Center(child: Text(t,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)))).toList(),
        )),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PICKER — DATA (início ou fim) — estilo iOS
  // ════════════════════════════════════════════════════════
  void _showDatePicker({required bool isStart}) {
    DateTime tempDate = isStart ? _startDate : _endDate;

    _showCupertinoPopup(
      title: isStart ? 'Data de Início' : 'Data de Término',
      onConfirm: () {
        if (isStart) {
          setState(() {
            _startDate = tempDate;
            // Garante que endDate é sempre após startDate
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(days: 1));
            }
          });
        } else {
          if (tempDate.isAfter(_startDate)) {
            setState(() => _endDate = tempDate);
          } else {
            _showValidationError('A data de término deve ser após a data de início.');
          }
        }
      },
      picker: SizedBox(
        height: 260,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: tempDate,
          minimumDate: isStart
              ? DateTime(2020)
              : _startDate.add(const Duration(days: 1)),
          maximumDate: DateTime(2100),
          onDateTimeChanged: (d) => tempDate = d,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  VALIDAÇÃO E SALVAR
  // ════════════════════════════════════════════════════════
  void _handleConfirm() {
    if (!_isEditing) { Navigator.pop(context); return; }

    if (_nameCtrl.text.trim().isEmpty) {
      _showValidationError('Informe o nome do medicamento.');
      return;
    }
    if (_selectedHour == 0 && _selectedMinute == 0) {
      _showValidationError('Selecione um horário válido.');
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      _showValidationError('A data de término deve ser após a data de início.');
      return;
    }

    final updated = Medication(
      id:        widget.medication?.id ?? MockMedicationService.instance.generateId(),
      name:      _nameCtrl.text.trim(),
      dosage:    _formattedDosage,
      time:      _formattedTime,
      frequency: _formattedFrequency,
      type:      _selectedType,
      taken:     _doseTaken,
      startDate: _startDate,
      endDate:   _endDate,
    );

    widget.onSave(updated);
    Navigator.pop(context);
  }

  void _showValidationError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Atenção', style: TextStyle(fontSize: 18)),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(message, style: const TextStyle(fontSize: 16)),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
              style: TextStyle(fontSize: 17, color: Color(0xFF2DA87A))),
          ),
        ],
      ),
    );
  }
}