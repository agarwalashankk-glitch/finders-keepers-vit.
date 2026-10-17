import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_status.dart';
import '../../../providers/item_providers.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';
import '../items/item_details_screen.dart';
import '../items/widgets/item_card.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Lost Items'),
            Tab(text: 'Found Items'),
          ],
        ),
      ),
      body: reportsAsync.when(
        data: (items) {
          final lostItems = items.where((i) => i.isLost).toList();
          final foundItems = items.where((i) => i.isFound).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(lostItems, 'No lost items reported yet.'),
              _buildList(foundItems, 'No found items reported yet.'),
            ],
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading your reports...'),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildList(List<dynamic> items, String emptyMessage) {
    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.inventory_2_outlined,
        title: 'No Reports',
        message: emptyMessage,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
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
  }
}
