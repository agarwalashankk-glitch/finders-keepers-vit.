import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Campus Navy
  static const Color primaryLight = Color(0xFF3B82F6); // Royal Blue
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Navy
  static const Color accent = Color(0xFF06B6D4); // Cyan Accent

  // Status colors
  static const Color lostColor = Color(0xFFDC2626); // Crimson Red for Lost
  static const Color lostBackground = Color(0xFFFEE2E2);
  static const Color foundColor = Color(0xFF059669); // Emerald Green for Found
  static const Color foundBackground = Color(0xFFD1FAE5);
  
  static const Color claimedColor = Color(0xFFD97706); // Amber for Claimed
  static const Color claimedBackground = Color(0xFFFEF3C7);
  static const Color verifiedColor = Color(0xFF4F46E5); // Indigo for Verified
  static const Color verifiedBackground = Color(0xFFE0E7FF);
  static const Color returnedColor = Color(0xFF0284C7); // Sky Blue for Returned
  static const Color returnedBackground = Color(0xFFE0F2FE);
  static const Color closedColor = Color(0xFF6B7280); // Gray for Closed
  static const Color closedBackground = Color(0xFFF3F4F6);

  // Background and surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // Alerts
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
}
