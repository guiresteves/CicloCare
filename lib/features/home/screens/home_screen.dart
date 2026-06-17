import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/medication.dart';
import '../mock/mock_medication_service.dart';
import '../../auth/mock/mock_auth_service.dart';
import 'medication_dose_card.dart';
import 'dose_action_modal.dart';
import 'dose_entry.dart';

// ════════════════════════════════════════════════════════════
//  HOME SCREEN — CicloCare
//  Arquivo: lib/features/home/screens/home_screen.dart
//
//  Alteração 2:
//  - Removido subtítulo fixo "X doses" (não fazia sentido
//    para exames/consultas).
//  - Substituído por "X atividade(s)" / "X item(ns) programado(s)".
//  - Cards usam ícones diferentes por categoria
//    (ver medication_dose_card.dart).
// ════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _monthNames = [
    '','Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'
  ];
  static const List<String> _weekNames = [
    '','Seg','Ter','Qua','Qui','Sex','Sáb','Dom'
  ];

  late String _userName;
  late List<DateTime> _calendarDays;
  int _selectedDayIndex = 0;

  late List<DoseEntry> _doses;

  @override
  void initState() {
    super.initState();
    _userName     = MockAuthService.instance.loggedUser?['name'] ?? 'Usuário';
    _calendarDays = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
    _loadDoses();
  }

  DateTime get _selectedDay => _calendarDays[_selectedDayIndex];

  void _loadDoses() {
    final meds = MockMedicationService.instance.getActiveOn(_selectedDay);
    _doses = [];
    for (final med in meds) {
      for (final time in med.times) {
        _doses.add(DoseEntry(med: med, time: time));
      }
    }
    _doses.sort((a, b) => a.time.compareTo(b.time));
  }

  // ── Progresso ────────────────────────────────────────────
  int get _totalDoses => _doses.length;
  int get _doneDoses  => _doses.where((d) =>
      d.med.statusFor(_selectedDay, d.time) == MedicationStatus.taken ||
      d.med.statusFor(_selectedDay, d.time) == MedicationStatus.skipped).length;

  double get _progress => _totalDoses == 0 ? 0 : _doneDoses / _totalDoses;

  // ── Filtra doses por período ─────────────────────────────
  List<DoseEntry> _dosesForPeriod(String period) =>
      _doses.where((d) => Medication.periodOf(d.time) == period).toList();

  /// Texto do subtítulo da seção, considerando se há mistura
  /// de medicamentos e exames/consultas no período
  String _periodSubtitle(List<DoseEntry> doses) {
    final hasOnlyMeds = doses.every(
        (d) => d.med.category == MedicationCategory.remedio);
    final count = doses.length;

    if (hasOnlyMeds) {
      // Todos são medicamentos → pode falar "doses"
      return count == 1 ? '1 dose programada' : '$count doses programadas';
    }
    // Mistura de medicamentos, exames e/ou consultas
    return count == 1 ? '1 item programado' : '$count itens programados';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => setState(_loadDoses),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                children: [
                  _buildProgressSection(),
                  const SizedBox(height: 24),
                  if (_doses.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildPeriodSection('Manhã', Icons.wb_sunny_outlined, AppColors.morning, AppColors.morningLight),
                    _buildPeriodSection('Tarde', Icons.wb_cloudy_outlined, AppColors.afternoon, AppColors.afternoonLight),
                    _buildPeriodSection('Noite', Icons.nights_stay_outlined, AppColors.night, AppColors.nightLight),
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
  //  HEADER
  // ════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.white.withOpacity(0.25),
                    child: const Icon(Icons.person_rounded,
                      color: AppColors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TITULAR',
                          style: TextStyle(
                            color: Colors.white70, fontSize: 11,
                            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text(_userName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.white)),
                      ],
                    ),
                  ),
                  _headerBtn(Icons.notifications_outlined),
                  const SizedBox(width: 8),
                  _headerBtn(Icons.settings_outlined),
                ],
              ),

              const SizedBox(height: 22),

              SizedBox(
                height: 86,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _calendarDays.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final selected = i == _selectedDayIndex;
                    final date = _calendarDays[i];
                    final isToday = i == 0;

                    final meds = MockMedicationService.instance.getActiveOn(date);
                    final hasDoses = meds.isNotEmpty;

                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedDayIndex = i;
                        _loadDoses();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 58,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.white.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _monthNames[date.month],
                                  style: TextStyle(
                                    color: selected ? AppColors.white : AppColors.white.withOpacity(0.7),
                                    fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: selected ? FontWeight.w900 : FontWeight.w600),
                                ),
                                Text(
                                  isToday ? 'Hoje' : _weekNames[date.weekday],
                                  style: TextStyle(
                                    color: selected ? AppColors.white : AppColors.white.withOpacity(0.7),
                                    fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (hasDoses)
                              Positioned(
                                top: 6, right: 8,
                                child: Container(
                                  width: 6, height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerBtn(IconData icon) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: AppColors.white.withOpacity(0.2),
      shape: BoxShape.circle),
    child: Icon(icon, color: AppColors.white, size: 24),
  );

  // ════════════════════════════════════════════════════════
  //  PROGRESS
  // ════════════════════════════════════════════════════════
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Atividades do Dia',
                style: AppTextStyles.headlineSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_doneDoses de $_totalDoses',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: AppColors.inputBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).toStringAsFixed(0)}% concluído',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  SEÇÃO POR PERÍODO
  // ════════════════════════════════════════════════════════
  Widget _buildPeriodSection(
      String period, IconData icon, Color color, Color bgColor) {
    final doses = _dosesForPeriod(period);
    if (doses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho do período
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(period,
                style: AppTextStyles.sectionTitle.copyWith(color: color)),
              const Spacer(),
              // Subtítulo dinâmico — sem mencionar "dose" para
              // grupos que misturam exames/consultas
              Text(_periodSubtitle(doses),
                style: AppTextStyles.labelSmall.copyWith(color: color)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Cards
        ...doses.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MedicationDoseCard(
            dose: d,
            selectedDay: _selectedDay,
            onTap: () => _showDoseAction(d),
          ),
        )),
        const SizedBox(height: 14),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  ESTADO VAZIO
  // ════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Container(
              width: 90, height: 90,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.event_available_rounded,
                color: AppColors.primary, size: 46),
            ),
            const SizedBox(height: 20),
            Text('Nenhuma atividade\npara este dia',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text('Selecione outro dia no calendário.',
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MODAL DE AÇÃO
  // ════════════════════════════════════════════════════════
  void _showDoseAction(DoseEntry d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DoseActionModal(
        dose: d,
        selectedDay: _selectedDay,
        onAction: (status) {
          d.med.setStatus(_selectedDay, d.time, status);
          setState(() {});
        },
      ),
    );
  }
}