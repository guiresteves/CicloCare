// ════════════════════════════════════════════════════════════
//  MODELO — Exam
//  Arquivo: lib/features/exams/models/exam.dart
// ════════════════════════════════════════════════════════════

enum ExamStatus { scheduled, completed, cancelled }
enum ExamType   { laboratorial, imaging, clinical, consultation }

class Exam {
  final String id;
  String name;
  ExamType type;
  ExamStatus status;
  DateTime scheduledDate;
  String time;
  String location;
  String doctor;
  String observations;
  String? resultPath; // caminho do arquivo de resultado (PDF/imagem)
  DateTime createdAt;

  Exam({
    required this.id,
    required this.name,
    required this.type,
    required this.scheduledDate,
    required this.time,
    this.status       = ExamStatus.scheduled,
    this.location     = '',
    this.doctor       = '',
    this.observations = '',
    this.resultPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ── Helpers ──────────────────────────────────────────────

  bool get isPast => scheduledDate.isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year  == now.year &&
           scheduledDate.month == now.month &&
           scheduledDate.day   == now.day;
  }

  String get formattedDate {
    return '${scheduledDate.day.toString().padLeft(2,'0')}/'
        '${scheduledDate.month.toString().padLeft(2,'0')}/'
        '${scheduledDate.year}';
  }

  String get typeLabel {
    switch (type) {
      case ExamType.laboratorial:  return 'Laboratorial';
      case ExamType.imaging:       return 'Imagem';
      case ExamType.clinical:      return 'Clínico';
      case ExamType.consultation:  return 'Consulta';
    }
  }

  String get statusLabel {
    switch (status) {
      case ExamStatus.scheduled:   return 'Agendado';
      case ExamStatus.completed:   return 'Concluído';
      case ExamStatus.cancelled:   return 'Cancelado';
    }
  }

  bool get hasResult => resultPath != null && resultPath!.isNotEmpty;
}