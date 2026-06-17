import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/history_item.dart';
import '../mock/mock_history_service.dart';

// ════════════════════════════════════════════════════════════
//  HISTORY SCREEN — CicloCare
//  Arquivo: lib/features/history/screens/history_screen.dart
//
//  Alteração 5:
//  • Timeline médica moderna
//  • Filtros por categoria: Todos / Medicamentos / Exames
//  • Filtros por período: Hoje / 7 dias / 30 dias / Personalizado
//  • Ordenação: Mais recentes / Mais antigos
//  • Cards modernos com ícone, status e detalhe
// ════════════════════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── Filtros ──────────────────────────────────────────────
  HistoryCategory? _category; // null = todos
  int _periodIndex  = 1;      // 0=hoje, 1=7d, 2=30d, 3=custom
  bool _newestFirst = true;

  DateTime? _customFrom;
  DateTime? _customTo;

  static const _periodLabels = ['Hoje', '7 dias', '30 dias', 'Personalizado'];
  static const _periodDays   = [0, 7, 30, -1];

  List<HistoryItem> get _items {
    final p = _periodDays[_periodIndex];
    DateTime? from, to;

    if (p == 0) {
      // Hoje
      final now = DateTime.now();
      from = DateTime(now.year, now.month, now.day);
    } else if (p > 0) {
      from = DateTime.now().subtract(Duration(days: p));
    } else if (_periodIndex == 3) {
      from = _customFrom;
      to   = _customTo;
    }

    return MockHistoryService.instance.getFiltered(
      category: _category,
      from: from,
      to: to,
      newestFirst: _newestFirst,
    );
  }

  // Agrupa por data formatada
  Map<String, List<HistoryItem>> get _grouped {
    final map = <String, List<HistoryItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.formattedDate, () => []).add(item);
    }
    return map;
  }

  // ── Estatísticas do período filtrado ─────────────────────
  int get _totalCount  => _items.length;
  int get _takenCount  => _items.where((i) => i.isPositive).length;
  int get _skippedCount=> _items.where((i) =>
      i.action == HistoryAction.skipped ||
      i.action == HistoryAction.cancelled).length;

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final dates   = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('Histórico'),
        actions: [
          // Ordenação
          IconButton(
            tooltip: _newestFirst ? 'Mais recentes' : 'Mais antigos',
            icon: Icon(
              _newestFirst
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: AppColors.primary),
            onPressed: () => setState(() => _newestFirst = !_newestFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de filtros ──────────────────────────────
          _buildFilterBar(),

          // ── Resumo ────────────────────────────────────────
          if (_totalCount > 0) _buildSummary(),

          const Divider(height: 1),

          // ── Lista / Vazio ─────────────────────────────────
          Expanded(
            child: _items.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: dates.length,
                    itemBuilder: (_, i) {
                      final date  = dates[i];
                      final items = grouped[date]!;
                      return _buildDayGroup(date, items, i, dates.length);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BARRA DE FILTROS
  // ════════════════════════════════════════════════════════
  Widget _buildFilterBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          // Filtro de período
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _periodLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final sel = i == _periodIndex;
                return GestureDetector(
                  onTap: () async {
                    if (i == 3) {
                      await _pickCustomPeriod();
                    }
                    setState(() => _periodIndex = i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.inputBg,
                      borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: Text(_periodLabels[i],
                      style: AppTextStyles.labelMedium.copyWith(
                        color: sel ? AppColors.white : AppColors.textSecondary,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Filtro de categoria
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _catChip(null, 'Todos', Icons.list_rounded),
                const SizedBox(width: 8),
                _catChip(HistoryCategory.medication, 'Medicamentos',
                  Icons.medication_rounded),
                const SizedBox(width: 8),
                _catChip(HistoryCategory.exam, 'Exames',
                  Icons.biotech_rounded),
              ],
            ),
          ),

          // Label período personalizado
          if (_periodIndex == 3 && _customFrom != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.date_range_rounded,
                  color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${_fmtDate(_customFrom!)} → ${_customTo != null ? _fmtDate(_customTo!) : 'agora'}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _catChip(HistoryCategory? cat, String label, IconData icon) {
    final sel = _category == cat;
    return GestureDetector(
      onTap: () => setState(() => _category = cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.inputBg,
          borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.center,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
            size: 14,
            color: sel ? AppColors.white : AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.labelMedium.copyWith(
            color: sel ? AppColors.white : AppColors.textSecondary,
            fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  RESUMO DE ESTATÍSTICAS
  // ════════════════════════════════════════════════════════
  Widget _buildSummary() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(children: [
        _statPill('$_totalCount', 'registros', AppColors.primary),
        const SizedBox(width: 8),
        _statPill('$_takenCount', 'concluídos', AppColors.success),
        const SizedBox(width: 8),
        _statPill('$_skippedCount', 'pulados', AppColors.warning),
      ]),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: AppTextStyles.labelLarge.copyWith(color: color)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  GRUPO POR DIA (timeline)
  // ════════════════════════════════════════════════════════
  Widget _buildDayGroup(String date, List<HistoryItem> items,
      int groupIndex, int totalGroups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groupIndex > 0) const SizedBox(height: 20),

        // Header de data
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(20)),
            child: Text(date,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: AppColors.divider)),
        ]),
        const SizedBox(height: 12),

        // Cards com linha do tempo
        ...items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1 &&
              groupIndex == totalGroups - 1;
          return _buildTimelineItem(e.value, isLast: isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(HistoryItem item, {bool isLast = false}) {
    final color = item.isPositive ? AppColors.success : AppColors.warning;
    final icon  = item.category == HistoryCategory.medication
        ? Icons.medication_rounded
        : Icons.biotech_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do tempo
          Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.3), blurRadius: 4),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(vertical: 4)),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03),
                      blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(children: [
                  // Ícone
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 22)),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(item.name,
                              style: AppTextStyles.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                          // Badge de ação
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.isPositive
                                  ? AppColors.successLight
                                  : AppColors.warningLight,
                              borderRadius: BorderRadius.circular(8)),
                            child: Text(item.actionLabel,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: item.isPositive
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.w700))),
                        ]),
                        const SizedBox(height: 4),
                        if (item.details.isNotEmpty)
                          Text(item.details,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.access_time_rounded,
                            size: 12, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text(item.formattedTime,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              borderRadius: BorderRadius.circular(6)),
                            child: Text(item.categoryLabel,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 10))),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  VAZIO
  // ════════════════════════════════════════════════════════
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.history_rounded,
                color: AppColors.primary, size: 40)),
            const SizedBox(height: 20),
            Text('Nenhum registro encontrado',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text('Tente alterar os filtros acima.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  PERÍODO PERSONALIZADO
  // ════════════════════════════════════════════════════════
  Future<void> _pickCustomPeriod() async {
    DateTime tempFrom = _customFrom ?? DateTime.now().subtract(
        const Duration(days: 7));
    DateTime tempTo   = _customTo   ?? DateTime.now();

    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                    style: TextStyle(color: CupertinoColors.systemRed,
                      fontSize: 17))),
                const Text('Período inicial',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      _customFrom = tempFrom;
                      _customTo   = tempTo;
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('OK',
                    style: TextStyle(color: AppColors.primary,
                      fontSize: 17, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: tempFrom,
              maximumDate: DateTime.now(),
              onDateTimeChanged: (d) => tempFrom = d)),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ]),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
}