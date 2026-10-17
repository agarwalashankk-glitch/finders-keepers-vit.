import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/item_model.dart';
import '../../../models/item_status.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/claim_providers.dart';
import '../../../providers/item_providers.dart';
import '../../../providers/match_providers.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_indicator.dart';
import '../claims/claim_details_screen.dart';
import '../claims/submit_claim_screen.dart';
import 'widgets/potential_match_card.dart';
import 'widgets/status_badge.dart';

class ItemDetailsScreen extends ConsumerWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(singleItemProvider(itemId));
    final currentUser = ref.watch(currentUserProvider);
    final eventsAsync = ref.watch(itemEventsProvider(itemId));

    return itemAsync.when(
      data: (item) {
        if (item == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Item not found or has been removed.')),
          );
        }

        final isReporter = currentUser != null && currentUser.uid == item.reporterId;
        final matches = ref.watch(potentialMatchesProvider(item));

        return Scaffold(
          appBar: AppBar(
            title: Text(item.reportType.displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                tooltip: 'Report suspicious listing',
                onPressed: () => _showFlagDialog(context, ref, item),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(context, ref, item, isReporter),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header or Carousel
                _buildImageSection(item),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges Row
                      Row(
                        children: [
                          ReportTypeBadge(reportType: item.reportType),
                          const SizedBox(width: 8),
                          StatusBadge(status: item.status),
                          const Spacer(),
                          Text(
                            DateFormatter.formatShort(item.incidentDateTime),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Item Title
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Approximate Location Card (Privacy Guard)
                      _buildLocationPrivacyCard(item),

                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Item Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Potential Matches Section (Section 9)
                      if (matches.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              'Potential Matches',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${matches.length} found',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Heuristic comparison based on category, keywords, proximity & time.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...matches.take(2).map(
                              (match) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: PotentialMatchCard(
                                  match: match,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ItemDetailsScreen(
                                            itemId: match.candidateItem.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        const SizedBox(height: 20),
                      ],

                      // Event / Status Audit Timeline (Section 8)
                      const Text(
                        'Item Status Timeline',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      eventsAsync.when(
                        data: (events) => _buildEventTimeline(events),
                        loading: () => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildImageSection(ItemModel item) {
    if (item.imageUrls.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 8),
              Text(
                'No photograph attached to this report',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: PageView.builder(
        itemCount: item.imageUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: item.imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.surfaceVariant,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  Widget _buildLocationPrivacyCard(ItemModel item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Approximate Campus Location',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Privacy Protected',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.approximateLocation.zoneName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (item.approximateLocation.areaDetail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.approximateLocation.areaDetail,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventTimeline(List<dynamic> events) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: events.map((event) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 10, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.notes.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormatter.formatFull(event.timestamp as DateTime),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    WidgetRef ref,
    ItemModel item,
    bool isReporter,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: isReporter
            ? _buildReporterActions(context, ref, item)
            : _buildClaimantActions(context, item),
      ),
    );
  }

  Widget _buildReporterActions(BuildContext context, WidgetRef ref, ItemModel item) {
    if (item.reportType == ItemReportType.found) {
      return CustomButton(
        text: 'Review Submitted Claims (${item.activeClaimCount})',
        icon: Icons.assignment_outlined,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ClaimDetailsScreen(item: item),
            ),
          );
        },
      );
    } else {
      // Owner of lost item
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: item.status == ItemStatus.returned ? 'Recovered' : 'Mark as Recovered',
              icon: Icons.check,
              backgroundColor: AppColors.success,
              onPressed: item.status == ItemStatus.returned
                  ? null
                  : () async {
                      final confirmed = await ConfirmationDialog.show(
                        context: context,
                        title: 'Confirm Item Recovery',
                        message: 'Did you recover your lost item?',
                        confirmText: 'Yes, Recovered',
                      );
                      if (confirmed == true) {
                        final user = ref.read(currentUserProvider)!;
                        await ref.read(itemRepositoryProvider).updateItemStatus(
                              itemId: item.id,
                              newStatus: ItemStatus.returned,
                              userId: user.uid,
                              userName: user.displayName,
                              reasonNote: 'Recovered by original owner.',
                            );
                        ref.invalidate(singleItemProvider(item.id));
                      }
                    },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildClaimantActions(BuildContext context, ItemModel item) {
    if (!item.canBeClaimed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          item.status == ItemStatus.returned
              ? 'This item has already been successfully returned.'
              : 'This listing is not currently accepting claims.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return CustomButton(
      text: 'Claim this Item',
      icon: Icons.verified_user_outlined,
      backgroundColor: AppColors.primary,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SubmitClaimScreen(item: item),
          ),
        );
      },
    );
  }

  Future<void> _showFlagDialog(BuildContext context, WidgetRef ref, ItemModel item) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Report Listing'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason why this listing appears suspicious, fraudulent, or violates campus guidelines:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Inappropriate photo, duplicate report, spam',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      final user = ref.read(currentUserProvider);
      await ref.read(itemRepositoryProvider).flagItem(
            itemId: item.id,
            reason: reasonController.text.trim(),
            reportingUserId: user?.uid ?? 'anonymous',
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing flagged for moderator review. Thank you.')),
        );
      }
    }
  }
}
