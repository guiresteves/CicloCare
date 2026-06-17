import '../models/medication.dart';
import '../../history/mock/mock_history_service.dart';
import '../../history/models/history_item.dart';
import '../../notifications/mock/mock_notification_service.dart';

// ════════════════════════════════════════════════════════════
//  MOCK MEDICATION SERVICE — CicloCare
//  Arquivo: lib/features/home/mock/mock_medication_service.dart
//
//  • Dados por usuário (email como chave)
//  • Novo usuário inicia com lista vazia
//  • Ações sincronizam com histórico e notificações
// ════════════════════════════════════════════════════════════

class MockMedicationService {
  MockMedicationService._();
  static final MockMedicationService instance = MockMedicationService._();

  // Mapa userEmail → lista de medicamentos
  final Map<String, List<Medication>> _data = {};
  String? _currentUser;

  // ── Ciclo de vida do usuário ─────────────────────────────

  void setUser(String email) {
    _currentUser = email;
    _data.putIfAbsent(email, () => []);
  }

  void clearUser() => _currentUser = null;

  void deleteUser(String email) {
    _data.remove(email);
    if (_currentUser == email) _currentUser = null;
  }

  // ── Acesso interno ───────────────────────────────────────

  final List<Medication> _guestList = [];

  List<Medication> _list() {
    if (_currentUser == null) return _guestList;
    return _data[_currentUser!] ?? [];
  }

  // ── Queries ──────────────────────────────────────────────

  List<Medication> getAll() => List.from(_list());

  List<Medication> getActiveOn(DateTime day) =>
      _list().where((m) => m.isActiveOn(day)).toList();

  List<Medication> getByCategory(MedicationCategory category) =>
      _list().where((m) => m.category == category).toList();

  List<Medication> getActiveMedications() {
    final now = DateTime.now();
    return _list().where((m) =>
      m.category == MedicationCategory.remedio &&
      (m.endDate == null ||
          !m.endDate!.isBefore(
              DateTime(now.year, now.month, now.day)))).toList();
  }

  Medication? getById(String id) {
    try {
      return _list().firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Mutações ─────────────────────────────────────────────

  void add(Medication m) {
    print('===== ADD =====');
    print('currentUser: $_currentUser');

    final list = _list();

    print('antes: ${list.length}');

    list.add(m);

    print('depois: ${list.length}');
  }

  void update(Medication updated) {
    final list = _list();
    final i = list.indexWhere((m) => m.id == updated.id);
    if (i != -1) {
      list[i] = updated;
      MockNotificationService.instance.addMedicationEdited(updated.name);
    }
  }

  void delete(String id) {
    final list = _list();
    final med = list.firstWhere((m) => m.id == id,
        orElse: () => Medication(
            id: '', name: '', dosage: '', frequency: '',
            timesPerDay: 0, times: [], type: ''));
    if (med.id.isNotEmpty) {
      MockNotificationService.instance.addMedicationRemoved(med.name);
    }
    list.removeWhere((m) => m.id == id);
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // ── Registra ação de dose com sync ───────────────────────

  /// Chame este método ao confirmar tomada/pulada para
  /// sincronizar histórico e notificações.
  void recordDoseAction({
    required Medication med,
    required String time,
    required DateTime day,
    required MedicationStatus status,
  }) {
    // 1. Atualiza status no próprio medicamento
    med.setStatus(day, time, status);

    // 2. Histórico
    final action = status == MedicationStatus.taken
        ? HistoryAction.taken
        : HistoryAction.skipped;

    MockHistoryService.instance.add(HistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: med.name,
      category: med.category == MedicationCategory.exame
          ? HistoryCategory.exam
          : HistoryCategory.medication,
      action: action,
      dateTime: DateTime.now(),
      details: '${med.dosage} — $time',
    ));

    // 3. Notificações
    if (status == MedicationStatus.taken) {
      MockNotificationService.instance.addMedicationTaken(med.name);
    } else {
      MockNotificationService.instance.addMedicationSkipped(med.name);
    }
  }
}