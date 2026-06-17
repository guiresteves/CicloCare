import '../models/exam.dart';

// ════════════════════════════════════════════════════════════
//  MOCK EXAM SERVICE
//  Arquivo: lib/features/exams/mock/mock_exam_service.dart
// ════════════════════════════════════════════════════════════

class MockExamService {
  MockExamService._();
  static final MockExamService instance = MockExamService._();

  final List<Exam> _exams = [
    Exam(
      id: '1', name: 'Hemograma Completo',
      type: ExamType.laboratorial,
      status: ExamStatus.scheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      time: '07:00', location: 'Lab. Santa Clara',
      doctor: 'Dr. Roberto Alves',
      observations: 'Jejum de 8 horas obrigatório',
    ),
    Exam(
      id: '2', name: 'Glicemia em Jejum',
      type: ExamType.laboratorial,
      status: ExamStatus.scheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      time: '07:30', location: 'Lab. Santa Clara',
      doctor: 'Dr. Roberto Alves',
      observations: 'Jejum de 12 horas',
    ),
    Exam(
      id: '3', name: 'Raio-X de Tórax',
      type: ExamType.imaging,
      status: ExamStatus.scheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
      time: '09:00', location: 'Clínica Imagem Plus',
      doctor: 'Dra. Ana Paula',
    ),
    Exam(
      id: '4', name: 'Consulta Cardiologista',
      type: ExamType.consultation,
      status: ExamStatus.scheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 5)),
      time: '14:00', location: 'Clínica CardioVida',
      doctor: 'Dr. Carlos Mendes',
    ),
    Exam(
      id: '5', name: 'Consulta Clínico Geral',
      type: ExamType.consultation,
      status: ExamStatus.scheduled,
      scheduledDate: DateTime.now().add(const Duration(days: 12)),
      time: '10:00', location: 'UBS Centro',
      doctor: 'Dra. Fernanda Lima',
    ),
  ];

  /// Retorna apenas exames agendados (não concluídos/cancelados)
  List<Exam> getScheduled() =>
      _exams.where((e) => e.status == ExamStatus.scheduled).toList()
        ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  List<Exam> getAll() => List.from(_exams);

  void add(Exam e) => _exams.add(e);

  void update(Exam updated) {
    final i = _exams.indexWhere((e) => e.id == updated.id);
    if (i != -1) _exams[i] = updated;
  }

  void delete(String id) => _exams.removeWhere((e) => e.id == id);

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}