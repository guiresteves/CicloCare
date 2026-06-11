import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/medication.dart';
import '../../home/mock/mock_medication_service.dart';
import 'medication_form_screen.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATIONS SCREEN
//  Arquivo: lib/features/medications/screens/medications_screen.dart
// ════════════════════════════════════════════════════════════

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late List<Medication> _meds;
  MedicationCategory? _filter; // null = todos

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _meds = _filter == null
        ? MockMedicationService.instance.getAll()
        : MockMedicationService.instance.getByCategory(_filter!);
  }

  void _openForm({Medication? med}) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => MedicationFormScreen(medication: med),
    ));
    setState(_load);
  }

  void _delete(Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir medicamento'),
        content: Text('Deseja excluir "${med.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              MockMedicationService.instance.delete(med.id);
              Navigator.pop(context);
              setState(_load);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilters(),
          // Lista
          Expanded(
            child: _meds.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _meds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _MedManageCard(
                      med: _meds[i],
                      onEdit: () => _openForm(med: _meds[i]),
                      onDelete: () => _delete(_meds[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Adicionar', style: AppTextStyles.buttonMedium),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = <MedicationCategory?>[null, MedicationCategory.remedio,
        MedicationCategory.exame, MedicationCategory.consulta];
    final labels  = ['Todos', 'Remédios', 'Exames', 'Consultas'];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final selected = _filter == filters[i];
            return GestureDetector(
              onTap: () => setState(() { _filter = filters[i]; _load(); }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(labels[i],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? AppColors.white : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.medication_outlined,
              color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Nenhum medicamento cadastrado',
            style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text('Toque em "Adicionar" para começar.',
            style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ── Card de gerenciamento ─────────────────────────────────────────────────────
class _MedManageCard extends StatelessWidget {
  final Medication med;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedManageCard({
    required this.med, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isActive = med.endDate == null || med.endDate!.isAfter(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.medication_rounded,
                  color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    Text(med.dosage, style: AppTextStyles.cardSubtitle),
                  ],
                ),
              ),
              // Status ativo/inativo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successLight : AppColors.doneLight,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(
                  isActive ? 'Ativo' : 'Encerrado',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive ? AppColors.success : AppColors.done,
                    fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info linha
          Wrap(
            spacing: 8, runSpacing: 6,
            children: [
              _InfoChip(Icons.repeat_rounded, med.frequency),
              _InfoChip(Icons.access_time_rounded, med.times.join(', ')),
              _InfoChip(Icons.calendar_today_rounded, med.periodLabel),
            ],
          ),
          const Divider(height: 20),
          // Ações
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Excluir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}