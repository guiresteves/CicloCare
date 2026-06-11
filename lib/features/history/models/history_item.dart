// ════════════════════════════════════════════════════════════
//  MODELO — HistoryItem
//  Arquivo: lib/features/history/models/history_item.dart
// ════════════════════════════════════════════════════════════

enum HistoryCategory { medication, exam, consultation }
enum HistoryAction   { taken, skipped, scheduled, completed, cancelled }

class HistoryItem {
  final String id;
  final String name;
  final HistoryCategory category;
  final HistoryAction action;
  final DateTime dateTime;
  final String details;      // dosagem, local, médico, etc.
  final String observations;

  const HistoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.action,
    required this.dateTime,
    this.details      = '',
    this.observations = '',
  });

  // ── Helpers ──────────────────────────────────────────────

  String get categoryLabel {
    switch (category) {
      case HistoryCategory.medication:   return 'Medicamento';
      case HistoryCategory.exam:         return 'Exame';
      case HistoryCategory.consultation: return 'Consulta';
    }
  }

  String get actionLabel {
    switch (action) {
      case HistoryAction.taken:       return 'Tomado';
      case HistoryAction.skipped:     return 'Pulado';
      case HistoryAction.scheduled:   return 'Agendado';
      case HistoryAction.completed:   return 'Concluído';
      case HistoryAction.cancelled:   return 'Cancelado';
    }
  }

  String get formattedDate {
    return '${dateTime.day.toString().padLeft(2,'0')}/'
        '${dateTime.month.toString().padLeft(2,'0')}/'
        '${dateTime.year}';
  }

  String get formattedTime =>
      '${dateTime.hour.toString().padLeft(2,'0')}:'
      '${dateTime.minute.toString().padLeft(2,'0')}';

  bool get isPositive =>
      action == HistoryAction.taken ||
      action == HistoryAction.completed ||
      action == HistoryAction.scheduled;
}