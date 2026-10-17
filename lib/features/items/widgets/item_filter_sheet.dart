import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/campus_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_status.dart';
import '../../../providers/item_providers.dart';

class ItemFilterSheet extends ConsumerWidget {
  const ItemFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ItemFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(itemFilterProvider);
    final notifier = ref.read(itemFilterProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Listings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => notifier.resetFilters(),
                  child: const Text('Reset All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Filter options list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Report Type (All, Lost, Found)
                const Text(
                  'Report Type',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildChoiceChip(
                      label: 'All Reports',
                      isSelected: filter.reportType == null,
                      onSelected: () => notifier.setReportType(null),
                    ),
                    const SizedBox(width: 8),
                    _buildChoiceChip(
                      label: 'Lost Only',
                      isSelected: filter.reportType == ItemReportType.lost,
                      onSelected: () => notifier.setReportType(ItemReportType.lost),
                    ),
                    const SizedBox(width: 8),
                    _buildChoiceChip(
                      label: 'Found Only',
                      isSelected: filter.reportType == ItemReportType.found,
                      onSelected: () => notifier.setReportType(ItemReportType.found),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Status Filter
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'All Statuses',
                      isSelected: filter.status == null,
                      onSelected: () => notifier.setStatus(null),
                    ),
                    ...ItemStatus.values.map(
                      (status) => _buildChoiceChip(
                        label: status.displayName,
                        isSelected: filter.status == status,
                        onSelected: () => notifier.setStatus(status),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Category Filter
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'All Categories',
                      isSelected: filter.category == null,
                      onSelected: () => notifier.setCategory(null),
                    ),
                    ...AppConstants.categories.map(
                      (cat) => _buildChoiceChip(
                        label: cat,
                        isSelected: filter.category == cat,
                        onSelected: () => notifier.setCategory(cat),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Campus Zone Filter
                const Text(
                  'Campus Zone',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChoiceChip(
                      label: 'All Campus Zones',
                      isSelected: filter.zoneId == null,
                      onSelected: () => notifier.setZone(null),
                    ),
                    ...CampusLocations.zones.map(
                      (zone) => _buildChoiceChip(
                        label: zone.shortCode,
                        isSelected: filter.zoneId == zone.id,
                        onSelected: () => notifier.setZone(zone.id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
