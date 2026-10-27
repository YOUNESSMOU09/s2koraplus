import 'package:intl/intl.dart';

/// Number and date formatting.
///
/// **Numerals are Latin everywhere, including `ar`.** Scores, minutes and clock
/// times must be unambiguous and monospaced; IBM Plex Mono carries no
/// Arabic-Indic figures, and every major Arabic football app uses Latin score
/// digits. Weekday and month *words* still follow the active locale.
class AppFormat {
  const AppFormat._();

  /// `19:30` — always 24-hour, always Latin digits.
  static String kickoffTime(DateTime local) => DateFormat.Hm('en').format(local);

  /// `Sat 9 Aug` — localised weekday/month words, Latin day number.
  static String shortDate(DateTime local, String languageCode) {
    final String weekday = DateFormat.E(languageCode).format(local);
    final String month = DateFormat.MMM(languageCode).format(local);
    return '$weekday ${local.day} $month';
  }

  /// `Saturday 9 August 2026`
  static String longDate(DateTime local, String languageCode) {
    final String weekday = DateFormat.EEEE(languageCode).format(local);
    final String month = DateFormat.MMMM(languageCode).format(local);
    return '$weekday ${local.day} $month ${local.year}';
  }

  /// A score numeral, or an en dash when the goal count is unknown.
  static String goals(int? value) => value == null ? '–' : '$value';

  /// `61` -> `61st` in `en`, the bare number in `ar`.
  ///
  /// Added time renders as `90+3` — NEVER with a prime mark. The prime is a
  /// bidi-NEUTRAL character: outside `LiveMinuteBadge`'s forced-LTR run it
  /// lands on the wrong side of the digits in an Arabic paragraph. `+` is
  /// neutral too, so any added-time citation must be wrapped in
  /// `bidiIsolate(...)` at the call site.
  static String minuteOrdinal(
    int minute, {
    int extra = 0,
    required String languageCode,
  }) {
    if (extra > 0) {
      final String base = '$minute+$extra';
      return languageCode == 'ar' ? base : '$base${_ordinalSuffix(extra)}';
    }
    return languageCode == 'ar' ? '$minute' : '$minute${_ordinalSuffix(minute)}';
  }

  /// 1st, 2nd, 3rd, 4th … 11th, 12th, 13th … 21st, 22nd, 23rd.
  static String _ordinalSuffix(int n) {
    final int abs = n.abs();
    if (abs % 100 >= 11 && abs % 100 <= 13) return 'th';
    switch (abs % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  static String integer(int value) => NumberFormat.decimalPattern('en').format(value);

  /// Parses `"yyyy-MM-dd"` (the bucket's server date) without throwing.
  static DateTime? parseServerDate(String value) {
    if (value.length != 10) return null;
    return DateTime.tryParse('${value}T00:00:00Z');
  }
}
