import '../models/medication.dart';

// ════════════════════════════════════════════════════════════
//  DOSE ENTRY
//  Arquivo: lib/features/home/screens/dose_entry.dart
// ════════════════════════════════════════════════════════════

class DoseEntry {
  final Medication med;
  final String time;

  DoseEntry({required this.med, required this.time});
}