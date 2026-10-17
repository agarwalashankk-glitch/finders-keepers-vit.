import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _fullFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _timeOnly = DateFormat('h:mm a');

  static String formatFull(DateTime dateTime) {
    return _fullFormat.format(dateTime);
  }

  static String formatShort(DateTime dateTime) {
    return _shortDate.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeOnly.format(dateTime);
  }

  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return formatShort(dateTime);
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hr' : 'hrs'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatShort(dateTime);
    }
  }
}
