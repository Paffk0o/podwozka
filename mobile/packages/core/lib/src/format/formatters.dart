import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const _locale = 'pl_PL';

/// Loads Polish date symbols. Call once in `main()` before `runApp` (and in tests using dates).
Future<void> initPodwozkaFormatting() async {
  Intl.defaultLocale = _locale;
  await initializeDateFormatting(_locale);
}

final _money = NumberFormat.currency(locale: _locale, symbol: 'zł', decimalDigits: 2);

/// API amounts are integers in grosze: `6696` → `66,96 zł`.
String formatMoney(int grosze) => _money.format(grosze / 100);

/// `850` → `850 m`, `12400` → `12,4 km`.
String formatDistance(int meters) {
  if (meters < 1000) return '$meters m';
  final km = NumberFormat('0.#', _locale).format(meters / 1000);
  return '$km km';
}

/// Travel time / ETA: `45` → `1 min`, `720` → `12 min`, `3900` → `1 godz. 5 min`.
String formatDuration(int seconds) {
  final minutes = (seconds / 60).ceil().clamp(1, 1 << 31);
  if (minutes < 60) return '$minutes min';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '$hours godz.' : '$hours godz. $rest min';
}

/// `18.11.2026, 08:05` in local time.
String formatDateTime(DateTime value) =>
    DateFormat('d.MM.yyyy, HH:mm', _locale).format(value.toLocal());

/// `08:05` in local time.
String formatTime(DateTime value) => DateFormat('HH:mm', _locale).format(value.toLocal());

/// `śr., 18 lis` — short day label for schedules and history.
String formatDayShort(DateTime value) => DateFormat('E, d MMM', _locale).format(value.toLocal());
