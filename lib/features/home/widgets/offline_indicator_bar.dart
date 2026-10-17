import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/connectivity_providers.dart';

class OfflineIndicatorBar extends ConsumerWidget {
  const OfflineIndicatorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineAsync = ref.watch(isOnlineProvider);
    final isOnline = onlineAsync.value ?? ref.watch(connectivityServiceProvider).isOnline;

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            'Offline Mode — Viewing cached reports. New drafts will save locally.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
