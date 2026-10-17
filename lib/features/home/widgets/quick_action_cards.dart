import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_status.dart';

class QuickActionCards extends StatelessWidget {
  final void Function(ItemReportType type) onReportTap;

  const QuickActionCards({super.key, required this.onReportTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Report Lost Item Card
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onReportTap(ItemReportType.lost),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lostColor.withOpacity(0.3), width: 1.5),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lostBackground.withOpacity(0.4),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.lostColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.search, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'I Lost an Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Post item details for campus community',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Report Found Item Card
        Expanded(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onReportTap(ItemReportType.found),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.foundColor.withOpacity(0.3), width: 1.5),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.foundBackground.withOpacity(0.4),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.foundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'I Found an Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Safeguard & review ownership claims',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
