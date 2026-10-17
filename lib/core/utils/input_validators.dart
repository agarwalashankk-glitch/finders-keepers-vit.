import '../constants/app_constants.dart';

class InputValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }

  static String? validateItemTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an item name/title';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (trimmed.length > AppConstants.maxTitleLength) {
      return 'Title cannot exceed ${AppConstants.maxTitleLength} characters';
    }
    return null;
  }

  static String? validateItemDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please provide a clear description';
    }
    final trimmed = value.trim();
    if (trimmed.length < 15) {
      return 'Description should be at least 15 characters to help identify it';
    }
    if (trimmed.length > AppConstants.maxDescriptionLength) {
      return 'Description cannot exceed ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  static String? validateClaimEvidence(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Private proof of ownership is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minEvidenceLength) {
      return 'Please provide more specific identifying details (at least ${AppConstants.minEvidenceLength} characters) to prevent fraudulent claims.';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty || !AppConstants.categories.contains(value)) {
      return 'Please select a valid item category';
    }
    return null;
  }

  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Please select the approximate date';
    }
    final now = DateTime.now().add(const Duration(hours: 1));
    if (date.isAfter(now)) {
      return 'Date cannot be in the future';
    }
    return null;
  }
}
