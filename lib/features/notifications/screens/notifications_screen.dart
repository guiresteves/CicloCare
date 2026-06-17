import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/notification_item.dart';
import '../mock/mock_notification_service.dart';

// ════════════════════════════════════════════════════════════
//  NOTIFICATIONS SCREEN — CicloCare
//  Arquivo: lib/features/notifications/screens/notifications_screen.dart
// ════════════════════════════════════════════════════════════

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory? _filter; // null = todos

  List<NotificationItem> get _items =>
      MockNotificationService.instance.getAll();

  List<NotificationItem> get _filtered {
    if (_filter == null) return _items;
    return _items.where((n) => n.category == _filter).toList();
  }

  // Agrupa por groupLabel: Hoje / Ontem / Anteriores
  Map<String, List<NotificationItem>> get _grouped {
    final map = <String, List<NotificationItem>>{};
    for (final item in _filtered) {
      map.putIfAbsent(item.groupLabel, () => []).add(item);
    }
    return map;
  }

  static const _groupOrder = ['Hoje', 'Ontem', 'Anteriores'];

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    final groups = _groupOrder.where((g) => grouped.containsKey(g)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notificações'),
        actions: [
          if (MockNotificationService.instance.unreadCount > 0)
            TextButton(
              onPressed: () {
                MockNotificationService.instance.markAllRead();
                setState(() {});
              },
              child: Text(
                'Marcar todas',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: groups.length,
                    itemBuilder: (_, i) {
                      final group = groups[i];
                      final items = grouped[group]!;
                      return _buildGroup(group, items);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Barra de filtros ─────────────────────────────────────
  Widget _buildFilterBar() {
    final filters = <NotificationCategory?>[
      null,
      NotificationCategory.medication,
      NotificationCategory.exam,
      NotificationCategory.consultation,
    ];
    final labels = ['Todos', 'Remédios', 'Exames', 'Consultas'];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final sel = _filter == filters[i];
            return GestureDetector(
              onTap: () => setState(() => _filter = filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.inputBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: AppTextStyles.labelMedium.copyWith(
                    color: sel ? AppColors.white : AppColors.textSecondary,
                    fontWeight:
                        sel ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Grupo de data ────────────────────────────────────────
  Widget _buildGroup(String label, List<NotificationItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          child: Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider()),
          ]),
        ),
        ...items.map((item) => _buildCard(item)),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Card de notificação ──────────────────────────────────
  Widget _buildCard(NotificationItem item) {
    final color = _accentColor(item.action);
    final iconBg = color.withOpacity(0.1);

    return GestureDetector(
      onTap: () {
        MockNotificationService.instance.markRead(item.id);
        setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surface : AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.isRead
                ? AppColors.divider
                : color.withOpacity(0.35),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: item.isRead
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra lateral colorida (apenas não lidas)
                if (!item.isRead)
                  Container(width: 5, color: color),

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
                            color: item.isRead
                                ? AppColors.inputBg
                                : iconBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _iconData(item.action),
                            color: item.isRead
                                ? AppColors.textHint
                                : color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Conteúdo
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título + hora
                              Row(children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      color: item.isRead
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.formattedTime,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 6),

                              // Descrição
                              Text(
                                item.description,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: item.isRead
                                      ? AppColors.textHint
                                      : AppColors.textSecondary,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Badge de categoria
                              Row(children: [
                                _categoryBadge(item.category, color,
                                    item.isRead),
                              ]),
                            ],
                          ),
                        ),

                        // Ponto de não lida
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: color,
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
    );
  }

  Widget _categoryBadge(
      NotificationCategory cat, Color color, bool isRead) {
    String label;
    switch (cat) {
      case NotificationCategory.medication:
        label = 'Remédio';
        break;
      case NotificationCategory.exam:
        label = 'Exame';
        break;
      case NotificationCategory.consultation:
        label = 'Consulta';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isRead ? AppColors.inputBg : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isRead ? AppColors.textHint : color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Vazio ────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhuma notificação',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Suas notificações aparecerão aqui.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ── Mapeamentos ──────────────────────────────────────────
  Color _accentColor(NotificationAction action) {
    switch (action) {
      case NotificationAction.medicationTaken:
      case NotificationAction.examCompleted:
      case NotificationAction.consultationCompleted:
      case NotificationAction.medicationAdded:
      case NotificationAction.examScheduled:
      case NotificationAction.consultationScheduled:
        return AppColors.success;

      case NotificationAction.medicationSkipped:
      case NotificationAction.medicationReminder:
      case NotificationAction.medicationDue:
      case NotificationAction.examUpcoming:
        return AppColors.warning;

      case NotificationAction.medicationRemoved:
      case NotificationAction.examCancelled:
      case NotificationAction.consultationCancelled:
        return AppColors.error;

      case NotificationAction.medicationEdited:
      case NotificationAction.examRescheduled:
      case NotificationAction.consultationRescheduled:
        return AppColors.info;
    }
  }

  IconData _iconData(NotificationAction action) {
    switch (action) {
      case NotificationAction.medicationAdded:
        return Icons.add_circle_outline_rounded;
      case NotificationAction.medicationReminder:
      case NotificationAction.medicationDue:
        return Icons.alarm_rounded;
      case NotificationAction.medicationTaken:
        return Icons.check_circle_outline_rounded;
      case NotificationAction.medicationSkipped:
        return Icons.skip_next_rounded;
      case NotificationAction.medicationEdited:
        return Icons.edit_outlined;
      case NotificationAction.medicationRemoved:
        return Icons.delete_outline_rounded;

      case NotificationAction.examScheduled:
        return Icons.event_available_rounded;
      case NotificationAction.examUpcoming:
        return Icons.event_note_rounded;
      case NotificationAction.examCompleted:
        return Icons.task_alt_rounded;
      case NotificationAction.examCancelled:
        return Icons.event_busy_rounded;
      case NotificationAction.examRescheduled:
        return Icons.update_rounded;

      case NotificationAction.consultationScheduled:
        return Icons.calendar_month_rounded;
      case NotificationAction.consultationCompleted:
        return Icons.how_to_reg_rounded;
      case NotificationAction.consultationCancelled:
        return Icons.cancel_outlined;
      case NotificationAction.consultationRescheduled:
        return Icons.edit_calendar_rounded;
    }
  }
}