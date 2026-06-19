import '../models/exam.dart';
import '../../history/mock/mock_history_service.dart';
import '../../history/models/history_item.dart';
import '../../notifications/mock/mock_notification_service.dart';

// ════════════════════════════════════════════════════════════
//  MOCK EXAM SERVICE
//  Arquivo: lib/features/exams/mock/mock_exam_service.dart
//
//  • Dados por usuário
//  • Novo usuário inicia sem exames
//  • Ações sincronizam com histórico e notificações
// ════════════════════════════════════════════════════════════

class MockExamService {
  MockExamService._();
  static final MockExamService instance = MockExamService._();

  final Map<String, List<Exam>> _data = {};
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

  List<Exam> _list() {
    if (_currentUser == null) return [];
    return _data[_currentUser!] ?? [];
  }

  // ── Queries ──────────────────────────────────────────────

  List<Exam> getScheduled() =>
      _list().where((e) => e.status == ExamStatus.scheduled).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  List<Exam> getAll() => List.from(_list());

  // ── Mutações base ────────────────────────────────────────

  void add(Exam e) {
    _list().add(e);
    if (e.type == ExamType.consultation) {
      MockNotificationService.instance.addConsultationScheduled(e.name);
    } else {
      MockNotificationService.instance.addExamScheduled(e.name);
    }
  }

  void update(Exam updated) {
    final list = _list();
    final i = list.indexWhere((e) => e.id == updated.id);
    if (i != -1) list[i] = updated;
  }

  void delete(String id) => _list().removeWhere((e) => e.id == id);

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  // ── Ações com sync completo ──────────────────────────────

  void markCompleted(Exam exam) {
    exam.status = ExamStatus.completed;
    update(exam);

    final isConsultation = exam.type == ExamType.consultation;

    // Histórico
    MockHistoryService.instance.add(HistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: exam.name,
      category: isConsultation
          ? HistoryCategory.exam
          : HistoryCategory.exam,
      action: HistoryAction.completed,
      dateTime: DateTime.now(),
      details: exam.location.isNotEmpty ? exam.location : exam.doctor,
    ));

    // Notificações
    if (isConsultation) {
      MockNotificationService.instance.addConsultationCompleted(exam.name);
    } else {
      MockNotificationService.instance.addExamCompleted(exam.name);
    }
  }

  void markCancelled(Exam exam) {
    exam.status = ExamStatus.cancelled;
    update(exam);

    final isConsultation = exam.type == ExamType.consultation;

    MockHistoryService.instance.add(HistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: exam.name,
      category: HistoryCategory.exam,
      action: HistoryAction.cancelled,
      dateTime: DateTime.now(),
      details: exam.location.isNotEmpty ? exam.location : exam.doctor,
    ));

    if (isConsultation) {
      MockNotificationService.instance.addConsultationCancelled(exam.name);
    } else {
      MockNotificationService.instance.addExamCancelled(exam.name);
    }
  }

  void markRescheduled(Exam exam) {
    final isConsultation = exam.type == ExamType.consultation;
    if (isConsultation) {
      MockNotificationService.instance
          .addConsultationRescheduled(exam.name);
    } else {
      MockNotificationService.instance.addExamRescheduled(exam.name);
    }
  }

  void markNotAttended(Exam exam) {
    exam.status = ExamStatus.cancelled;
    update(exam);

    MockHistoryService.instance.add(HistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: exam.name,
      category: HistoryCategory.exam,
      action: HistoryAction.cancelled,
      dateTime: DateTime.now(),
      details: 'Não compareceu',
    ));

    MockNotificationService.instance.addConsultationCancelled(exam.name);
  }
}
