import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/item_providers.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../items/item_details_screen.dart';

class AdminModerationScreen extends ConsumerWidget {
  const AdminModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final allItemsAsync = ref.watch(filteredItemsProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Text('You do not have moderator/admin permissions.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Moderation Panel'),
      ),
      body: allItemsAsync.when(
        data: (items) {
          final flaggedItems = items.where((i) => i.isFlagged).toList();
          final allActiveCount = items.length;
          final lostCount = items.where((i) => i.isLost).length;
          final foundCount = items.where((i) => i.isFound).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Summary
                Row(
                  children: [
                    _buildStatCard('Total Reports', '$allActiveCount', AppColors.primary),
                    const SizedBox(width: 8),
                    _buildStatCard('Lost', '$lostCount', AppColors.lostColor),
                    const SizedBox(width: 8),
                    _buildStatCard('Found', '$foundCount', AppColors.foundColor),
                    const SizedBox(width: 8),
                    _buildStatCard('Flagged', '${flaggedItems.length}', AppColors.warning),
                  ],
                ),
                const SizedBox(height: 24),

                // Flagged Items
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    const SizedBox(width: 8),
                    const Text(
                      'Flagged / Suspicious Reports',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reports reported by campus students requiring administrative review.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),

                if (flaggedItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: EmptyStateView(
                      icon: Icons.verified_user,
                      title: 'No Flagged Content',
                      message: 'No reports are currently flagged for moderation.',
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: flaggedItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = flaggedItems[index];
                      return _buildFlaggedItemCard(context, ref, item);
                    },
                  ),

                const SizedBox(height: 24),

                // All Campus Reports
                const Text(
                  'All Campus Listings (Moderator Quick Actions)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.take(10).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Text(
                          '${item.reportType.displayName} • ${item.category} • ${item.status.displayName}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_forever, color: AppColors.error),
                          tooltip: 'Take down listing',
                          onPressed: () => _handleDelete(context, ref, item),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ItemDetailsScreen(itemId: item.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading moderation data...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlaggedItemCard(BuildContext context, WidgetRef ref, ItemModel item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lostBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'FLAGGED',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${item.flagReason ?? 'Marked suspicious by student'}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsScreen(itemId: item.id),
                      ),
                    );
                  },
                  child: const Text('Inspect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () => _handleDelete(context, ref, item),
                  child: const Text('Delete Listing'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref, ItemModel item) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Remove Listing?',
      message: 'Are you sure you want to permanently remove "${item.title}" from the campus board?',
      confirmText: 'Remove',
      isDestructive: true,
    );

    if (confirmed == true) {
      await ref.read(itemRepositoryProvider).moderateDeleteItem(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing removed by moderator.')),
        );
      }
    }
  }
}
