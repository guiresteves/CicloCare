import '../models/medication.dart';

// ════════════════════════════════════════════════════════════
//  MOCK MEDICATION SERVICE — CicloCare
//  Arquivo: lib/features/home/mock/mock_medication_service.dart
// ════════════════════════════════════════════════════════════

class MockMedicationService {
  MockMedicationService._();
  static final MockMedicationService instance = MockMedicationService._();

  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Dipirona 500 mg',
      dosage: '1 comprimido',
      frequency: '3X DIA',
      timesPerDay: 3,
      times: ['08:00', '14:00', '20:00'],
      type: 'CP',
      category: MedicationCategory.remedio,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 25)),
    ),
    Medication(
      id: '2',
      name: 'Losartana 50 mg',
      dosage: '1 comprimido',
      frequency: '1X AO DIA',
      timesPerDay: 1,
      times: ['08:00'],
      type: 'CP',
      category: MedicationCategory.remedio,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 60)),
    ),
    Medication(
      id: '3',
      name: 'Vitamina D3',
      dosage: '1 cápsula',
      frequency: '1X AO DIA',
      timesPerDay: 1,
      times: ['20:00'],
      type: 'CP',
      category: MedicationCategory.remedio,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 90)),
    ),
    Medication(
      id: '4',
      name: 'Hemograma Completo',
      dosage: 'Coleta em jejum',
      frequency: 'SE NECESSÁRIO',
      timesPerDay: 1,
      times: ['07:00'],
      type: 'EX',
      category: MedicationCategory.exame,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    ),
    Medication(
      id: '5',
      name: 'Cardiologista',
      dosage: 'Dr. Roberto Alves',
      frequency: 'SE NECESSÁRIO',
      timesPerDay: 1,
      times: ['14:00'],
      type: 'CO',
      category: MedicationCategory.consulta,
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];

  List<Medication> getAll() => List.from(_medications);

  List<Medication> getActiveOn(DateTime day) =>
      _medications.where((m) => m.isActiveOn(day)).toList();

  List<Medication> getByCategory(MedicationCategory category) =>
      _medications.where((m) => m.category == category).toList();

  /// Retorna apenas medicamentos (Alteração 3 — tela de Remédios)
  List<Medication> getActiveMedications() {
    final now = DateTime.now();
    return _medications.where((m) =>
      m.category == MedicationCategory.remedio &&
      (m.endDate == null || !m.endDate!.isBefore(DateTime(now.year, now.month, now.day)))
    ).toList();
  }

  Medication? getById(String id) {
    try {
      return _medications.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(Medication m) => _medications.add(m);

  void update(Medication updated) {
    final i = _medications.indexWhere((m) => m.id == updated.id);
    if (i != -1) _medications[i] = updated;
  }

  void delete(String id) => _medications.removeWhere((m) => m.id == id);

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}