// ════════════════════════════════════════════════════════════
//  MODELO — NotificationItem
//  Arquivo: lib/features/notifications/models/notification_item.dart
// ════════════════════════════════════════════════════════════

enum NotificationCategory { medication, exam, consultation }

enum NotificationAction {
  // Medicamentos
  medicationAdded,
  medicationReminder,
  medicationDue,
  medicationTaken,
  medicationSkipped,
  medicationEdited,
  medicationRemoved,
  // Exames
  examScheduled,
  examUpcoming,
  examCompleted,
  examCancelled,
  examRescheduled,
  // Consultas
  consultationScheduled,
  consultationCompleted,
  consultationCancelled,
  consultationRescheduled,
}

class NotificationItem {
  final String id;
  final NotificationCategory category;
  final NotificationAction action;
  final String title;
  final String description;
  final DateTime dateTime;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.category,
    required this.action,
    required this.title,
    required this.description,
    required this.dateTime,
    this.isRead = false,
  });

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (d == today) return 'Hoje';
    if (d == yesterday) return 'Ontem';
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  String get formattedTime =>
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';

  String get groupLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (d == today) return 'Hoje';
    if (d == yesterday) return 'Ontem';
    return 'Anteriores';
  }
}