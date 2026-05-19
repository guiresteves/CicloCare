import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
//  NOTIFICATIONS SCREEN — CicloCare
//  Arquivo: lib/features/notifications/notifications_screen.dart
// ════════════════════════════════════════════════════════════

// ── MODELO ───────────────────────────────────────────────────
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
  });
}

// ── DADOS MOCKADOS ───────────────────────────────────────────
final List<Map<String, dynamic>> mockNotificationGroups = [
  {
    'label': 'Hoje',
    'items': [
      NotificationItem(
        id: '1',
        title: 'Remédio Agendado',
        body: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        time: '2 M',
      ),
      NotificationItem(
        id: '2',
        title: 'Remédio Agendado',
        body: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        time: '2 H',
      ),
      NotificationItem(
        id: '3',
        title: 'Remédio Agendado',
        body: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        time: '3 H',
      ),
    ],
  },
  {
    'label': 'Ontem',
    'items': [
      NotificationItem(
        id: '4',
        title: 'Remédio Agendado',
        body: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        time: '1 D',
      ),
    ],
  },
  {
    'label': '15 de Abril',
    'items': [
      NotificationItem(
        id: '5',
        title: 'Remédio Agendado',
        body: 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
        time: '5 D',
      ),
    ],
  },
];

// ════════════════════════════════════════════════════════════
//  WIDGET PRINCIPAL
// ════════════════════════════════════════════════════════════
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const Color _teal  = Color(0xFF3DB89E);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _grey  = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: seta + título ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: _teal,
                      size: 32,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Notificações',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _teal,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32), // espaçador para centralizar
                ],
              ),
            ),

            // ── Lista agrupada ──────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: mockNotificationGroups.length,
                itemBuilder: (context, groupIndex) {
                  final group = mockNotificationGroups[groupIndex];
                  final items = group['items'] as List<NotificationItem>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge do grupo
                      Container(
                        margin: const EdgeInsets.only(bottom: 16, top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _teal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          group['label'] as String,
                          style: const TextStyle(
                            color: _teal,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      ...items.map((item) => _buildCard(item)),

                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── Bottom bar ─────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ════════════════════════════════════════════════════════
  //  CARD
  // ════════════════════════════════════════════════════════
  Widget _buildCard(NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone redondo teal
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: _teal,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: _white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: TextStyle(fontSize: 12, color: _grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: TextStyle(fontSize: 12, color: _grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  BOTTOM BAR — volta para a home
  // ════════════════════════════════════════════════════════
  Widget _buildBottomBar(BuildContext context) {
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
        child: GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.home_rounded, color: _white, size: 28),
          ),
        ),
      ),
    );
  }
}