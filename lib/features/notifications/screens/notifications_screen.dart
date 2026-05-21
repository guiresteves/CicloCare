import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  NOTIFICATIONS SCREEN — CicloCare
//  Arquivo: lib/features/notifications/screens/notifications_screen.dart
// ════════════════════════════════════════════════════════════

enum NotifType { overdueAlert, reminder, appointment, success, stock, exam }

enum NotifStatus { unread, read }

class NotificationItem {
  final NotifType type;
  final String title;
  final String message;
  final String time;
  final String? dayLabel;
  NotifStatus status;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.dayLabel,
    this.status = NotifStatus.unread,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // ── Paleta (mesma da HomeScreen) ─────────────────────────
  static const Color _green       = Color(0xFF2DA87A);
  static const Color _greenLight  = Color(0xFFE8F8F2);
  static const Color _red         = Color(0xFFB94040);
  static const Color _redLight    = Color(0xFFFDEDED);
  static const Color _orange      = Color(0xFFE07B2A);
  static const Color _orangeLight = Color(0xFFFFF4EB);
  static const Color _blue        = Color(0xFF2563EB);
  static const Color _blueLight   = Color(0xFFEBF4FD);
  static const Color _grey        = Color(0xFF6B7280);
  static const Color _greyLight   = Color(0xFFF3F4F6);
  static const Color _white       = Color(0xFFFFFFFF);
  static const Color _textDark    = Color(0xFF111827);
  static const Color _textGrey    = Color(0xFF4B5563);
  static const Color _textMuted   = Color(0xFF9CA3AF);
  static const Color _border      = Color(0xFFE5E7EB);

  int _tabIndex = 0;
  final List<String> _tabs = ['Todos', 'Remédios', 'Agenda', 'Sistema'];
  final List<int> _unreadCounts = [5, 3, 0, 0];
  late List<NotificationItem> _allItems;

  @override
  void initState() {
    super.initState();
    _allItems = _mockNotifications();
  }

  List<NotificationItem> _mockNotifications() => [
        NotificationItem(
          type: NotifType.overdueAlert,
          title: 'Losartana atrasada!',
          message: 'Você deveria ter tomado às 08:00. Já se passaram 6h 32min do horário.',
          time: '14:32',
          dayLabel: 'Hoje',
        ),
        NotificationItem(
          type: NotifType.reminder,
          title: 'Hora do Metformina',
          message: 'Está na hora de tomar Metformina 850mg — 1 comprimido com o almoço.',
          time: '12:00',
        ),
        NotificationItem(
          type: NotifType.appointment,
          title: 'Consulta amanhã',
          message: 'Lembrete: consulta com Dr. Carlos Mendes amanhã às 10h00 — Cardiologia.',
          time: '09:15',
        ),
        NotificationItem(
          type: NotifType.success,
          title: 'Todos tomados!',
          message: 'Parabéns! Você tomou todos os 4 medicamentos do dia. Continue assim!',
          time: '22:00',
          dayLabel: 'Ontem',
          status: NotifStatus.read,
        ),
        NotificationItem(
          type: NotifType.stock,
          title: 'Estoque baixo',
          message: 'Restam apenas 5 comprimidos de Losartana. Lembre-se de renovar a receita.',
          time: '18:40',
          status: NotifStatus.read,
        ),
        NotificationItem(
          type: NotifType.exam,
          title: 'Exame de sangue',
          message: 'Resultado do exame de glicemia disponível. Toque para ver o relatório.',
          time: '08:00',
          status: NotifStatus.read,
        ),
      ];

  List<NotificationItem> get _filtered {
    if (_tabIndex == 0) return _allItems;
    if (_tabIndex == 1) {
      return _allItems
          .where((n) =>
              n.type == NotifType.overdueAlert ||
              n.type == NotifType.reminder ||
              n.type == NotifType.stock)
          .toList();
    }
    if (_tabIndex == 2) {
      return _allItems.where((n) => n.type == NotifType.appointment).toList();
    }
    return _allItems
        .where((n) => n.type == NotifType.success || n.type == NotifType.exam)
        .toList();
  }

  int get _unreadCount =>
      _allItems.where((n) => n.status == NotifStatus.unread).length;

  void _clearAll() {
    setState(() {
      for (final item in _allItems) {
        item.status = NotifStatus.read;
      }
    });
  }

  // ── Helpers por tipo ─────────────────────────────────────
  Color _accentColor(NotifType type) {
    switch (type) {
      case NotifType.overdueAlert: return _red;
      case NotifType.reminder:     return _green;
      case NotifType.appointment:  return _orange;
      case NotifType.success:      return _green;
      case NotifType.stock:        return _orange;
      case NotifType.exam:         return _blue;
    }
  }

  Color _iconBgColor(NotifType type) {
    switch (type) {
      case NotifType.overdueAlert: return _redLight;
      case NotifType.reminder:     return _greenLight;
      case NotifType.appointment:  return _orangeLight;
      case NotifType.success:      return _greenLight;
      case NotifType.stock:        return _orangeLight;
      case NotifType.exam:         return _blueLight;
    }
  }

  Color _iconColor(NotifType type) {
    switch (type) {
      case NotifType.overdueAlert: return _red;
      case NotifType.reminder:     return _green;
      case NotifType.appointment:  return _orange;
      case NotifType.success:      return _green;
      case NotifType.stock:        return _orange;
      case NotifType.exam:         return _blue;
    }
  }

  IconData _iconData(NotifType type) {
    switch (type) {
      case NotifType.overdueAlert: return Icons.timer_off_rounded;
      case NotifType.reminder:     return Icons.medication_rounded;
      case NotifType.appointment:  return Icons.event_rounded;
      case NotifType.success:      return Icons.check_circle_rounded;
      case NotifType.stock:        return Icons.inventory_2_rounded;
      case NotifType.exam:         return Icons.science_rounded;
    }
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greyLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.dayLabel != null) ...[
                            if (i != 0) const SizedBox(height: 18),
                            _buildDayLabel(item.dayLabel!),
                          ],
                          _buildNotifCard(item),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              // ── Linha título ──────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Notificações',
                      style: TextStyle(
                        color: _white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: _clearAll,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Text(
                          'Limpar tudo',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // ── Abas ──────────────────────────────────────
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final isSelected = i == _tabIndex;
                    final count = _unreadCounts[i];
                    return GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _white.withOpacity(0.25)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? _white
                                    : _white.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabs[i],
                              style: TextStyle(
                                color: isSelected
                                    ? _white
                                    : _white.withOpacity(0.8),
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (count > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _orange,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: _white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

  // ════════════════════════════════════════════════════════
  //  LABEL DE DATA
  // ════════════════════════════════════════════════════════
  Widget _buildDayLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CARD DE NOTIFICAÇÃO
  //  Usa ClipRRect + Row interno para barra lateral colorida,
  //  evitando o erro "borderRadius with non-uniform border colors"
  // ════════════════════════════════════════════════════════
  Widget _buildNotifCard(NotificationItem item) {
    final isRead     = item.status == NotifStatus.read;
    final accent     = _accentColor(item.type);
    final iconBg     = isRead ? _greyLight : _iconBgColor(item.type);
    final iconClr    = isRead ? _grey      : _iconColor(item.type);
    final titleColor = isRead ? _grey      : _textDark;
    final msgColor   = isRead ? _textMuted : _textGrey;

    return Semantics(
      label: '${item.title}. ${item.message}. Horário: ${item.time}',
      button: true,
      child: GestureDetector(
        onTap: () => setState(() => item.status = NotifStatus.read),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border, width: 1.5),
          ),
          // ClipRRect garante que a barra lateral respeita o borderRadius
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.5),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Barra lateral colorida ──────────────
                  if (!isRead)
                    Container(width: 5, color: accent),

                  // ── Conteúdo ────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ícone
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _iconData(item.type),
                              color: iconClr,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Textos + ações
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.time,
                                      style: const TextStyle(
                                          fontSize: 12, color: _textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.message,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: msgColor,
                                      height: 1.5),
                                ),
                                if (!isRead) ...[
                                  const SizedBox(height: 12),
                                  _buildActions(item),
                                ],
                              ],
                            ),
                          ),

                          // Ponto de não-lida
                          if (!isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Botões de ação por tipo ───────────────────────────────
  Widget _buildActions(NotificationItem item) {
    void markRead() => setState(() => item.status = NotifStatus.read);

    switch (item.type) {
      case NotifType.overdueAlert:
        return Row(
          children: [
            _actionBtn(
                label: '💊  Tomar agora',
                bg: _red,
                fg: _white,
                onTap: markRead),
            const SizedBox(width: 8),
            _actionBtn(
                label: 'Pular dose',
                bg: _white,
                fg: _textDark,
                onTap: markRead,
                border: true),
          ],
        );
      case NotifType.reminder:
        return Row(
          children: [
            _actionBtn(
                label: '✓  Já tomei',
                bg: _green,
                fg: _white,
                onTap: markRead),
            const SizedBox(width: 8),
            _actionBtn(
                label: 'Adiar 30min',
                bg: _white,
                fg: _textDark,
                onTap: markRead,
                border: true),
          ],
        );
      case NotifType.appointment:
        return _actionBtn(
            label: 'Ver detalhes',
            bg: _white,
            fg: _textDark,
            onTap: markRead,
            border: true);
      case NotifType.stock:
        return _actionBtn(
            label: 'Ver medicamento',
            bg: _white,
            fg: _textDark,
            onTap: markRead,
            border: true);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _actionBtn({
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
    bool border = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: border ? Border.all(color: _border, width: 1.5) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: fg),
        ),
      ),
    );
  }

  // ── Estado vazio ─────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 72,
            color: _grey.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma notificação',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: _grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você está em dia com tudo!',
            style: TextStyle(fontSize: 16, color: _textMuted),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTTOM BAR
  // ════════════════════════════════════════════════════════
  Widget _buildBottomBar() {
    final items = <Map<String, dynamic>>[
      {'icon': Icons.medication_outlined,     'label': 'Remédios'},
      {'icon': Icons.bolt_outlined,           'label': 'Atividade'},
      {'icon': Icons.home_rounded,            'label': 'Início'},
      {'icon': Icons.calendar_month_outlined, 'label': 'Agenda'},
      {'icon': Icons.notifications_rounded,   'label': 'Alertas'},
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((e) {
          final isActive = e.key == 4;
          final icon  = e.value['icon']  as IconData;
          final label = e.value['label'] as String;
          return GestureDetector(
            onTap: isActive ? null : () => Navigator.pop(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: isActive ? _green : _grey, size: 30),
                    if (isActive && _unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: _orange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$_unreadCount',
                              style: const TextStyle(
                                color: _white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? _green : _grey,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
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