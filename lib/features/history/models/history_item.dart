enum HistoryCategory { medication, exam }
enum HistoryAction   { taken, skipped, completed, cancelled }

class HistoryItem {
  final String id;
  final String name;
  final HistoryCategory category;
  final HistoryAction action;
  final DateTime dateTime;
  final String details;
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

  String get categoryLabel {
    switch (category) {
      case HistoryCategory.medication: return 'Medicamento';
      case HistoryCategory.exam:       return 'Exame';
    }
  }

  String get actionLabel {
    switch (action) {
      case HistoryAction.taken:     return 'Tomado';
      case HistoryAction.skipped:   return 'Pulado';
      case HistoryAction.completed: return 'Realizado';
      case HistoryAction.cancelled: return 'Cancelado';
    }
  }

  String get formattedDate =>
      '${dateTime.day.toString().padLeft(2,'0')}/'
      '${dateTime.month.toString().padLeft(2,'0')}/'
      '${dateTime.year}';

  String get formattedTime =>
      '${dateTime.hour.toString().padLeft(2,'0')}:'
      '${dateTime.minute.toString().padLeft(2,'0')}';

  bool get isPositive =>
      action == HistoryAction.taken || action == HistoryAction.completed;
}
