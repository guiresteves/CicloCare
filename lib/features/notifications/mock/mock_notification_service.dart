import '../models/notification_item.dart';

// ════════════════════════════════════════════════════════════
//  MOCK NOTIFICATION SERVICE
//  Arquivo: lib/features/notifications/mock/mock_notification_service.dart
//
//  • Dados por usuário (email como chave)
//  • Novo usuário inicia sem notificações
//  • Adiciona notificações via add() chamado pelas demais ações
// ════════════════════════════════════════════════════════════

class MockNotificationService {
  MockNotificationService._();
  static final MockNotificationService instance = MockNotificationService._();

  // Mapa userEmail → lista de notificações
  final Map<String, List<NotificationItem>> _data = {};
  String? _currentUser;

  // ── Ciclo de vida do usuário ─────────────────────────────

  void setUser(String email) {
    _currentUser = email;
    // Se for a primeira vez desse usuário, inicia vazio
    _data.putIfAbsent(email, () => []);
  }

  void clearUser() => _currentUser = null;

  void deleteUser(String email) {
    _data.remove(email);
    if (_currentUser == email) _currentUser = null;
  }

  // ── Acesso ───────────────────────────────────────────────

  List<NotificationItem> _list() {
    if (_currentUser == null) return [];
    return _data[_currentUser!] ?? [];
  }

  List<NotificationItem> getAll({bool newestFirst = true}) {
    final list = List<NotificationItem>.from(_list());
    list.sort((a, b) => newestFirst
        ? b.dateTime.compareTo(a.dateTime)
        : a.dateTime.compareTo(b.dateTime));
    return list;
  }

  int get unreadCount => _list().where((n) => !n.isRead).length;

  // ── Mutações ─────────────────────────────────────────────

  void add(NotificationItem item) {
    if (_currentUser == null) return;
    _data[_currentUser!]!.insert(0, item);
  }

  void markRead(String id) {
    for (final n in _list()) {
      if (n.id == id) {
        n.isRead = true;
        return;
      }
    }
  }

  void markAllRead() {
    for (final n in _list()) {
      n.isRead = true;
    }
  }

  void delete(String id) {
    _data[_currentUser!]?.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    _data[_currentUser!]?.clear();
  }

  // ── Helpers de criação ───────────────────────────────────

  String _genId() => DateTime.now().microsecondsSinceEpoch.toString();

  void addMedicationTaken(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.medication,
        action: NotificationAction.medicationTaken,
        title: 'Medicamento tomado',
        description: '$name foi marcado como tomado.',
        dateTime: DateTime.now(),
      ));

  void addMedicationSkipped(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.medication,
        action: NotificationAction.medicationSkipped,
        title: 'Medicamento pulado',
        description: '$name foi pulado neste horário.',
        dateTime: DateTime.now(),
      ));

  void addMedicationAdded(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.medication,
        action: NotificationAction.medicationAdded,
        title: 'Medicamento cadastrado',
        description: '$name foi adicionado à sua lista.',
        dateTime: DateTime.now(),
      ));

  void addMedicationEdited(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.medication,
        action: NotificationAction.medicationEdited,
        title: 'Medicamento atualizado',
        description: '$name foi editado com sucesso.',
        dateTime: DateTime.now(),
      ));

  void addMedicationRemoved(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.medication,
        action: NotificationAction.medicationRemoved,
        title: 'Medicamento removido',
        description: '$name foi removido da sua lista.',
        dateTime: DateTime.now(),
      ));

  void addExamScheduled(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.exam,
        action: NotificationAction.examScheduled,
        title: 'Exame agendado',
        description: '$name foi agendado com sucesso.',
        dateTime: DateTime.now(),
      ));

  void addExamCompleted(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.exam,
        action: NotificationAction.examCompleted,
        title: 'Exame realizado',
        description: '$name foi marcado como realizado.',
        dateTime: DateTime.now(),
      ));

  void addExamCancelled(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.exam,
        action: NotificationAction.examCancelled,
        title: 'Exame cancelado',
        description: '$name foi cancelado.',
        dateTime: DateTime.now(),
      ));

  void addExamRescheduled(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.exam,
        action: NotificationAction.examRescheduled,
        title: 'Exame reagendado',
        description: '$name foi reagendado.',
        dateTime: DateTime.now(),
      ));

  void addConsultationScheduled(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.consultation,
        action: NotificationAction.consultationScheduled,
        title: 'Consulta agendada',
        description: '$name foi agendada com sucesso.',
        dateTime: DateTime.now(),
      ));

  void addConsultationCompleted(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.consultation,
        action: NotificationAction.consultationCompleted,
        title: 'Consulta realizada',
        description: 'Presença em $name confirmada.',
        dateTime: DateTime.now(),
      ));

  void addConsultationCancelled(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.consultation,
        action: NotificationAction.consultationCancelled,
        title: 'Consulta cancelada',
        description: '$name foi cancelada.',
        dateTime: DateTime.now(),
      ));

  void addConsultationRescheduled(String name) => add(NotificationItem(
        id: _genId(),
        category: NotificationCategory.consultation,
        action: NotificationAction.consultationRescheduled,
        title: 'Consulta reagendada',
        description: '$name foi reagendada.',
        dateTime: DateTime.now(),
      ));
}
