import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../mock/mock_medication_service.dart';
import '../../auth/mock/mock_auth_service.dart';
import 'medication_modal.dart';
import 'under_construction_screen.dart';
import '../../../core/constants/app_routes.dart';
// ════════════════════════════════════════════════════════════
//  HOME SCREEN — CicloCare (acessibilidade terceira idade)
//  Arquivo: lib/features/home/screens/home_screen.dart
//
//  Diretrizes aplicadas:
//  • Fontes mínimas de 18px, títulos 22px+
//  • Áreas de toque mínimas de 56px (recomendação WCAG)
//  • Espaçamento generoso entre elementos
//  • Ícones grandes (32px+)
//  • Contraste elevado entre texto e fundo
//  • Textos de status claros e descritivos
// ════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Paleta ───────────────────────────────────────────────
  static const Color _green      = Color(0xFF2DA87A); // verde mais escuro = mais contraste
  static const Color _greenLight = Color(0xFFE8F8F2);
  static const Color _red        = Color(0xFFB94040);
  static const Color _redLight   = Color(0xFFFDEDED);
  static const Color _orange     = Color(0xFFE07B2A);
  static const Color _grey       = Color(0xFF6B7280); // mais escuro para contraste
  static const Color _greyLight  = Color(0xFFF3F4F6);
  static const Color _white      = Color(0xFFFFFFFF);
  static const Color _textDark   = Color(0xFF111827); // quase preto
  static const Color _textGrey   = Color(0xFF4B5563);

  // ── Estado ───────────────────────────────────────────────
  late List<MedicationItem> _items;
  late String _userName;
  int _selectedDayIndex = 1;
  int _filterIndex = 0;

  final List<Map<String, String>> _days = [
    {'month': 'Abr', 'day': '23', 'label': 'Sex'},
    {'month': 'Abr', 'day': '24', 'label': 'Sex'},
    {'month': 'Abr', 'day': '25', 'label': 'Sáb'},
    {'month': 'Abr', 'day': '26', 'label': 'Dom'},
    {'month': 'Abr', 'day': '27', 'label': 'Seg'},
    {'month': 'Abr', 'day': '28', 'label': 'Ter'},
  ];

  final List<String> _filters = ['Todos', 'Remédios', 'Exames', 'Consultas'];

  @override
  void initState() {
    super.initState();
    _userName = MockAuthService.instance.loggedUser?['name'] ?? 'Usuário';
    _loadItems();
  }

  void _loadItems() {
    final meds = MockMedicationService.instance.getAll();
    _items = meds.asMap().entries.map((e) {
      MedStatus status;
      if (e.key == 0) {
        status = MedStatus.overdue;
      } else if (e.key == 1) status = MedStatus.done;
      else                 status = MedStatus.pending;
      return MedicationItem(med: e.value, status: status);
    }).toList();
  }

  int get _doneCount  => _items.where((i) => i.status == MedStatus.done).length;
  int get _totalCount => _items.length;

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              children: [
                _buildSectionTitle(),
                const SizedBox(height: 10),
                _buildProgressBar(),
                const SizedBox(height: 18),
                _buildFilters(),
                const SizedBox(height: 20),
                ..._items.map((item) => _buildMedCard(item)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ════════════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              // ── Perfil ──────────────────────────────────
              Row(
                children: [
                  // Avatar grande para fácil identificação
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _white.withOpacity(0.25),
                    child: const Icon(Icons.person_rounded, color: _white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TITULAR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: _white,
                            fontSize: 22, // grande e legível
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Botões com área mínima de 56px
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                    child: _iconBtn(Icons.notifications_outlined, 'Notificações'),
                  ),
                  const SizedBox(width: 10),
                  _iconBtn(Icons.settings_outlined, 'Configurações'),
                ],
              ),

              const SizedBox(height: 24),

              // ── Calendário horizontal ────────────────────
              SizedBox(
                height: 90, // mais alto para toque fácil
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final isSelected = index == _selectedDayIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 64, // mais largo para toque fácil
                        decoration: BoxDecoration(
                          color: isSelected ? _white.withOpacity(0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? _white : _white.withOpacity(0.35),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _days[index]['month']!,
                              style: TextStyle(
                                color: isSelected ? _white : _white.withOpacity(0.75),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _days[index]['day']!,
                              style: TextStyle(
                                color: _white,
                                fontSize: 26, // número do dia bem grande
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              ),
                            ),
                            Text(
                              _days[index]['label']!,
                              style: TextStyle(
                                color: isSelected ? _white : _white.withOpacity(0.75),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botão de ícone com área mínima 56x56
  Widget _iconBtn(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _white, size: 28),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  TÍTULO DA SEÇÃO
  // ════════════════════════════════════════════════════════
  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Medicamentos do Dia',
          style: TextStyle(
            fontSize: 20, // bem legível
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _greenLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$_doneCount de $_totalCount tomados',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  PROGRESS BAR — mais grossa e visível
  // ════════════════════════════════════════════════════════
  Widget _buildProgressBar() {
    final progress = _totalCount == 0 ? 0.0 : _doneCount / _totalCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10, // mais grossa — idosos enxergam melhor
            backgroundColor: _greyLight,
            valueColor: const AlwaysStoppedAnimation<Color>(_green),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(_doneCount / (_totalCount == 0 ? 1 : _totalCount) * 100).toStringAsFixed(0)}% concluído',
          style: const TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════
  //  FILTROS — botões grandes e fáceis de tocar
  // ════════════════════════════════════════════════════════
  Widget _buildFilters() {
    return SizedBox(
      height: 46, // mais alto para toque fácil
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: selected ? _green : _white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: selected ? _green : _grey.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? _white : _textGrey,
                  fontSize: 16, // fonte maior nos filtros
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CARD DE MEDICAMENTO — grande e acessível
  // ════════════════════════════════════════════════════════
  Widget _buildMedCard(MedicationItem item) {
    final isDone    = item.status == MedStatus.done;
    final isOverdue = item.status == MedStatus.overdue;
    final isPending = item.status == MedStatus.pending;

    // ── Cores por estado ─────────────────────────────────
    final cardBg      = isDone    ? const Color(0xFFF3F4F6)
                      : isOverdue ? const Color(0xFFFFF0F0)
                      :             const Color(0xFFEBFAF3);
    final borderColor = isDone    ? const Color(0xFFD1D5DB)
                      : isOverdue ? const Color(0xFFE57373)
                      :             const Color(0xFF6FCF97);
    final iconBg      = isDone    ? const Color(0xFFD1D5DB)
                      : isOverdue ? const Color(0xFFFFCDD2)
                      :             const Color(0xFFC8F0DC);
    final iconColor   = isDone    ? const Color(0xFF9CA3AF)
                      : isOverdue ? _red
                      :             _green;
    final nameColor   = isDone    ? _grey : _textDark;
    final timeColor   = isDone    ? _grey
                      : isOverdue ? _red
                      :             _green;
    final timeBg      = isDone    ? const Color(0xFFE5E7EB)
                      : isOverdue ? const Color(0xFFFFE5E5)
                      :             const Color(0xFFD1FAE5);
    final badgeBg     = isDone    ? const Color(0xFFE5E7EB)
                      : isOverdue ? const Color(0xFFFFE5E5)
                      :             const Color(0xFFD1FAE5);
    final badgeColor  = isDone    ? _grey
                      : isOverdue ? _red
                      :             _green;

    return Semantics(
      label: '${item.med.name}, horário ${item.med.time}',
      button: true,
      child: GestureDetector(
        onTap: () => _onCardTap(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // ── Ícone ──────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.medication_rounded, color: iconColor, size: 30),
              ),
              const SizedBox(width: 14),

              // ── Info ───────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome + horário na mesma linha (apenas pendente e atrasado)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.med.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: nameColor,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: _grey,
                              decorationThickness: 2.5,
                            ),
                          ),
                        ),
                        // Horário ao lado do nome (pendente e atrasado)
                        if (!isDone) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: timeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPending)
                                  Icon(Icons.access_time_rounded, size: 13, color: timeColor),
                                if (isPending) const SizedBox(width: 3),
                                Text(
                                  item.med.time,
                                  style: TextStyle(
                                    color: timeColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Dosagem
                    Text(
                      item.med.dosage,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDone ? _grey : _textGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Badges
                    Row(
                      children: [
                        _badge(item.med.frequency, bg: badgeBg, color: badgeColor, isDone: isDone),
                        const SizedBox(width: 8),
                        _badge(item.med.type, bg: badgeBg, color: badgeColor, isDone: isDone),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Lado direito ───────────────────────────
              if (isDone) ...[
                // Horário riscado no lado direito
                const SizedBox(width: 10),
                Text(
                  item.med.time,
                  style: TextStyle(
                    color: _grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: _grey,
                    decorationThickness: 2,
                  ),
                ),
              ] else if (isPending) ...[
                // Checkbox no canto direito
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _onCardTap(item),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }



  // ════════════════════════════════════════════════════════
  //  LÓGICA — toque no card
  // ════════════════════════════════════════════════════════
  void _onCardTap(MedicationItem item) {
    switch (item.status) {
      case MedStatus.pending: _showConfirmModal(item); break;
      case MedStatus.overdue: _showOverdueModal(item); break;
      case MedStatus.done:    _showUndoModal(item);    break;
    }
  }

  // ── Modal: confirmar dose ────────────────────────────────
  void _showConfirmModal(MedicationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomModal(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _modalMedCard(item),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MedicationModal(
                        medication: item.med,
                        isEditing: true,
                        onSave: (updated) {
                          MockMedicationService.instance.update(updated);
                          setState(_loadItems);
                        },
                        onDelete: (id) {
                          MockMedicationService.instance.delete(id);
                          setState(_loadItems);
                        },
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.edit_outlined, size: 18, color: _green),
                label: const Text('Editar medicamento',
                  style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Você tomou este medicamento?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Confirme apenas se já tomou a dose correta.',
              style: TextStyle(fontSize: 16, color: _textGrey),
            ),
            const SizedBox(height: 24),
            _modalBtn('✓  Sim, já tomei', _green, _white, () {
              setState(() => item.status = MedStatus.done);
              Navigator.pop(context);
            }),
            const SizedBox(height: 12),
            _modalBtn('Cancelar', _white, _textDark, () => Navigator.pop(context), border: true),
          ],
        ),
      ),
    );
  }

  // ── Modal: atrasado ──────────────────────────────────────
  void _showOverdueModal(MedicationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomModal(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alerta vermelho — texto claro e grande
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _redLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _red.withOpacity(0.3), width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_rounded, color: _red, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medicamento Atrasado!',
                          style: TextStyle(color: _red, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: _red, fontSize: 16, height: 1.5),
                            children: [
                              const TextSpan(text: 'Deveria ter sido tomado às '),
                              TextSpan(
                                text: item.med.time,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const TextSpan(text: '.\nJá se passaram '),
                              const TextSpan(
                                text: '6h 32min',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const TextSpan(text: ' do horário.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _modalMedCard(item),
            const SizedBox(height: 24),
            _modalBtn('💊  Tomar agora', _red, _white, () {
              setState(() => item.status = MedStatus.done);
              Navigator.pop(context);
            }),
            const SizedBox(height: 12),
            _modalBtn('Pular esta dose', _orange, _white, () {
              setState(() => item.status = MedStatus.done);
              Navigator.pop(context);
            }),
            const SizedBox(height: 12),
            _modalBtn('Cancelar', _white, _textDark, () => Navigator.pop(context), border: true),
          ],
        ),
      ),
    );
  }

  // ── Modal: desmarcar ─────────────────────────────────────
  void _showUndoModal(MedicationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomModal(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _modalMedCard(item),
            const SizedBox(height: 20),
            const Text(
              'Deseja desmarcar este medicamento?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              'O medicamento voltará para a lista de pendentes.',
              style: TextStyle(fontSize: 16, color: _textGrey),
            ),
            const SizedBox(height: 24),
            _modalBtn('Desmarcar Tarefa', _grey, _white, () {
              setState(() => item.status = MedStatus.pending);
              Navigator.pop(context);
            }),
            const SizedBox(height: 12),
            _modalBtn('Cancelar', _white, _textDark, () => Navigator.pop(context), border: true),
          ],
        ),
      ),
    );
  }

  // ── Card mini no modal ───────────────────────────────────
  Widget _modalMedCard(MedicationItem item) {
    final isDone    = item.status == MedStatus.done;
    final isOverdue = item.status == MedStatus.overdue;
    final nameColor = isDone ? _grey : isOverdue ? _red : _textDark;
    final iconBg    = isDone ? _greyLight : isOverdue ? _redLight : _greenLight;
    final iconColor = isDone ? _grey : isOverdue ? _red : _green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _greyLight, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.medication_rounded, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.med.name,
                  style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: nameColor,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: _grey, decorationThickness: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.med.dosage, style: const TextStyle(fontSize: 15, color: _textGrey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniChip(Icons.access_time_rounded, item.med.time, _green),
                    const SizedBox(width: 8),
                    _miniChip(null, item.med.frequency, _green),
                    const SizedBox(width: 8),
                    _miniChip(null, item.med.type, _green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, {required Color bg, required Color color, bool isDone = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color,
          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: color,
        ),
      ),
    );
  }

  Widget _miniChip(IconData? icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // Botão de modal — grande, fácil de tocar (min 58px)
  Widget _modalBtn(String label, Color bg, Color fg, VoidCallback onTap, {bool border = false}) {
    return SizedBox(
      width: double.infinity,
      height: 58, // grande para toque fácil
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: border ? BorderSide(color: _grey.withOpacity(0.3), width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: fg),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  FAB — grande
  // ════════════════════════════════════════════════════════
  Widget _buildFAB() {
    return SizedBox(
      width: 68,
      height: 68,
      child: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => MedicationModal(
            medication: null,
            isEditing: false,
            onSave: (med) {
              MockMedicationService.instance.add(med);
              setState(_loadItems);
            },
            onDelete: (_) {},
          ),
        ),
        backgroundColor: _green,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTTOM BAR — ícones grandes e com label
  // ════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    final items = [
      {'icon': Icons.medication_outlined,     'label': 'Remédios',  'title': 'Remédios',  'iconData': Icons.medication_outlined},
      {'icon': Icons.bolt_outlined,           'label': 'Atividade', 'title': 'Atividade', 'iconData': Icons.bolt_outlined},
      {'icon': Icons.home_rounded,            'label': 'Início',    'title': '',           'iconData': Icons.home_rounded},
      {'icon': Icons.calendar_month_outlined, 'label': 'Agenda',    'title': 'Agenda',    'iconData': Icons.calendar_month_outlined},
      {'icon': Icons.person_outline_rounded,  'label': 'Perfil',    'title': 'Perfil',    'iconData': Icons.person_outline_rounded},
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final isHome  = e.key == 2;
          final icon    = e.value['icon'] as IconData;
          final label   = e.value['label'] as String;
          final title   = e.value['title'] as String;
          final iconData= e.value['iconData'] as IconData;

          return GestureDetector(
            onTap: isHome
                ? null // já está na home
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnderConstructionScreen(
                        title: title,
                        icon: iconData,
                      ),
                    ),
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isHome ? _green : _grey, size: 30),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isHome ? _green : _grey,
                    fontWeight: isHome ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  MODELOS
// ════════════════════════════════════════════════════════════
enum MedStatus { pending, overdue, done }

class MedicationItem {
  final Medication med;
  MedStatus status;
  MedicationItem({required this.med, required this.status});
}

// ════════════════════════════════════════════════════════════
//  BOTTOM MODAL WRAPPER
// ════════════════════════════════════════════════════════════
class _BottomModal extends StatelessWidget {
  final Widget child;
  const _BottomModal({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}