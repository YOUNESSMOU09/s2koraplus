/// Match timeline events. Present on `/live` only — the three day buckets omit
/// the `events` key entirely (API_CONTRACT Constraint 2).
enum EventType { goal, card, subst, other }

EventType eventTypeFromRaw(String? raw) {
  switch ((raw ?? '').toLowerCase().trim()) {
    case 'goal':
      return EventType.goal;
    case 'card':
      return EventType.card;
    case 'subst':
    case 'substitution':
      return EventType.subst;
    default:
      return EventType.other;
  }
}

class MatchEvent {
  const MatchEvent({
    required this.teamId,
    required this.type,
    required this.detail,
    this.elapsed,
    this.extra,
    this.teamName,
    this.playerName,
    this.assistName,
  });

  final int? elapsed;
  final int? extra;
  final String teamId;
  final String? teamName;

  /// FREQUENTLY NULL in the live feed — the UI falls back to the team name.
  final String? playerName;

  /// FREQUENTLY NULL — the assist line is omitted entirely when absent.
  final String? assistName;

  final EventType type;

  /// e.g. `Normal Goal`, `Yellow Card`, `Substitution 1`. Never null (`''`).
  final String detail;

  /// `62'` / `90+4'`
  String get minuteLabel {
    if (elapsed == null) return '';
    if (extra != null && extra! > 0) return "$elapsed+$extra'";
    return "$elapsed'";
  }

  /// Sort key that keeps added-time events after the regular minute.
  int get sortKey => (elapsed ?? 0) * 100 + (extra ?? 0);

  bool get isRedCard {
    final String d = detail.toLowerCase();
    return type == EventType.card && d.contains('red');
  }

  bool get isYellowCard {
    final String d = detail.toLowerCase();
    return type == EventType.card && d.contains('yellow');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'e': elapsed,
        'x': extra,
        't': teamId,
        'tn': teamName,
        'p': playerName,
        'a': assistName,
        'ty': type.name,
        'd': detail,
      };

  static MatchEvent fromJson(Map<String, dynamic> json) => MatchEvent(
        elapsed: (json['e'] as num?)?.toInt(),
        extra: (json['x'] as num?)?.toInt(),
        teamId: json['t']?.toString() ?? '',
        teamName: json['tn'] as String?,
        playerName: json['p'] as String?,
        assistName: json['a'] as String?,
        type: EventType.values.firstWhere(
          (EventType t) => t.name == json['ty'],
          orElse: () => EventType.other,
        ),
        detail: (json['d'] as String?) ?? '',
      );
}
