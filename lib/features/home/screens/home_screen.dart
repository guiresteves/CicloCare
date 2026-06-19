import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/medication.dart';
import '../mock/mock_medication_service.dart';
import '../../auth/mock/mock_auth_service.dart';
import '../../notifications/mock/mock_notification_service.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../main/main_screen.dart';
import '../../exams/models/exam.dart';
import '../../exams/mock/mock_exam_service.dart';
import '../../exams/screens/exam_dose_card.dart';
import '../../exams/screens/exam_action_modal.dart';
import 'medication_dose_card.dart';
import 'dose_action_modal.dart';
import 'dose_entry.dart';


// GlobalKey público — MainScreen usa para chamar reload()
final homeScreenKey = GlobalKey<HomeScreenState>();

class _Activity {
  final DoseEntry? dose;
  final Exam? exam;

  _Activity.medication(this.dose) : exam = null;
  _Activity.exam(this.exam) : dose = null;

  bool get isExam => exam != null;
  String get time => isExam ? exam!.time : dose!.time;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const List<String> _monthNames = [
    '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
  ];
  static const List<String> _weekNames = [
    '', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
  ];

  late String _userName;
  late List<DateTime> _calendarDays;
  int _selectedDayIndex = 0;
  late List<_Activity> _activities;

  @override
  void initState() {
    super.initState();
    _userName = MockAuthService.instance.loggedUser?['name'] ?? 'Usuário';
    _calendarDays =
        List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
    _loadDoses();
  }

  DateTime get _selectedDay => _calendarDays[_selectedDayIndex];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Chamado pelo MainScreen sempre que a aba Home é selecionada
  void reload() {
    if (mounted) setState(_loadDoses);
  }

  void _loadDoses() {
    final meds = MockMedicationService.instance.getActiveOn(_selectedDay);
    final doseList = <DoseEntry>[];
    for (final med in meds) {
      for (final time in med.times) {
        doseList.add(DoseEntry(med: med, time: time));
      }
    }

    // Usa getAll() (não getScheduled()) para que exames já concluídos
    // ou cancelados continuem aparecendo no dia e contando no progresso.
    final examList = MockExamService.instance
        .getAll()
        .where((e) => _isSameDay(e.scheduledDate, _selectedDay))
        .toList();

    _activities = [
      ...doseList.map((d) => _Activity.medication(d)),
      ...examList.map((e) => _Activity.exam(e)),
    ]..sort((a, b) => a.time.compareTo(b.time));
  }

  int get _totalDoses => _activities.length;

  int get _doneDoses => _activities.where((a) {
        if (a.isExam) {
          final s = a.exam!.status;
          return s == ExamStatus.completed || s == ExamStatus.cancelled;
        }
        final s = a.dose!.med.statusFor(_selectedDay, a.dose!.time);
        return s == MedicationStatus.taken || s == MedicationStatus.skipped;
      }).length;

  double get _progress => _totalDoses == 0 ? 0 : _doneDoses / _totalDoses;

  List<_Activity> _activitiesForPeriod(String period) =>
      _activities.where((a) => Medication.periodOf(a.time) == period).toList();

  String _periodSubtitle(List<_Activity> items) {
    final hasOnlyMeds = items.every((a) => !a.isExam);
    final count = items.length;
    if (hasOnlyMeds) {
      return count == 1 ? '1 dose programada' : '$count doses programadas';
    }
    return count == 1 ? '1 item programado' : '$count itens programados';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
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
                if (_activities.isEmpty)
                  _buildEmptyState()
                else ...[
                  _buildPeriodSection('Manhã', Icons.wb_sunny_outlined,
                      AppColors.morning, AppColors.morningLight),
                  _buildPeriodSection('Tarde', Icons.wb_cloudy_outlined,
                      AppColors.afternoon, AppColors.afternoonLight),
                  _buildPeriodSection('Noite', Icons.nights_stay_outlined,
                      AppColors.night, AppColors.nightLight),
                ],
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    final unread = MockNotificationService.instance.unreadCount;
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
          child: Column(children: [
            Row(children: [
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
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 2),
                    Text(_userName,
                        style: AppTextStyles.headlineMedium
                            .copyWith(color: AppColors.white)),
                  ],
                ),
              ),
              // Notificações
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ).then((_) => setState(() {})),
                child: Stack(clipBehavior: Clip.none, children: [
                  _headerBtn(Icons.notifications_outlined),
                  if (unread > 0)
                    Positioned(
                      top: -2, right: -2,
                      child: Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
              const SizedBox(width: 8),
              // Configurações → Perfil
              GestureDetector(
                onTap: () => context
                    .findAncestorStateOfType<MainScreenState>()
                    ?.navigateTo(4),
                child: _headerBtn(Icons.settings_outlined),
              ),
            ]),
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
                  final hasDoses = MockMedicationService.instance
                      .getActiveOn(date)
                      .isNotEmpty;

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
                      child: Stack(alignment: Alignment.center, children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_monthNames[date.month],
                                style: TextStyle(
                                    color: selected
                                        ? AppColors.white
                                        : AppColors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(date.day.toString(),
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w600)),
                            Text(
                                isToday ? 'Hoje' : _weekNames[date.weekday],
                                style: TextStyle(
                                    color: selected
                                        ? AppColors.white
                                        : AppColors.white.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
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
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
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

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Atividades do Dia', style: AppTextStyles.headlineSmall),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$_doneDoses de $_totalDoses',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 12,
            backgroundColor: AppColors.inputBg,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(_progress * 100).toStringAsFixed(0)}% concluído',
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.textSecondary, fontSize: 14),
        ),
      ]),
    );
  }

  Widget _buildPeriodSection(
      String period, IconData icon, Color color, Color bgColor) {
    final items = _activitiesForPeriod(period);
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(period,
                style: AppTextStyles.sectionTitle.copyWith(color: color)),
            const Spacer(),
            Text(_periodSubtitle(items),
                style: AppTextStyles.labelSmall.copyWith(color: color)),
          ]),
        ),
        const SizedBox(height: 10),
        ...items.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: a.isExam
                  ? ExamDoseCard(
                      exam: a.exam!,
                      onTap: () => _showExamAction(a.exam!),
                    )
                  : MedicationDoseCard(
                      dose: a.dose!,
                      selectedDay: _selectedDay,
                      onTap: () => _showDoseAction(a.dose!),
                    ),
            )),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(children: [
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
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  void _showDoseAction(DoseEntry d) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DoseActionModal(
        dose: d,
        selectedDay: _selectedDay,
        onAction: (_) => setState(_loadDoses),
      ),
    );
  }

  void _showExamAction(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExamActionModal(
        exam: exam,
        onAction: () => setState(_loadDoses),
      ),
    );
  }
}
