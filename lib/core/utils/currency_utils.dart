import 'package:intl/intl.dart';

class CurrencyUtils {
  static final _formatter = NumberFormat.currency(
    locale: 'en_EU',
    symbol: '€',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000) {
      return '\${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }
}