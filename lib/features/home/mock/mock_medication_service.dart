import '../models/medication.dart';

// ════════════════════════════════════════════════════════════
//  MOCK MEDICATION SERVICE
//  Arquivo: lib/features/home/mock/mock_medication_service.dart
//
//  Segue o mesmo padrão do MockAuthService do módulo de auth.
//  Centraliza os dados e operações de medicamentos.
// ════════════════════════════════════════════════════════════

class MockMedicationService {
  MockMedicationService._();
  static final MockMedicationService instance = MockMedicationService._();

  // Dados mockados iniciais — privados, só acessados pelos métodos
  final List<Medication> _medications = [
    Medication(
      id: '1',
      name: 'Dipirona 500 mg',
      dosage: '1 comprimido',
      time: '08:00',
      frequency: '2X DIA',
      type: 'CP',
    ),
    Medication(
      id: '2',
      name: 'Dipirona 500 mg',
      dosage: '1 comprimido',
      time: '16:00',
      frequency: '2X DIA',
      type: 'CP',
    ),
    Medication(
      id: '3',
      name: 'Dipirona 500 mg',
      dosage: '1 comprimido',
      time: '20:00',
      frequency: '2X DIA',
      type: 'CP',
    ),
  ];

  /// Retorna uma cópia da lista para evitar modificação externa direta
  List<Medication> getAll() => List.from(_medications);

  /// Adiciona um novo medicamento
  void add(Medication medication) {
    _medications.add(medication);
  }

  /// Atualiza um medicamento existente pelo id
  void update(Medication updated) {
    final index = _medications.indexWhere((m) => m.id == updated.id);
    if (index != -1) _medications[index] = updated;
  }

  /// Remove um medicamento pelo id
  void delete(String id) {
    _medications.removeWhere((m) => m.id == id);
  }

  /// Gera um id único baseado no timestamp
  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}