/// Which of the three cached calendar buckets a fixture belongs to.
enum DayKey {
  yesterday,
  today,
  tomorrow;

  static DayKey fromName(String? name) => DayKey.values.firstWhere(
        (DayKey d) => d.name == name,
        orElse: () => DayKey.today,
      );
}

/// Coarse grouping of the short status codes the app keys on. GOAL's status
/// enum is translated into these codes at the parser (`goalStatus`).
enum MatchPhase { scheduled, live, halftime, finished, postponed, abandoned, unknown }

extension MatchPhaseX on MatchPhase {
  bool get isLiveish => this == MatchPhase.live || this == MatchPhase.halftime;
  bool get hasScore =>
      this == MatchPhase.live ||
      this == MatchPhase.halftime ||
      this == MatchPhase.finished;
}

/// Every status code the API can emit, mapped once. Anything unrecognised
/// resolves to [MatchPhase.unknown] and renders `status.longText` verbatim —
/// an unknown code must never crash or render blank.
MatchPhase matchPhaseFromCode(String? shortCode) {
  switch ((shortCode ?? '').toUpperCase().trim()) {
    case 'TBD':
    case 'NS':
      return MatchPhase.scheduled;
    case 'PST':
      return MatchPhase.postponed;
    case '1H':
    case '2H':
    case 'ET':
    case 'BT':
    case 'P':
    case 'LIVE':
      return MatchPhase.live;
    case 'HT':
      return MatchPhase.halftime;
    case 'FT':
    case 'AET':
    case 'PEN':
    case 'AWD':
    case 'WO':
      return MatchPhase.finished;
    case 'SUSP':
    case 'INT':
    case 'CANC':
    case 'ABD':
      return MatchPhase.abandoned;
    default:
      return MatchPhase.unknown;
  }
}

class MatchStatus {
  const MatchStatus({
    required this.shortCode,
    required this.longText,
    this.elapsed,
    this.extra,
  });

  /// e.g. `1H`, `HT`, `FT`, `PEN`, `NS`. Never null (defaults to `''`).
  final String shortCode;

  /// e.g. `First Half`. Never null. Rendered verbatim when phase is unknown.
  final String longText;

  /// Live minute. NULL before kickoff and on many finished rows.
  final int? elapsed;

  /// Added time, i.e. `45+extra`. NULL almost always.
  final int? extra;

  MatchPhase get phase => matchPhaseFromCode(shortCode);

  /// `45'` / `45+2'` / `HT` / `PEN` — the live badge content.
  String get minuteLabel {
    final MatchPhase p = phase;
    if (p == MatchPhase.halftime) return 'HT';
    final String code = shortCode.toUpperCase();
    if (code == 'P') return 'PEN';
    if (code == 'BT') return 'ET';
    if (elapsed == null) return code.isEmpty ? 'LIVE' : code;
    if (extra != null && extra! > 0) return "$elapsed+$extra'";
    return "$elapsed'";
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'short': shortCode,
        'long': longText,
        'elapsed': elapsed,
        'extra': extra,
      };

  static MatchStatus fromJson(Map<String, dynamic> json) => MatchStatus(
        shortCode: (json['short'] as String?) ?? '',
        longText: (json['long'] as String?) ?? '',
        elapsed: (json['elapsed'] as num?)?.toInt(),
        extra: (json['extra'] as num?)?.toInt(),
      );
}
