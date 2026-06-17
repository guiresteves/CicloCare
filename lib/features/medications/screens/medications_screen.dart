import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/models/medication.dart';
import '../../home/mock/mock_medication_service.dart';
import 'medication_form_screen.dart';

// ════════════════════════════════════════════════════════════
//  MEDICATIONS SCREEN — CicloCare
//  Arquivo: lib/features/medications/screens/medications_screen.dart
//
//  Alteração 3:
//  • Exibe SOMENTE medicamentos (categoria remedio)
//  • Exames e consultas não aparecem aqui
//  • Formulário exclusivo para cadastro de medicamentos
//  • CRUD completo: adicionar, editar, excluir
// ════════════════════════════════════════════════════════════

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Medication> _active;
  late List<Medication> _inactive;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final all = MockMedicationService.instance
        .getByCategory(MedicationCategory.remedio);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _active = all.where((m) =>
      m.endDate == null ||
      !DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day).isBefore(today)
    ).toList();

    _inactive = all.where((m) =>
      m.endDate != null &&
      DateTime(m.endDate!.year, m.endDate!.month, m.endDate!.day).isBefore(today)
    ).toList();
  }

  Future<void> _openForm({Medication? med}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicationFormScreen(medication: med),
      ),
    );
    setState(_load);
  }

  void _confirmDelete(Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir medicamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              const TextSpan(text: 'Deseja excluir '),
              TextSpan(
                text: '"${med.name}"',
                style: const TextStyle(fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
              const TextSpan(text: '?\n\nEsta ação não pode ser desfeita.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              MockMedicationService.instance.delete(med.id);
              Navigator.pop(context);
              setState(_load);
            },
            child: const Text('Excluir',
              style: TextStyle(color: Colors.white, fontSize: 16))),
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
        title: const Text('Meus Remédios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: AppTextStyles.labelLarge,
            unselectedLabelStyle: AppTextStyles.labelMedium,
            tabs: [
              Tab(text: 'Ativos (${_active.length})'),
              Tab(text: 'Encerrados (${_inactive.length})'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Ativos ──────────────────────────────────────
          _active.isEmpty
              ? _buildEmpty(
                  'Nenhum remédio ativo',
                  'Toque em "Adicionar" para cadastrar\num novo medicamento.',
                )
              : _buildList(_active, showActions: true),

          // ── Encerrados ──────────────────────────────────
          _inactive.isEmpty
              ? _buildEmpty(
                  'Nenhum remédio encerrado',
                  'Remédios com período finalizado\naparecerão aqui.',
                )
              : _buildList(_inactive, showActions: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        elevation: 3,
        icon: const Icon(Icons.add, color: AppColors.white, size: 24),
        label: Text('Adicionar', style: AppTextStyles.buttonMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildList(List<Medication> list, {required bool showActions}) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _MedCard(
        med: list[i],
        showActions: showActions,
        onEdit: () => _openForm(med: list[i]),
        onDelete: () => _confirmDelete(list[i]),
      ),
    );
  }

  Widget _buildEmpty(String title, String subtitle) {
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
              child: const Icon(Icons.medication_outlined,
                color: AppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            Text(title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ── Card de medicamento ───────────────────────────────────────────────────────
class _MedCard extends StatelessWidget {
  final Medication med;
  final bool showActions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedCard({
    required this.med,
    required this.showActions,
    required this.onEdit,
    required this.onDelete,
  });

  int get _daysRemaining {
    if (med.endDate == null) return -1;
    return med.endDate!.difference(DateTime.now()).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysRemaining;
    final isEnding = days >= 0 && days <= 3;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEnding ? AppColors.warning.withOpacity(0.4) : AppColors.divider,
          width: isEnding ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cabeçalho ──────────────────────────────
                Row(
                  children: [
                    // Ícone
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.medication_rounded,
                        color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(med.name,
                            style: AppTextStyles.headlineSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(med.dosage,
                            style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),

                    // Badge status
                    _StatusBadge(daysRemaining: days),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Chips de info ───────────────────────────
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.repeat_rounded,
                      label: med.frequency),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: med.times.join(' · ')),
                    if (med.endDate != null)
                      _InfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: med.periodLabel),
                  ],
                ),

                // Aviso de encerrando em breve
                if (isEnding && days >= 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3))),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        days == 0
                            ? 'Último dia do tratamento!'
                            : 'Encerra em $days ${days == 1 ? 'dia' : 'dias'}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.warning)),
                    ]),
                  ),
                ],

                // Observações
                if (med.observations.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes_rounded,
                        color: AppColors.textHint, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(med.observations,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Ações ────────────────────────────────────────
          if (showActions) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text('Editar',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary)),
                    ),
                  ),
                  Container(
                    width: 1, height: 24,
                    color: AppColors.divider),
                  Expanded(
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text('Excluir',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.error)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final int daysRemaining;
  const _StatusBadge({required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    if (daysRemaining < 0) {
      return _badge('Em uso', AppColors.success, AppColors.successLight);
    }
    if (daysRemaining == 0) {
      return _badge('Último dia', AppColors.warning, AppColors.warningLight);
    }
    if (daysRemaining <= 3) {
      return _badge('$daysRemaining dias', AppColors.warning, AppColors.warningLight);
    }
    return _badge('Ativo', AppColors.success, AppColors.successLight);
  }

  Widget _badge(String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20)),
      child: Text(label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}