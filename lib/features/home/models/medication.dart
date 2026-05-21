class Medication {
  final String id;
  String name;
  String dosage;
  String time;
  String frequency;
  String type; // 'CP', 'ML', etc.
  bool taken;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    required this.type,
    this.taken = false,
  });
}