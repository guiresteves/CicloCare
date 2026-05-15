import 'package:flutter/material.dart';
import 'medication_modal.dart';

// ════════════════════════════════════════════════════════════
//  HOME SCREEN — Titular
//  Arquivo: lib/features/home/home_screen.dart
// ════════════════════════════════════════════════════════════

// ── MODELO DE DADOS (mockado, sem banco ainda) ───────────────
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

// ── DADOS MOCKADOS ───────────────────────────────────────────
List<Medication> mockMedications = [
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

// ════════════════════════════════════════════════════════════
//  WIDGET PRINCIPAL
// ════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── CORES ────────────────────────────────────────────────
  static const Color _purple = Color(0xFF7C5CBF);
  static const Color _teal   = Color(0xFF3DB89E);
  static const Color _white  = Color(0xFFFFFFFF);
  static const Color _grey   = Color(0xFF6B7280);
  static const Color _bgGrey = Color(0xFFF3F4F6);

  // ── ESTADO ───────────────────────────────────────────────
  // Lista local de medicamentos (será substituída pelo banco depois)
  List<Medication> _medications = List.from(mockMedications);

  // Índice do dia selecionado no calendário horizontal (0 = hoje)
  int _selectedDayIndex = 2;

  // Dias da semana exibidos no calendário
  final List<Map<String, String>> _weekDays = [
    {'day': '9',  'label': 'SEG'},
    {'day': '10', 'label': 'TER'},
    {'day': '11', 'label': 'QUA'},
    {'day': '12', 'label': 'QUI'},
    {'day': '13', 'label': 'SEX'},
    {'day': '14', 'label': 'SÁB'},
  ];

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header verde com saudação e calendário
            _buildHeader(),

            // Lista de medicamentos
            Expanded(child: _buildMedicationList()),
          ],
        ),
      ),

      // Botão flutuante de adicionar medicamento
      floatingActionButton: _buildFAB(),

      // Barra inferior com ícone home
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  HEADER — saudação + busca + calendário
  // ════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_teal, Color(0xFF2DA88E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // ── Linha do perfil ─────────────────────────────
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: _white.withOpacity(0.3),
                child: const Icon(Icons.person, color: _white, size: 26),
              ),
              const SizedBox(width: 12),

              // Nome + subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'João Silva',
                      style: TextStyle(
                        color: _white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Seja Bem-Vindo!',
                      style: TextStyle(
                        color: _white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Ícones de notificação e configurações
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: _white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: _white),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Barra de busca ──────────────────────────────
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: _white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.tune, color: _white.withOpacity(0.85), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: _white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar medicamento...',
                      hintStyle: TextStyle(
                        color: _white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Icon(Icons.search, color: _white.withOpacity(0.85), size: 20),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Calendário horizontal ────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_weekDays.length, (index) {
              final isSelected = index == _selectedDayIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? _white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: _white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekDays[index]['day']!,
                        style: TextStyle(
                          color: isSelected ? _teal : _white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _weekDays[index]['label']!,
                        style: TextStyle(
                          color: isSelected
                              ? _teal
                              : _white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  LISTA DE MEDICAMENTOS
  // ════════════════════════════════════════════════════════
  Widget _buildMedicationList() {
    if (_medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 64, color: _grey.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              'Nenhum medicamento para hoje',
              style: TextStyle(color: _grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        return _buildMedicationCard(med);
      },
    );
  }

  // ════════════════════════════════════════════════════════
  //  CARD DE MEDICAMENTO
  // ════════════════════════════════════════════════════════
  Widget _buildMedicationCard(Medication med) {
    return GestureDetector(
      onTap: () => _openMedicationModal(med, isEditing: false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF5EE), // verde claro
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Ícone de cápsula
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: _teal,
                size: 22,
              ),
            ),

            const SizedBox(width: 12),

            // Nome + frequência
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    med.dosage,
                    style: TextStyle(fontSize: 12, color: _grey),
                  ),
                  const SizedBox(height: 4),
                  // Badge de tipo + frequência
                  Row(
                    children: [
                      _buildBadge(med.type, _teal),
                      const SizedBox(width: 6),
                      _buildBadge(med.frequency, _teal),
                    ],
                  ),
                ],
              ),
            ),

            // Horário
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                med.time,
                style: const TextStyle(
                  color: _white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  FAB — Adicionar medicamento
  // ════════════════════════════════════════════════════════
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () => _openMedicationModal(null, isEditing: false),
      backgroundColor: _teal,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: _white, size: 28),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTTOM BAR
  // ════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_teal, _purple],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.home_rounded, color: _white, size: 28),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MODAL — Visualizar / Adicionar / Editar medicamento
  // ════════════════════════════════════════════════════════
  void _openMedicationModal(Medication? med, {required bool isEditing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MedicationModal(
        medication: med,
        isEditing: isEditing,
        onSave: (updated) {
          setState(() {
            if (med == null) {
              // Adicionar novo
              _medications.add(updated);
            } else {
              // Editar existente
              final index = _medications.indexWhere((m) => m.id == updated.id);
              if (index != -1) _medications[index] = updated;
            }
          });
        },
        onDelete: (id) {
          setState(() {
            _medications.removeWhere((m) => m.id == id);
          });
        },
      ),
    );
  }
}