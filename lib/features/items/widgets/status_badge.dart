import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_status.dart';

class StatusBadge extends StatelessWidget {
  final ItemStatus status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case ItemStatus.lost:
        bg = AppColors.lostBackground;
        fg = AppColors.lostColor;
        icon = Icons.search;
        break;
      case ItemStatus.found:
        bg = AppColors.foundBackground;
        fg = AppColors.foundColor;
        icon = Icons.check_circle_outline;
        break;
      case ItemStatus.claimed:
        bg = AppColors.claimedBackground;
        fg = AppColors.claimedColor;
        icon = Icons.hourglass_top;
        break;
      case ItemStatus.verified:
        bg = AppColors.verifiedBackground;
        fg = AppColors.verifiedColor;
        icon = Icons.verified_user_outlined;
        break;
      case ItemStatus.returned:
        bg = AppColors.returnedBackground;
        fg = AppColors.returnedColor;
        icon = Icons.handshake_outlined;
        break;
      case ItemStatus.closed:
        bg = AppColors.closedBackground;
        fg = AppColors.closedColor;
        icon = Icons.archive_outlined;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isSmall ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: fg,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportTypeBadge extends StatelessWidget {
  final ItemReportType reportType;

  const ReportTypeBadge({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    final isLost = reportType == ItemReportType.lost;
    final bg = isLost ? AppColors.lostBackground : AppColors.foundBackground;
    final fg = isLost ? AppColors.lostColor : AppColors.foundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isLost ? 'LOST' : 'FOUND',
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
