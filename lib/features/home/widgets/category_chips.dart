import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/item_providers.dart';

class CategoryChips extends ConsumerWidget {
  final void Function(String category) onCategorySelected;

  const CategoryChips({super.key, required this.onCategorySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategory = ref.watch(itemFilterProvider).category;

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? 'All' : AppConstants.categories[index - 1];
          final isSelected = isAll
              ? (activeCategory == null || activeCategory == 'All')
              : activeCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
          );
        },
      ),
    );
  }
}
