import '../models/history_item.dart';


class MockHistoryService {
  MockHistoryService._();
  static final MockHistoryService instance = MockHistoryService._();

  final List<HistoryItem> _items = [
    HistoryItem(
      id: '1', name: 'Dipirona 500 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      details: '1 comprimido — 08:00',
    ),
    HistoryItem(
      id: '2', name: 'Losartana 50 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(hours: 4)),
      details: '1 comprimido — 08:00',
    ),
    HistoryItem(
      id: '3', name: 'Vitamina D3',
      category: HistoryCategory.medication, action: HistoryAction.skipped,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      details: '1 cápsula — 20:00',
    ),
    HistoryItem(
      id: '4', name: 'Dipirona 500 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      details: '1 comprimido — 08:00',
    ),
    HistoryItem(
      id: '5', name: 'Hemograma Completo',
      category: HistoryCategory.exam, action: HistoryAction.completed,
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      details: 'Lab. Santa Clara — Dr. Roberto Alves',
    ),
    HistoryItem(
      id: '6', name: 'Losartana 50 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      details: '1 comprimido — 08:00',
    ),
    HistoryItem(
      id: '7', name: 'Raio-X de Tórax',
      category: HistoryCategory.exam, action: HistoryAction.cancelled,
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      details: 'Clínica Imagem Plus',
    ),
    HistoryItem(
      id: '8', name: 'Dipirona 500 mg',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(days: 4)),
      details: '1 comprimido — 14:00',
    ),
    HistoryItem(
      id: '9', name: 'Vitamina D3',
      category: HistoryCategory.medication, action: HistoryAction.taken,
      dateTime: DateTime.now().subtract(const Duration(days: 6)),
      details: '1 cápsula — 20:00',
    ),
    HistoryItem(
      id: '10', name: 'Glicemia em Jejum',
      category: HistoryCategory.exam, action: HistoryAction.completed,
      dateTime: DateTime.now().subtract(const Duration(days: 10)),
      details: 'Lab. Santa Clara',
    ),
  ];

  List<HistoryItem> getFiltered({
    HistoryCategory? category,
    int? lastDays,
    DateTime? from,
    DateTime? to,
    bool newestFirst = true,
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

    result.sort((a, b) => newestFirst
        ? b.dateTime.compareTo(a.dateTime)
        : a.dateTime.compareTo(b.dateTime));

    return result;
  }

  void add(HistoryItem item) => _items.add(item);
}
