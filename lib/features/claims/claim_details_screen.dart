import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../models/claim_model.dart';
import '../../../models/item_model.dart';
import '../../../models/item_status.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/claim_providers.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';

class ClaimDetailsScreen extends ConsumerStatefulWidget {
  final ItemModel item;

  const ClaimDetailsScreen({super.key, required this.item});

  @override
  ConsumerState<ClaimDetailsScreen> createState() => _ClaimDetailsScreenState();
}

class _ClaimDetailsScreenState extends ConsumerState<ClaimDetailsScreen> {
  final _handoverCodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _handoverCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final claimsAsync = ref.watch(itemClaimsProvider(widget.item.id));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Submitted Claims'),
      ),
      body: claimsAsync.when(
        data: (claims) {
          if (claims.isEmpty) {
            return const EmptyStateView(
              icon: Icons.assignment_late_outlined,
              title: 'No Claims Submitted Yet',
              message:
                  'When students claim ownership of this found item, their private verification proof will appear here.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final claim = claims[index];
              return _buildClaimReviewCard(claim, currentUser);
            },
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading claims...'),
        error: (err, _) => Center(child: Text('Error loading claims: $err')),
      ),
    );
  }

  Widget _buildClaimReviewCard(ClaimModel claim, dynamic currentUser) {
    final isVerified = claim.status == ClaimStatus.verified;
    final isRejected = claim.status == ClaimStatus.rejected;
    final isPending = claim.status == ClaimStatus.pending || claim.status == ClaimStatus.under_review;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isVerified
              ? AppColors.verifiedColor
              : (isRejected ? AppColors.divider : AppColors.primaryLight.withOpacity(0.4)),
          width: isVerified ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Date Header
            Row(
              children: [
                _buildClaimStatusBadge(claim.status),
                const Spacer(),
                Text(
                  DateFormatter.formatRelative(claim.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Claimant Info (Masked for privacy)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    claim.claimantName.isNotEmpty ? claim.claimantName[0] : 'S',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claim.claimantName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    Text(
                      claim.claimantEmail,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Verification Evidence Section
            const Text(
              'Distinguishing Features & Marks:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              claim.distinguishingFeatures,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
            ),
            const SizedBox(height: 12),

            const Text(
              'Hidden Contents / Internal Proof:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              claim.hiddenContents,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.35),
            ),
            const SizedBox(height: 12),

            if (claim.serialOrIdentifier.isNotEmpty) ...[
              const Text(
                'Serial / Identifier Code:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                claim.serialOrIdentifier,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
            ],

            const Text(
              'Circumstance of Loss:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              claim.lossCircumstance,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
            ),

            // Proof Images
            if (claim.proofImageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Claimant Attached Proof:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: claim.proofImageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, idx) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: claim.proofImageUrls[idx],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],

            // Handover Code Verification Section (If Verified)
            if (isVerified) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.verifiedBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.verifiedColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, color: AppColors.verifiedColor, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Ownership Verified — Ready for Handover',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.verifiedColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When meeting the student on campus, ask them for their 6-digit handover code. Enter it below to complete the secure handover.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _handoverCodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              counterText: '',
                              hintText: 'Enter 6-digit code',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verifiedColor,
                          ),
                          onPressed: () => _handleCompleteHandover(claim, currentUser),
                          child: const Text('Confirm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (Approve / Reject) for Pending Claims
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () => _handleReject(claim, currentUser),
                      child: const Text('Reject Claim'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verifiedColor,
                      ),
                      onPressed: () => _handleApprove(claim, currentUser),
                      child: const Text('Verify & Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClaimStatusBadge(ClaimStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _handleApprove(ClaimModel claim, dynamic currentUser) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Approve Ownership Claim?',
      message:
          'Have you verified that the distinguishing marks and hidden contents match your found item? This will lock the item to this owner and generate a secure handover code.',
      confirmText: 'Verify & Approve',
      confirmColor: AppColors.verifiedColor,
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        final claimRepo = ref.read(claimRepositoryProvider);
        await claimRepo.approveClaim(
          claimId: claim.id,
          reviewerId: currentUser?.uid ?? 'finder',
          reviewerName: currentUser?.displayName ?? 'Finder',
          reviewerNotes: 'Verified hidden proof matches item.',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Claim approved! Handover code generated.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Approval error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleReject(ClaimModel claim, dynamic currentUser) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a brief reason why the evidence does not match:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'e.g. Identifying marks or wallet cards do not match.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final claimRepo = ref.read(claimRepositoryProvider);
      await claimRepo.rejectClaim(
        claimId: claim.id,
        reviewerId: currentUser?.uid ?? 'finder',
        reviewerName: currentUser?.displayName ?? 'Finder',
        rejectionReason: reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : 'Evidence does not match found item.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim rejected.')),
        );
      }
    }
  }

  Future<void> _handleCompleteHandover(ClaimModel claim, dynamic currentUser) async {
    final code = _handoverCodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit handover code')),
      );
      return;
    }

    final claimRepo = ref.read(claimRepositoryProvider);
    final isMatch = await claimRepo.verifyHandoverCodeAndComplete(
      claimId: claim.id,
      enteredCode: code,
      finderUserId: currentUser?.uid ?? 'finder',
      finderUserName: currentUser?.displayName ?? 'Finder',
    );

    if (isMatch) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Handover confirmed! Item marked as RETURNED.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incorrect handover code. Please check with claimant.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
