import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/claim_model.dart';
import '../../../providers/claim_providers.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../items/item_details_screen.dart';

class MyClaimsScreen extends ConsumerWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myClaimsAsync = ref.watch(myClaimsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
      ),
      body: myClaimsAsync.when(
        data: (claims) {
          if (claims.isEmpty) {
            return const EmptyStateView(
              icon: Icons.assignment_outlined,
              title: 'No Claims Submitted',
              message:
                  'If you see an item on the campus board that belongs to you, submit an ownership claim to initiate the verification process.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final claim = claims[index];
              return _buildMyClaimCard(context, claim);
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading your claims...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMyClaimCard(BuildContext context, ClaimModel claim) {
    final isVerified = claim.status == ClaimStatus.verified;
    final isRejected = claim.status == ClaimStatus.rejected;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBadge(claim.status),
                const Spacer(),
                Text(
                  DateFormatter.formatShort(claim.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              claim.itemTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${claim.itemCategory}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // If Verified: Show 6-digit Handover Code Prominently!
            if (isVerified && claim.handoverVerificationCode != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.verifiedColor.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'YOUR HANDOVER VERIFICATION CODE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.verifiedColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      claim.handoverVerificationCode!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.verifiedColor,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Present this 6-digit code to the finder when you meet on campus to collect your item.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (isRejected && claim.reviewerNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lostBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Finder note: ${claim.reviewerNotes}',
                        style: const TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View Item Listing'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ItemDetailsScreen(itemId: claim.itemId),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(ClaimStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case ClaimStatus.pending:
      case ClaimStatus.under_review:
        bg = AppColors.claimedBackground;
        fg = AppColors.claimedColor;
        break;
      case ClaimStatus.verified:
        bg = AppColors.verifiedBackground;
        fg = AppColors.verifiedColor;
        break;
      case ClaimStatus.rejected:
        bg = AppColors.lostBackground;
        fg = AppColors.lostColor;
        break;
      case ClaimStatus.cancelled:
        bg = AppColors.closedBackground;
        fg = AppColors.closedColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
