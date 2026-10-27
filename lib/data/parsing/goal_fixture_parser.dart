/// GOAL API fixture row → domain [Fixture]. Pure Dart, isolate-safe.
///
/// Everything provider-specific stops here: string scores become ints, the
/// status enum becomes the short codes the rest of the app already speaks,
/// spaced country names become the hyphenated keys the flag/Arabic tables use,
/// and nested team/league objects win over their flat fallbacks.
library;

import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_event.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/entities/refs.dart';

/// Returns null for a row too broken to show (no id, or no teams).
Fixture? fixtureFromGoal(Object? raw) {
  if (raw is! Map) return null;
  final Map<String, dynamic> row = raw.cast<String, dynamic>();
  final String id = _str(row['id']) ?? '';
  if (id.isEmpty) return null;

  final Map<String, dynamic> homeObj = _map(row['homeTeam']);
  final Map<String, dynamic> awayObj = _map(row['awayTeam']);
  final Map<String, dynamic> leagueObj = _map(row['league']);

  final TeamRef home = TeamRef(
    id: _str(homeObj['id']) ?? _str(row['homeTeamId']) ?? '',
    name: _str(homeObj['name']) ?? _str(row['homeTeamName']) ?? '',
    logo: _str(homeObj['badge']) ?? _str(row['teamHomeBadge']),
  );
  final TeamRef away = TeamRef(
    id: _str(awayObj['id']) ?? _str(row['awayTeamId']) ?? '',
    name: _str(awayObj['name']) ?? _str(row['awayTeamName']) ?? '',
    logo: _str(awayObj['badge']) ?? _str(row['teamAwayBadge']),
  );
  if (home.name.isEmpty || away.name.isEmpty) return null;

  final String status = (_str(row['matchStatus']) ?? '').toUpperCase();
  final int? homeGoals = parseGoalInt(row['homeTeamScore']);
  final int? awayGoals = parseGoalInt(row['awayTeamScore']);
  final bool afterExtraTime = status == 'AFTER_ET' || status == 'AFTER_PEN';

  return Fixture(
    id: id,
    timestamp: goalKickoffEpochSeconds(row),
    status: goalStatus(row),
    referee: _str(row['matchReferee']),
    venue: _venue(_str(row['matchStadium'])),
    league: LeagueRef(
      id: _str(leagueObj['id']) ?? _str(row['leagueId']) ?? '',
      // `leagueName` carries the stage ("Cup - Quarter-finals"); the nested
      // name is the competition itself, which is what a header should say.
      name: _str(leagueObj['name']) ?? _str(row['leagueName']) ?? '',
      country: goalCountryKey(_str(row['countryName'])),
      season: _seasonStart(_str(row['leagueYear'])),
      round: _round(_str(row['stageName']), _str(row['matchRound'])),
      logo: _str(leagueObj['logo']) ?? _str(row['leagueLogo']),
      popularity: parseGoalInt(leagueObj['popularity']),
    ),
    home: home,
    away: away,
    homeGoals: homeGoals,
    awayGoals: awayGoals,
    halftime: ScoreLine(
      parseGoalInt(row['homeTeamHalftimeScore']),
      parseGoalInt(row['awayTeamHalftimeScore']),
    ),
    // After extra time the running score is the 120' result; the 90' score
    // (when sent) becomes the secondary line, as the scoreline logic expects.
    fulltime: ScoreLine(
      parseGoalInt(row['homeTeamFtScore']),
      parseGoalInt(row['awayTeamFtScore']),
    ),
    extratime: afterExtraTime ? ScoreLine(homeGoals, awayGoals) : const ScoreLine.empty(),
    penalty: status == 'AFTER_PEN'
        ? ScoreLine(
            parseGoalInt(row['homeTeamPenaltyScore']),
            parseGoalInt(row['awayTeamPenaltyScore']),
          )
        : const ScoreLine.empty(),
    events: _events(row['events'], home.id, away.id),
  );
}

/// Scores and counts arrive as strings ("0", "43"). Null or blank means "not
/// played yet", never zero.
int? parseGoalInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  final String s = value.toString().trim();
  return s.isEmpty ? null : int.tryParse(s);
}

/// Kickoff, in UTC epoch seconds.
///
/// `kickoffUtc` is used as real UTC. Verified against production on
/// 2026-10-27: on all 13 live matches, `kickoffUtc` == `matchDate`+`matchTime`,
/// and the reported minute only fits that time being UTC (a 10:30 kickoff at
/// minute 23 at 10:53Z; 10:00 kickoffs at "Half Time" at 10:53Z). Read as
/// Europe/Berlin wall clock, the same matches would be 82 and 113 minutes in.
/// `matchDate`+`matchTime` is the fallback, read the same way.
int goalKickoffEpochSeconds(Map<String, dynamic> row) {
  final DateTime? utc = DateTime.tryParse(_str(row['kickoffUtc']) ?? '');
  if (utc != null) return utc.toUtc().millisecondsSinceEpoch ~/ 1000;
  final String? date = _str(row['matchDate']);
  final String time = _str(row['matchTime']) ?? '00:00';
  final DateTime? wall = date == null ? null : DateTime.tryParse('${date}T$time:00Z');
  return wall == null ? 0 : wall.millisecondsSinceEpoch ~/ 1000;
}

/// GOAL's status enum → the short codes the rest of the app keys on (status
/// labels, phases, minute badges), so no screen had to change.
MatchStatus goalStatus(Map<String, dynamic> row) {
  final String status = (_str(row['matchStatus']) ?? '').toUpperCase();
  final String period = (_str(row['matchPeriod']) ?? '').toUpperCase();
  final String code = switch (status) {
    'SCHEDULED' => 'NS',
    'LIVE' => _livePeriodCode(period),
    'HALF_TIME' => 'HT',
    'FINISHED' => 'FT',
    'AFTER_ET' => 'AET',
    'AFTER_PEN' => 'PEN',
    'POSTPONED' => 'PST',
    'CANCELLED' => 'CANC',
    'AWARDED' => 'AWD',
    'ABANDONED' => 'ABD',
    'SUSPENDED' => 'SUSP',
    _ => status,
  };
  final (int?, int?) minute = _minute(row);
  return MatchStatus(
    shortCode: code,
    longText: _titleCase(status),
    elapsed: minute.$1,
    extra: minute.$2,
  );
}

String _livePeriodCode(String period) {
  if (period.contains('PEN')) return 'P';
  if (period.contains('EXTRA')) return 'ET';
  if (period.contains('BREAK')) return 'BT';
  if (period.contains('SECOND')) return '2H';
  if (period.contains('FIRST')) return '1H';
  return 'LIVE';
}

/// `matchElapsed`/`matchExtra` when present, else parsed from `matchMinute`
/// ("81", "45+2"; "Half Time" has no number).
(int?, int?) _minute(Map<String, dynamic> row) {
  final int? elapsed = parseGoalInt(row['matchElapsed']);
  if (elapsed != null) return (elapsed, parseGoalInt(row['matchExtra']));
  return parseMinuteLabel(_str(row['matchMinute']));
}

/// "45+2" → (45, 2); "81" → (81, null); anything else → (null, null).
(int?, int?) parseMinuteLabel(String? label) {
  final RegExpMatch? m = RegExp(r"^\s*(\d+)\s*(?:\+\s*(\d+))?\s*'?\s*$").firstMatch(label ?? '');
  if (m == null) return (null, null);
  return (int.parse(m.group(1)!), m.group(2) == null ? null : int.parse(m.group(2)!));
}

/// "Saudi Arabia" → "Saudi-Arabia"; "intl" / "eurocups" → "World" (the
/// flag/name tables' key for international competitions). GOAL names that
/// differ from the tables' existing keys are aliased onto them.
String goalCountryKey(String? name) {
  final String raw = (name ?? '').trim();
  final String key = raw.replaceAll(RegExp(r'\s+'), '-');
  if (raw.isEmpty || _worldNames.contains(raw.toLowerCase())) return 'World';
  return _countryAliases[key] ?? key;
}

const Set<String> _worldNames = <String>{'intl', 'international', 'world', 'eurocups'};

/// GOAL spelling → the key the flag and Arabic-name tables already use.
/// Found by checking every country in three real GOAL days (2026-10-26..28).
const Map<String, String> _countryAliases = <String, String>{
  'Bosnia-and-Herzegovina': 'Bosnia',
  'Kyrgyz-Republic': 'Kyrgyzstan',
  'Republic-of-Ireland': 'Ireland',
  'China-PR': 'China',
  'Korea-Republic': 'South-Korea',
  'North-Macedonia': 'Macedonia',
  'Surinam': 'Suriname',
};

List<MatchEvent> _events(Object? raw, String homeId, String awayId) {
  if (raw is! List) return const <MatchEvent>[];
  final List<MatchEvent> out = <MatchEvent>[];
  for (final Object? e in raw) {
    if (e is! Map) continue;
    final Map<String, dynamic> ev = e.cast<String, dynamic>();
    final String type = (_str(ev['type']) ?? '').toUpperCase();
    final String? homePlayer = _str(ev['homeScorer']) ?? _str(ev['homeFault']) ?? _str(ev['homePlayer']);
    final String? awayPlayer = _str(ev['awayScorer']) ?? _str(ev['awayFault']) ?? _str(ev['awayPlayer']);
    final String info = (_str(ev['info']) ?? '').toLowerCase();
    final bool isHome = info == 'home' || (info != 'away' && homePlayer != null);
    final (int?, int?) minute = parseMinuteLabel(_str(ev['time']));
    final EventType kind = type.contains('GOAL')
        ? EventType.goal
        : type.contains('CARD')
            ? EventType.card
            : type.contains('SUB')
                ? EventType.subst
                : EventType.other;
    out.add(MatchEvent(
      elapsed: minute.$1,
      extra: minute.$2,
      teamId: isHome ? homeId : awayId,
      playerName: isHome ? homePlayer : awayPlayer,
      assistName: isHome ? _str(ev['homeAssist']) : _str(ev['awayAssist']),
      type: kind,
      detail: switch (kind) {
        EventType.card => type.contains('RED') ? 'Red Card' : 'Yellow Card',
        EventType.goal => type.contains('OWN')
            ? 'Own Goal'
            : (type.contains('PEN') ? 'Penalty' : 'Normal Goal'),
        _ => _titleCase(type),
      },
    ));
  }
  out.sort((MatchEvent a, MatchEvent b) => a.sortKey.compareTo(b.sortKey));
  return out;
}

Venue? _venue(String? stadium) =>
    (stadium == null || stadium.isEmpty) ? null : Venue(name: stadium);

/// "2026/2027" or "2026" → 2026.
int _seasonStart(String? year) =>
    int.tryParse(RegExp(r'\d{4}').firstMatch(year ?? '')?.group(0) ?? '') ?? 0;

/// "Clausura - Quadrangular" + "2" → "Clausura - Quadrangular - 2"; a round
/// already named by the stage ("Quarter-finals" twice) is not repeated.
String? _round(String? stage, String? round) {
  final List<String> parts = <String>[
    if (stage != null && stage.isNotEmpty) stage,
    if (round != null && round.isNotEmpty && round != stage) round,
  ];
  return parts.isEmpty ? null : parts.join(' - ');
}

String _titleCase(String enumValue) => enumValue
    .split('_')
    .where((String w) => w.isNotEmpty)
    .map((String w) => w[0] + w.substring(1).toLowerCase())
    .join(' ');

String? _str(Object? v) {
  if (v == null) return null;
  final String s = v.toString().trim();
  return s.isEmpty ? null : s;
}

Map<String, dynamic> _map(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};
