import 'package:intl/intl.dart';

/// Smart date formatting utilities using Indonesian locale.
abstract final class DateFormatter {
  /// Returns a contextual date string:
  /// - 'Hari ini HH:mm' if the date is today
  /// - 'Kemarin' if the date is yesterday
  /// - 'd MMM yyyy' otherwise (e.g., '5 Jul 2026')
  static String formatSmartDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      final timeFormat = DateFormat('HH:mm', 'id_ID');
      return 'Hari ini ${timeFormat.format(date)}';
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (dateOnly == yesterday) {
      return 'Kemarin';
    }

    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    return dateFormat.format(date);
  }

  /// Returns a full date + time string, e.g., '5 Juli 2026, 17:15'.
  static String formatFullDate(DateTime date) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');
    return dateFormat.format(date);
  }
}
