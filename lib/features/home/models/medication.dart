// ════════════════════════════════════════════════════════════
//  MODELO — Medication
//  Arquivo: lib/features/home/models/medication.dart
// ════════════════════════════════════════════════════════════

enum MedicationCategory { remedio, exame, consulta }

enum MedicationStatus {
  pending,  // pendente (ainda não chegou o horário ou não tomou)
  taken,    // tomado (concluído pelo usuário)
  overdue,  // atrasado (passou do horário sem tomar)
  skipped,  // pulado pelo usuário
}

class Medication {
  final String id;
  String name;
  String dosage;
  String frequency;   // ex: "2X DIA"
  int timesPerDay;    // número de vezes por dia (gera cards automáticos)
  List<String> times; // horários gerados: ["08:00", "14:00", "20:00"]
  String type;        // CP, ML, GTS...
  MedicationCategory category;
  String observations;

  // Período
  DateTime? startDate;
  DateTime? endDate;

  // Status por horário: key = "YYYY-MM-DD_HH:MM", value = MedicationStatus
  // Permite persistir o status de cada dose individualmente
  Map<String, MedicationStatus> statusMap;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timesPerDay,
    required this.times,
    required this.type,
    this.category    = MedicationCategory.remedio,
    this.observations= '',
    this.startDate,
    this.endDate,
    Map<String, MedicationStatus>? statusMap,
  }) : statusMap = statusMap ?? {};

  // ── Helpers ──────────────────────────────────────────────

  /// Retorna o status de uma dose específica (dia + horário)
  MedicationStatus statusFor(DateTime day, String time) {
    final key = _key(day, time);
    if (statusMap.containsKey(key)) return statusMap[key]!;

    // Calcula automaticamente se está atrasado
    final now = DateTime.now();
    final parts = time.split(':');
    final doseTime = DateTime(day.year, day.month, day.day,
        int.parse(parts[0]), int.parse(parts[1]));

    if (now.isAfter(doseTime.add(const Duration(minutes: 30)))) {
      return MedicationStatus.overdue;
    }
    return MedicationStatus.pending;
  }

  /// Atualiza o status de uma dose
  void setStatus(DateTime day, String time, MedicationStatus status) {
    statusMap[_key(day, time)] = status;
  }

  String _key(DateTime day, String time) =>
      '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}_$time';

  /// Verifica se o medicamento deve aparecer em um dia específico
  bool isActiveOn(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    if (startDate == null || endDate == null) return true;
    final s = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final e = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Formato legível do período
  String get periodLabel {
    if (startDate == null || endDate == null) return 'Sem período definido';
    return '${_fmt(startDate!)} até ${_fmt(endDate!)}';
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  /// Dias restantes do tratamento
  int get daysRemaining {
    if (endDate == null) return -1;
    return endDate!.difference(DateTime.now()).inDays;
  }

  /// Período de um horário — Manhã / Tarde / Noite
  static String periodOf(String time) {
    final hour = int.tryParse(time.split(':')[0]) ?? 0;
    if (hour >= 5  && hour < 12) return 'Manhã';
    if (hour >= 12 && hour < 18) return 'Tarde';
    return 'Noite';
  }

  /// Gera horários distribuídos automaticamente conforme timesPerDay
  static List<String> generateTimes(int timesPerDay) {
    switch (timesPerDay) {
      case 1:  return ['08:00'];
      case 2:  return ['08:00', '20:00'];
      case 3:  return ['08:00', '14:00', '20:00'];
      case 4:  return ['08:00', '12:00', '16:00', '20:00'];
      case 6:  return ['06:00', '10:00', '14:00', '18:00', '22:00', '02:00'];
      default: return ['08:00'];
    }
  }
}