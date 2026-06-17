import '../models/history_item.dart';

// ════════════════════════════════════════════════════════════
//  MOCK HISTORY SERVICE
//  Arquivo: lib/features/history/mock/mock_history_service.dart
//
//  • Dados por usuário
//  • Novo usuário inicia sem histórico
// ════════════════════════════════════════════════════════════

class MockHistoryService {
  MockHistoryService._();
  static final MockHistoryService instance = MockHistoryService._();

  final Map<String, List<HistoryItem>> _data = {};
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

  List<HistoryItem> _list() {
    if (_currentUser == null) return [];
    return _data[_currentUser!] ?? [];
  }

  // ── Queries ──────────────────────────────────────────────

  List<HistoryItem> getFiltered({
    HistoryCategory? category,
    int? lastDays,
    DateTime? from,
    DateTime? to,
    bool newestFirst = true,
  }) {
    var result = List<HistoryItem>.from(_list());

    if (category != null) {
      result = result.where((i) => i.category == category).toList();
    }

    if (lastDays != null) {
      final cutoff =
          DateTime.now().subtract(Duration(days: lastDays));
      result =
          result.where((i) => i.dateTime.isAfter(cutoff)).toList();
    }

    if (from != null) {
      result = result.where((i) => i.dateTime.isAfter(from)).toList();
    }
    if (to != null) {
      result = result.where((i) => i.dateTime.isBefore(to)).toList();
    }

    result.sort((a, b) => newestFirst
        ? b.dateTime.compareTo(a.dateTime)
        : a.dateTime.compareTo(b.dateTime));

    return result;
  }

  // ── Mutações ─────────────────────────────────────────────

  void add(HistoryItem item) {
    if (_currentUser == null) return;
    _data[_currentUser!]!.insert(0, item);
  }

  void deleteUser2(String email) => deleteUser(email);
}