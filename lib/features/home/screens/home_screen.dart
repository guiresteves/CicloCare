import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../mock/mock_medication_service.dart';
import '../../auth/mock/mock_auth_service.dart';
import 'medication_modal.dart';

// ════════════════════════════════════════════════════════════
//  HOME SCREEN — CicloCare (fiel ao design Figma)
//  Arquivo: lib/features/home/screens/home_screen.dart
// ════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── PALETA (extraída do Figma) ───────────────────────────
  static const Color _green        = Color(0xFF3DBE8B); // verde primário
  static const Color _greenDark    = Color(0xFF2DA87A); // verde escuro (dia selecionado)
  static const Color _greenLight   = Color(0xFFDFF5EC); // verde claro (fundo geral + cards)
  static const Color _white        = Color(0xFFFFFFFF);
  static const Color _textDark     = Color(0xFF1A1A2E);
  static const Color _textGrey     = Color(0xFF6B7280);

  late List<Medication> _medications;
  late String _userName;
  int _selectedDayIndex = 2;

  final List<Map<String, String>> _weekDays = [
    {'day': '9',  'label': 'SEG'},
    {'day': '10', 'label': 'TER'},
    {'day': '11', 'label': 'QUA'},
    {'day': '12', 'label': 'QUI'},
    {'day': '13', 'label': 'SEX'},
    {'day': '14', 'label': 'SAB'},
  ];

  @override
  void initState() {
    super.initState();
    _medications = MockMedicationService.instance.getAll();
    _userName    = MockAuthService.instance.loggedUser?['name'] ?? 'Usuário';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenLight, // fundo verde claro geral
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  HEADER — branco, sem gradiente
  // ════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      color: _white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Column(
        children: [
          // ── Perfil ──────────────────────────────────────
          Row(
            children: [
              // Foto de perfil
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _green, width: 2),
                  image: const DecorationImage(
                    // Placeholder — substituir por foto real futuramente
                    image: NetworkImage(
                      'https://randomuser.me/api/portraits/men/75.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Nome + saudação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Seja Bem-Vindo!',
                      style: TextStyle(
                        color: _textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Notificação
              _HeaderIconButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              // Configurações
              _HeaderIconButton(
                icon: Icons.settings_outlined,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Busca ────────────────────────────────────────
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: _green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(fontSize: 15, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Buscar medicamento...',
                      hintStyle: TextStyle(color: _textGrey.withOpacity(0.7), fontSize: 15),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Icon(Icons.search_rounded, color: _green, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BODY — calendário + lista
  // ════════════════════════════════════════════════════════
  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        _buildCalendar(),
        const SizedBox(height: 24),
        ..._medications.map((med) => _buildMedicationCard(med)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  CALENDÁRIO — fundo verde claro, selecionado verde escuro
  // ════════════════════════════════════════════════════════
  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_weekDays.length, (index) {
          final isSelected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 68,
              decoration: BoxDecoration(
                color: isSelected ? _greenDark : _white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [BoxShadow(color: _greenDark.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekDays[index]['day']!,
                    style: TextStyle(
                      color: isSelected ? _white : _textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _weekDays[index]['label']!,
                    style: TextStyle(
                      color: isSelected ? _white.withOpacity(0.85) : _textGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CARD DE MEDICAMENTO — fundo branco
  // ════════════════════════════════════════════════════════
  Widget _buildMedicationCard(Medication med) {
    return GestureDetector(
      onTap: () => _openMedicationModal(med, isEditing: false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone cápsula
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _greenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: _green,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: _green, // nome em verde como no Figma
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    med.dosage,
                    style: const TextStyle(fontSize: 13, color: _textGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBadge(med.type),
                      const SizedBox(width: 6),
                      _buildBadge(med.frequency),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Horário
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                med.time,
                style: const TextStyle(
                  color: _white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _green,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  FAB
  // ════════════════════════════════════════════════════════
  Widget _buildFAB() {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        onPressed: () => _openMedicationModal(null, isEditing: false),
        backgroundColor: _green,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: _white, size: 30),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTTOM BAR — verde com ícone home centralizado
  // ════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    return Container(
      height: 72,
      color: _white,
      child: Center(
        child: Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.home_rounded, color: _white, size: 28),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  MODAL
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
          if (med == null) {
            MockMedicationService.instance.add(updated);
          } else {
            MockMedicationService.instance.update(updated);
          }
          setState(() => _medications = MockMedicationService.instance.getAll());
        },
        onDelete: (id) {
          MockMedicationService.instance.delete(id);
          setState(() => _medications = MockMedicationService.instance.getAll());
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  WIDGET AUXILIAR — Ícone do header
// ════════════════════════════════════════════════════════════
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFDFF5EC),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF3DBE8B), size: 22),
      ),
    );
  }
}