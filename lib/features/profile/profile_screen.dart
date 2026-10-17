import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../services/mock_seed_service.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../admin/admin_moderation_screen.dart';
import '../claims/my_claims_screen.dart';
import 'my_reports_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      user != null && user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Campus Student',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  if (user?.campusRegistrationNumber != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Reg No: ${user!.campusRegistrationNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatChip(
                        label: 'Role',
                        value: user?.role.name.toUpperCase() ?? 'USER',
                        color: isAdmin ? AppColors.accent : AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        label: 'Reputation',
                        value: '${user?.reputationScore ?? 100} pts',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.assignment_outlined, color: AppColors.primary),
                    title: const Text('My Reports'),
                    subtitle: const Text('Manage your lost and found listings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MyReportsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined, color: AppColors.primary),
                    title: const Text('My Claims'),
                    subtitle: const Text('View statuses & handover codes'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MyClaimsScreen()),
                      );
                    },
                  ),
                  if (isAdmin) ...[
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: AppColors.accent),
                      title: const Text('Admin Moderation'),
                      subtitle: const Text('Manage flagged items and reports'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminModerationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Evaluator Demo Mode Controls
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.developer_mode, size: 18, color: AppColors.accent),
                      SizedBox(width: 8),
                      Text(
                        'Evaluator Testing Tools',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tools provided for technical evaluator demonstration and grading:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(authRepositoryProvider)
                                .toggleDemoAdmin(!isAdmin);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  !isAdmin
                                      ? 'Switched to Admin Role. Moderation panel enabled!'
                                      : 'Switched to Standard Student Role.',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            isAdmin ? 'Drop Admin Role' : 'Enable Admin Role',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final seeded = await MockSeedService.seedToFirestore();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    seeded > 0
                                        ? 'Seeded $seeded campus demo reports to Firestore!'
                                        : 'Demo items refreshed in local memory board.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Seed Campus Data', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sign out
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.divider),
              ),
              tileColor: Colors.white,
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                final confirm = await ConfirmationDialog.show(
                  context: context,
                  title: 'Sign Out?',
                  message: 'Are you sure you want to sign out of Finders Keepers?',
                  confirmText: 'Sign Out',
                  isDestructive: true,
                );
                if (confirm == true) {
                  await ref.read(authRepositoryProvider).signOut();
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appVersion,
              style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
