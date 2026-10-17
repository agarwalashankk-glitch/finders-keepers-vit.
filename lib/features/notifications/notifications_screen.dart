import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/notification_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../repositories/notification_repository.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../items/item_details_screen.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final userNotificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return repo.watchUserNotifications(user.uid);
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                ref.read(notificationRepositoryProvider).markAllAsRead(user.uid);
              }
            },
          ),
        ],
      ),
      body: notifsAsync.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return const EmptyStateView(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              message:
                  'You will receive notifications when someone claims an item you found, or when a potential match is discovered.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = notifs[index];
              return _buildNotificationCard(context, ref, notif);
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading notifications...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notif,
  ) {
    IconData icon;
    Color color;

    switch (notif.type) {
      case NotificationType.claimSubmitted:
        icon = Icons.assignment_ind_outlined;
        color = AppColors.claimedColor;
        break;
      case NotificationType.claimVerified:
        icon = Icons.verified_outlined;
        color = AppColors.verifiedColor;
        break;
      case NotificationType.claimRejected:
        icon = Icons.cancel_outlined;
        color = AppColors.error;
        break;
      case NotificationType.potentialMatch:
        icon = Icons.auto_awesome;
        color = AppColors.accent;
        break;
      case NotificationType.itemReturned:
        icon = Icons.handshake_outlined;
        color = AppColors.returnedColor;
        break;
      case NotificationType.adminAlert:
        icon = Icons.admin_panel_settings_outlined;
        color = AppColors.primary;
        break;
    }

    return Card(
      elevation: notif.isRead ? 0 : 2,
      color: notif.isRead ? Colors.white : AppColors.surfaceVariant.withOpacity(0.5),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif.body,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormatter.formatRelative(notif.createdAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
        onTap: () {
          ref.read(notificationRepositoryProvider).markAsRead(notif.id);
          if (notif.relatedItemId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(itemId: notif.relatedItemId!),
              ),
            );
          }
        },
      ),
    );
  }
}
