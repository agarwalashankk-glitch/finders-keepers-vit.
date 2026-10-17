class AppConstants {
  static const String appName = 'Finders Keepers?';
  static const String appTagline = 'Campus Lost & Found with Verified Ownership Handover';
  static const String appVersion = '1.0.0 (CodeChef-VIT Submission)';

  // Categories of items commonly found on campus
  static const List<String> categories = [
    'Student ID & Cards',
    'Electronics & Gadgets',
    'Earphones & Audio',
    'Wallets & Purses',
    'Keys & Keychains',
    'Notebooks & Books',
    'Bottles & Lunchboxes',
    'Bags & Backpacks',
    'Clothing & Accessories',
    'Eyewear & Watches',
    'Other',
  ];

  // Storage and file limits
  static const int maxImageCount = 3;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxTitleLength = 80;
  static const int maxDescriptionLength = 1000;
  static const int minEvidenceLength = 30;

  // Potential match score threshold (percentage)
  static const double matchScoreThreshold = 45.0;

  // Local storage draft key
  static const String reportDraftKey = 'finders_keepers_report_draft_v1';
  static const String demoModeKey = 'finders_keepers_demo_mode_active';
}
