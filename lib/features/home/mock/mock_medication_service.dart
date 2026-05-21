import '../models/medication.dart';

class MockMedicationService {
  MockMedicationService._();
  static final MockMedicationService instance = MockMedicationService._();

  final List<Medication> _medications = [
    Medication(
      id: '1', name: 'Dipirona 500 mg', dosage: '1 comprimido(s)',
      time: '08:00', frequency: '2X DIA', type: 'CP',
      startDate: DateTime(2025, 4, 20), endDate: DateTime(2025, 5, 20),
    ),
    Medication(
      id: '2', name: 'Dipirona 500 mg', dosage: '1 comprimido(s)',
      time: '16:00', frequency: '2X DIA', type: 'CP',
      startDate: DateTime(2025, 4, 1), endDate: DateTime(2025, 4, 30),
    ),
    Medication(
      id: '3', name: 'Dipirona 500 mg', dosage: '1 comprimido(s)',
      time: '20:00', frequency: '1X AO DIA', type: 'CP',
      startDate: DateTime(2025, 4, 24), endDate: DateTime(2025, 5, 24),
    ),
  ];

  List<Medication> getAll() => List.from(_medications);
  void add(Medication m) => _medications.add(m);
  void update(Medication updated) {
    final i = _medications.indexWhere((m) => m.id == updated.id);
    if (i != -1) _medications[i] = updated;
  }
  void delete(String id) => _medications.removeWhere((m) => m.id == id);
  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}