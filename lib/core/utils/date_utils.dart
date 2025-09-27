import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _timeFormatter = DateFormat('HH:mm');
  static final _fullFormatter = DateFormat('MMM dd, yyyy HH:mm');

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormatter.format(time);
  }

  static String formatFull(DateTime dateTime) {
    return _fullFormatter.format(dateTime);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}