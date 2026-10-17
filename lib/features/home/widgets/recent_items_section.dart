import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_model.dart';
import '../../../providers/item_providers.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../../items/item_details_screen.dart';
import '../../items/widgets/item_card.dart';

class RecentItemsSection extends ConsumerWidget {
  final VoidCallback onSeeAll;

  const RecentItemsSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentItemsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        recentAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyStateView(
                icon: Icons.inventory_2_outlined,
                title: 'No Active Reports',
                message: 'All campus items are accounted for right now.',
              );
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsScreen(itemId: item.id),
                      ),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(32.0),
            child: LoadingIndicator(message: 'Loading campus board...'),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading items: $err'),
          ),
        ),
      ],
    );
  }
}
