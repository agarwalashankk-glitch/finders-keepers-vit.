import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_status.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/item_providers.dart';
import '../items/report_item_screen.dart';
import '../notifications/notifications_screen.dart';
import 'widgets/category_chips.dart';
import 'widgets/offline_indicator_bar.dart';
import 'widgets/quick_action_cards.dart';
import 'widgets/recent_items_section.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.travel_explore, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Finders Keepers?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  user != null ? 'Hello, ${user.displayName}' : 'VIT Campus Community',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineIndicatorBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(recentItemsProvider);
                ref.invalidate(filteredItemsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Tap Box
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: InkWell(
                        onTap: () {
                          if (onNavigateTab != null) {
                            onNavigateTab!(1); // Go to Browse tab
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search, color: AppColors.textTertiary, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'Search lost keys, ID cards, electronics...',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Quick Action Buttons (Lost vs Found)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: QuickActionCards(
                        onReportTap: (reportType) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReportItemScreen(initialType: reportType),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Category Filter Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Browse by Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CategoryChips(
                      onCategorySelected: (cat) {
                        ref.read(itemFilterProvider.notifier).setCategory(cat);
                        if (onNavigateTab != null) {
                          onNavigateTab!(1);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Recent Items
                    RecentItemsSection(
                      onSeeAll: () {
                        if (onNavigateTab != null) {
                          onNavigateTab!(1);
                        }
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
