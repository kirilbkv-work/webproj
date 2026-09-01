import 'package:intl/intl.dart';

/// shared price and date formatting
abstract final class Formatters {
  static final NumberFormat _money = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final NumberFormat _moneyShort = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$',
    decimalDigits: 0,
  );

  static final DateFormat _shortDate = DateFormat('d MMM y', 'en_US');
  static final DateFormat _longDate = DateFormat('d MMMM y', 'en_US');
  static final DateFormat _monthYear = DateFormat('MMM y', 'en_US');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd', 'en_US');

  static String money(double value) => _money.format(value);

  static String moneyShort(double value) => _moneyShort.format(value);

  static String shortDate(DateTime value) => _shortDate.format(value);

  static String longDate(DateTime value) => _longDate.format(value);

  static String monthYear(DateTime value) => _monthYear.format(value);

  static String isoDate(DateTime value) => _isoDate.format(value);

  static String plural(int count, String one, String many) =>
      '$count ${count == 1 ? one : many}';
}
