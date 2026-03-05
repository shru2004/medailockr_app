// ─── Notifications Screen ────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/page_wrapper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'reminder': return Icons.access_alarm_rounded;
      case 'message':  return Icons.message_rounded;
      case 'record':   return Icons.folder_rounded;
      default:         return Icons.event_note_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'reminder': return AppColors.primaryBlue;
      case 'message':  return const Color(0xFF10B981);
      case 'record':   return const Color(0xFF8B5CF6);
      default:         return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppStateProvider>();

    return PageWrapper(
      title: 'Notifications',
      actions: [
        TextButton(onPressed: app.markAllRead, child: const Text('Mark all read', style: TextStyle(fontSize: 13, color: AppColors.primaryBlue))),
      ],
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: app.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final n = app.notifications[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: n.unread ? AppColors.primaryBlue.withValues(alpha: 0.04) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: n.unread ? AppColors.primaryBlue.withValues(alpha: 0.2) : AppColors.border),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: _colorFor(n.type).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_iconFor(n.type), color: _colorFor(n.type), size: 20)),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (n.unread) ...[const SizedBox(width: 6), Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryBlue))],
                ]),
                const SizedBox(height: 4),
                Text(n.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 4),
                Text(n.timestamp, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
            ]),
          );
        },
      ),
    );
  }
}
