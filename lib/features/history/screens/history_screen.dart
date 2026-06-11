import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/history_item.dart';
import '../mock/mock_history_service.dart';

// ════════════════════════════════════════════════════════════
//  HISTORY SCREEN
//  Arquivo: lib/features/history/screens/history_screen.dart
// ════════════════════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Filtros
  int _periodIndex   = 0; // 0=7d, 1=15d, 2=30d, 3=custom
  HistoryCategory? _category; // null=todos
  DateTime? _customFrom;
  DateTime? _customTo;

  static const _periods    = ['7 dias', '15 dias', '30 dias', 'Período'];
  static const _periodDays = [7, 15, 30, -1];

  List<HistoryItem> get _items {
    int? days = _periodDays[_periodIndex] > 0 ? _periodDays[_periodIndex] : null;
    return MockHistoryService.instance.getFiltered(
      category: _category,
      lastDays: days,
      from: _periodIndex == 3 ? _customFrom : null,
      to:   _periodIndex == 3 ? _customTo   : null,
    );
  }

  // Agrupa items por data
  Map<String, List<HistoryItem>> get _grouped {
    final items = _items;
    final map = <String, List<HistoryItem>>{};
    for (final item in items) {
      final key = item.formattedDate;
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final keys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Histórico')),
      body: Column(
        children: [
          // ── Filtros de período ───────────────────────────
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _periods.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final sel = i == _periodIndex;
                      return GestureDetector(
                        onTap: () async {
                          if (i == 3) await _pickCustomPeriod();
                          setState(() => _periodIndex = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.inputBg,
                            borderRadius: BorderRadius.circular(20)),
                          alignment: Alignment.center,
                          child: Text(_periods[i],
                            style: AppTextStyles.labelMedium.copyWith(
                              color: sel ? AppColors.white : AppColors.textSecondary,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Filtro de categoria
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _catChip(null, 'Todos'),
                      const SizedBox(width: 8),
                      _catChip(HistoryCategory.medication, '💊 Remédios'),
                      const SizedBox(width: 8),
                      _catChip(HistoryCategory.exam, '🔬 Exames'),
                      const SizedBox(width: 8),
                      _catChip(HistoryCategory.consultation, '🩺 Consultas'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Resumo
          if (_items.isNotEmpty)
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(children: [
                _StatChip(
                  label: 'Total',
                  value: _items.length.toString(),
                  color: AppColors.primary),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Tomados',
                  value: _items.where((i) =>
                    i.action == HistoryAction.taken ||
                    i.action == HistoryAction.completed).length.toString(),
                  color: AppColors.success),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Pulados',
                  value: _items.where((i) =>
                    i.action == HistoryAction.skipped).length.toString(),
                  color: AppColors.warning),
              ]),
            ),

          const Divider(height: 1),

          // Lista agrupada
          Expanded(
            child: _items.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: keys.length,
                    itemBuilder: (_, i) {
                      final date  = keys[i];
                      final items = grouped[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (i > 0) const SizedBox(height: 20),
                          // Header de data
                          Text(date,
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HistoryCard(item: item),
                          )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _catChip(HistoryCategory? cat, String label) {
    final sel = _category == cat;
    return GestureDetector(
      onTap: () => setState(() => _category = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.inputBg,
          borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(
          color: sel ? AppColors.white : AppColors.textSecondary,
          fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 80, height: 80,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight, shape: BoxShape.circle),
        child: const Icon(Icons.history_rounded,
          color: AppColors.primary, size: 40)),
      const SizedBox(height: 16),
      Text('Nenhum registro encontrado',
        style: AppTextStyles.headlineSmall),
      const SizedBox(height: 8),
      Text('Tente alterar os filtros acima.',
        style: AppTextStyles.bodyMedium),
    ]),
  );

  Future<void> _pickCustomPeriod() async {
    DateTime? from, to;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar',
                    style: TextStyle(color: CupertinoColors.systemRed))),
                const Text('Selecionar período',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() { _customFrom = from; _customTo = to; });
                    Navigator.pop(ctx);
                  },
                  child: const Text('OK',
                    style: TextStyle(color: AppColors.primary,
                      fontWeight: FontWeight.w600))),
              ]),
          ),
          SizedBox(
            height: 260,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: DateTime.now().subtract(const Duration(days: 30)),
              maximumDate: DateTime.now(),
              onDateTimeChanged: (d) => from = d)),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ]),
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
      Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
    ]),
  );
}

// ── History Card ──────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  const _HistoryCard({required this.item});

  Color get _actionColor {
    switch (item.action) {
      case HistoryAction.taken:
      case HistoryAction.completed:
      case HistoryAction.scheduled:
        return AppColors.success;
      case HistoryAction.skipped:   return AppColors.warning;
      case HistoryAction.cancelled: return AppColors.error;
    }
  }

  IconData get _categoryIcon {
    switch (item.category) {
      case HistoryCategory.medication:   return Icons.medication_rounded;
      case HistoryCategory.exam:         return Icons.science_rounded;
      case HistoryCategory.consultation: return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        // Ícone
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _actionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(_categoryIcon, color: _actionColor, size: 22)),
        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: AppTextStyles.cardTitle),
            if (item.details.isNotEmpty)
              Text(item.details, style: AppTextStyles.cardSubtitle),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.access_time_rounded,
                size: 12, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(item.formattedTime,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              const SizedBox(width: 10),
              Text(item.categoryLabel,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
            ]),
          ]),
        ),

        // Ação badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _actionColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
          child: Text(item.actionLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: _actionColor, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
