import 'package:flutter/material.dart';
import 'home_screen.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATION MODAL — CicloCare
//  Arquivo: lib/features/home/medication_modal.dart
//
//  Usado para:
//    • Visualizar um medicamento existente
//    • Editar um medicamento existente
//    • Adicionar um novo medicamento
// ════════════════════════════════════════════════════════════

class MedicationModal extends StatefulWidget {
  final Medication? medication;   // null = novo medicamento
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
  // ── CORES ────────────────────────────────────────────────
  static const Color _teal   = Color(0xFF3DB89E);
  static const Color _white  = Color(0xFFFFFFFF);
  static const Color _grey   = Color(0xFF6B7280);
  static const Color _red    = Color(0xFFEF4444);
  static const Color _bgGrey = Color(0xFFF3F4F6);

  // ── ESTADO ───────────────────────────────────────────────
  late bool _isEditing;
  late bool _doseTaken;
  bool _showDeleteConfirm = false;

  // Controllers dos campos de texto
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _freqCtrl;
  late TextEditingController _typeCtrl;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing || widget.medication == null;
    _doseTaken = widget.medication?.taken ?? false;

    // Preenche os campos com os dados existentes ou vazio para novo
    _nameCtrl   = TextEditingController(text: widget.medication?.name   ?? '');
    _dosageCtrl = TextEditingController(text: widget.medication?.dosage ?? '');
    _timeCtrl   = TextEditingController(text: widget.medication?.time   ?? '');
    _freqCtrl   = TextEditingController(text: widget.medication?.frequency ?? '');
    _typeCtrl   = TextEditingController(text: widget.medication?.type   ?? 'CP');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _timeCtrl.dispose();
    _freqCtrl.dispose();
    _typeCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Barra de drag + header ─────────────────────
          _buildHandle(),
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 20),

          // ── Diálogo de confirmação de exclusão ─────────
          if (_showDeleteConfirm) ...[
            _buildDeleteConfirm(),
            const SizedBox(height: 20),
          ],

          // ── Campos do medicamento ──────────────────────
          _buildNameField(),
          const SizedBox(height: 14),
          _buildField('Dosagem', _dosageCtrl, hint: '1 cápsula'),
          const SizedBox(height: 14),
          _buildField('Hora', _timeCtrl, hint: '08:00'),
          const SizedBox(height: 14),

          // Dose tomada — aparece só ao visualizar (não editando)
          if (!_isEditing && widget.medication != null) ...[
            _buildDoseTakenRow(),
            const SizedBox(height: 20),
          ],

          // ── Botão excluir — aparece só ao visualizar ───
          if (!_isEditing && widget.medication != null) ...[
            _buildDeleteButton(),
            const SizedBox(height: 14),
          ],

          // ── Botão principal ────────────────────────────
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BARRA DE DRAG (indicador visual do modal)
  // ════════════════════════════════════════════════════════
  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  HEADER: "Fechar" + título
  // ════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final title = widget.medication == null
        ? 'Novo Medicamento'
        : _isEditing
            ? 'Editar Medicamento'
            : 'Medicamento';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão fechar
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Fechar',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),

        // Título
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),

        // Botão editar (aparece ao visualizar)
        if (!_isEditing && widget.medication != null)
          TextButton(
            onPressed: () => setState(() => _isEditing = true),
            child: const Text(
              'Editar',
              style: TextStyle(color: _teal, fontSize: 14),
            ),
          )
        else
          const SizedBox(width: 64), // espaçador para manter alinhamento
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  CAMPO: Nome do medicamento com badge de tipo
  // ════════════════════════════════════════════════════════
  Widget _buildNameField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF5EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              enabled: _isEditing,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                hintText: 'Nome do medicamento',
                border: InputBorder.none,
              ),
            ),
          ),
          // Badge tipo (CP, ML...)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _typeCtrl.text.isEmpty ? 'CP' : _typeCtrl.text,
              style: const TextStyle(
                color: _teal,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CAMPO GENÉRICO (Dosagem, Hora)
  // ════════════════════════════════════════════════════════
  Widget _buildField(String label, TextEditingController ctrl, {String hint = ''}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _bgGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              enabled: _isEditing,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.black38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CHECKBOX — Dose Tomada
  // ════════════════════════════════════════════════════════
  Widget _buildDoseTakenRow() {
    return Row(
      children: [
        Checkbox(
          value: _doseTaken,
          activeColor: _teal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) => setState(() => _doseTaken = val ?? false),
        ),
        const Text('Dose Tomada', style: TextStyle(fontSize: 14)),

        const Spacer(),

        // Ícone de lixeira — abre confirmação de exclusão
        IconButton(
          icon: const Icon(Icons.delete_outline, color: _red),
          onPressed: () => setState(() => _showDeleteConfirm = true),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  DIÁLOGO DE CONFIRMAÇÃO DE EXCLUSÃO
  // ════════════════════════════════════════════════════════
  Widget _buildDeleteConfirm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: _red, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Deseja Excluir o\nMedicamento?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Cancelar
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _showDeleteConfirm = false),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: _white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Confirmar exclusão
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      widget.onDelete(widget.medication!.id);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(color: _white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTÃO EXCLUIR MEDICAMENTO (texto vermelho)
  // ════════════════════════════════════════════════════════
  Widget _buildDeleteButton() {
    return Center(
      child: TextButton(
        onPressed: () => setState(() => _showDeleteConfirm = true),
        child: const Text(
          'Excluir Medicamento',
          style: TextStyle(
            color: _red,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTÃO CONFIRMAR / SALVAR
  // ════════════════════════════════════════════════════════
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _handleConfirm,
        child: Text(
          _isEditing ? 'Confirmar' : 'Concluir',
          style: const TextStyle(
            color: _white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  LÓGICA — Salvar medicamento
  // ════════════════════════════════════════════════════════
  void _handleConfirm() {
    if (!_isEditing) {
      // Se só estava visualizando, fecha o modal
      Navigator.pop(context);
      return;
    }

    // Validação simples
    if (_nameCtrl.text.trim().isEmpty) return;

    final updated = Medication(
      // Mantém o id se for edição, gera um novo se for criação
      id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name:      _nameCtrl.text.trim(),
      dosage:    _dosageCtrl.text.trim(),
      time:      _timeCtrl.text.trim(),
      frequency: _freqCtrl.text.trim(),
      type:      _typeCtrl.text.trim().isEmpty ? 'CP' : _typeCtrl.text.trim(),
      taken:     _doseTaken,
    );

    widget.onSave(updated);
    Navigator.pop(context);
  }
}