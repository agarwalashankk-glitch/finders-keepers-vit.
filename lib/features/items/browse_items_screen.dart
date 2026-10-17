import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_status.dart';
import '../../../providers/item_providers.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_indicator.dart';
import 'item_details_screen.dart';
import 'widgets/item_card.dart';
import 'widgets/item_filter_sheet.dart';

class BrowseItemsScreen extends ConsumerStatefulWidget {
  const BrowseItemsScreen({super.key});

  @override
  ConsumerState<BrowseItemsScreen> createState() => _BrowseItemsScreenState();
}

class _BrowseItemsScreenState extends ConsumerState<BrowseItemsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(itemFilterProvider);
    final filterNotifier = ref.read(itemFilterProvider.notifier);
    final itemsAsync = ref.watch(filteredItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Board'),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list),
                if (filter.reportType != null ||
                    filter.category != null ||
                    filter.status != null ||
                    filter.zoneId != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => ItemFilterSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Toggle Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items by keywords...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                filterNotifier.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (val) {
                      filterNotifier.setSearchQuery(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lost vs Found Segmented Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                _buildSegmentButton(
                  title: 'All',
                  isSelected: filter.reportType == null,
                  onTap: () => filterNotifier.setReportType(null),
                ),
                const SizedBox(width: 8),
                _buildSegmentButton(
                  title: 'Lost Items',
                  isSelected: filter.reportType == ItemReportType.lost,
                  activeColor: AppColors.lostColor,
                  onTap: () => filterNotifier.setReportType(ItemReportType.lost),
                ),
                const SizedBox(width: 8),
                _buildSegmentButton(
                  title: 'Found Items',
                  isSelected: filter.reportType == ItemReportType.found,
                  activeColor: AppColors.foundColor,
                  onTap: () => filterNotifier.setReportType(ItemReportType.found),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Active Filters chips
          if (filter.category != null || filter.status != null || filter.zoneId != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filter.category != null)
                      _buildActiveFilterChip(
                        label: 'Category: ${filter.category}',
                        onDeleted: () => filterNotifier.setCategory(null),
                      ),
                    if (filter.status != null)
                      _buildActiveFilterChip(
                        label: 'Status: ${filter.status!.displayName}',
                        onDeleted: () => filterNotifier.setStatus(null),
                      ),
                    if (filter.zoneId != null)
                      _buildActiveFilterChip(
                        label: 'Zone: ${filter.zoneId!.toUpperCase()}',
                        onDeleted: () => filterNotifier.setZone(null),
                      ),
                  ],
                ),
              ),
            ),

          // Items List
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No Items Found',
                    message:
                        'No reported items match your current search and filter criteria.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
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
              loading: () => const LoadingIndicator(message: 'Searching items...'),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required bool isSelected,
    Color activeColor = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: onDeleted,
        backgroundColor: AppColors.primary.withOpacity(0.08),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
