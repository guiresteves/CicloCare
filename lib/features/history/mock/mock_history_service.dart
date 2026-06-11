import '../models/history_item.dart';

class MockHistoryService {
  MockHistoryService._();
  static final MockHistoryService instance = MockHistoryService._();

  final List<HistoryItem> _items = [
    HistoryItem(
      id: '1', name: 'Dipirona 500 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(hours: 4)),
      details: '1 comprimido — 08:00',
    ),
    HistoryItem(
      id: '2', name: 'Losartana 50 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(hours: 6)),
      details: '1 comprimido — 08:00',
    ),
    HistoryItem(
      id: '3', name: 'Vitamina D3',
      category: HistoryCategory.medication, action: HistoryAction.skipped,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      details: '1 cápsula — 20:00',
    ),
    HistoryItem(
      id: '4', name: 'Hemograma Completo',
      category: HistoryCategory.exam, action: HistoryAction.completed,
      dateTime: DateTime.now().subtract(const Duration(days: 15)),
      details: 'Lab. Santa Clara — Dr. Roberto Alves',
    ),
    HistoryItem(
      id: '5', name: 'Consulta Clínico Geral',
      category: HistoryCategory.consultation, action: HistoryAction.completed,
      dateTime: DateTime.now().subtract(const Duration(days: 20)),
      details: 'Dra. Ana Paula — UBS Centro',
    ),
    HistoryItem(
      id: '6', name: 'Dipirona 500 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      details: '1 comprimido — 14:00',
    ),
    HistoryItem(
      id: '7', name: 'Losartana 50 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      details: '1 comprimido — 08:00',
    ),
  ];

  List<HistoryItem> getAll() => List.from(_items)
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  List<HistoryItem> getFiltered({
    HistoryCategory? category,
    int? lastDays,
    DateTime? from,
    DateTime? to,
  }) {
    var result = List<HistoryItem>.from(_items);

    if (category != null) {
      result = result.where((i) => i.category == category).toList();
    }

    if (lastDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: lastDays));
      result = result.where((i) => i.dateTime.isAfter(cutoff)).toList();
    }

    if (from != null) result = result.where((i) => i.dateTime.isAfter(from)).toList();
    if (to   != null) result = result.where((i) => i.dateTime.isBefore(to)).toList();

    return result..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void add(HistoryItem item) => _items.add(item);
}