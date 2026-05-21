// ════════════════════════════════════════════════════════════
//  MODELO — Medication
//  Arquivo: lib/features/home/models/medication.dart
// ════════════════════════════════════════════════════════════

class Medication {
  final String id;
  String name;
  String dosage;
  String time;
  String frequency;
  String type;
  bool taken;

  // ── Período de tratamento ────────────────────────────────
  DateTime? startDate;
  DateTime? endDate;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.type,
    this.taken = false,
    this.startDate,
    this.endDate,
  });

  // Formata período para exibição
  String get periodLabel {
    if (startDate == null || endDate == null) return 'Sem período definido';
    final s = '${startDate!.day.toString().padLeft(2,'0')}/${startDate!.month.toString().padLeft(2,'0')}/${startDate!.year}';
    final e = '${endDate!.day.toString().padLeft(2,'0')}/${endDate!.month.toString().padLeft(2,'0')}/${endDate!.year}';
    return '$s até $e';
  }

  // Quantos dias de tratamento restam
  int get daysRemaining {
    if (endDate == null) return -1;
    return endDate!.difference(DateTime.now()).inDays;
  }
}