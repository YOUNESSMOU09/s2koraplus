import 'package:marma/domain/entities/match_event.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/entities/refs.dart';

/// How a scoreline should be rendered, resolved once from the raw score object.
enum ScorelineKind { scheduled, plain, afterExtraTime, afterPenalties }

class ResolvedScoreline {
  const ResolvedScoreline({
    required this.kind,
    this.home,
    this.away,
    this.secondaryHome,
    this.secondaryAway,
  });

  final ScorelineKind kind;

  /// Headline numerals. Null before kickoff.
  final int? home;
  final int? away;

  /// The supporting line: `FT 1–1` under a penalty result, or the full-time
  /// score under an AET result.
  final int? secondaryHome;
  final int? secondaryAway;

  bool get hasSecondary => secondaryHome != null && secondaryAway != null;
}

class Fixture {
  const Fixture({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.league,
    required this.home,
    required this.away,
    required this.halftime,
    required this.fulltime,
    required this.extratime,
    required this.penalty,
    this.referee,
    this.venue,
    this.homeGoals,
    this.awayGoals,
    this.events = const <MatchEvent>[],
  });

  /// GOAL cuid.
  final String id;

  /// Epoch SECONDS, UTC. Authoritative kickoff — `fixture.date` is never parsed.
  final int timestamp;

  final String? referee;
  final Venue? venue;
  final MatchStatus status;
  final LeagueRef league;
  final TeamRef home;
  final TeamRef away;
  final int? homeGoals;
  final int? awayGoals;
  final ScoreLine halftime;
  final ScoreLine fulltime;
  final ScoreLine extratime;
  final ScoreLine penalty;

  /// Never null — `[]` everywhere except `/live`.
  final List<MatchEvent> events;

  DateTime get kickoffUtc =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

  DateTime get kickoffLocal => kickoffUtc.toLocal();

  MatchPhase get phase => status.phase;

  /// Winner derived from goals, NOT from the unreliable `teams.*.winner` flag.
  /// Returns null for draws, unfinished matches, or missing goals.
  String? get winningTeamId {
    if (phase != MatchPhase.finished) return null;
    final ResolvedScoreline s = scoreline;
    final int? h = s.home, a = s.away;
    if (h == null || a == null) return null;
    if (s.kind == ScorelineKind.afterPenalties) {
      final int? ph = penalty.home, pa = penalty.away;
      if (ph != null && pa != null && ph != pa) {
        return ph > pa ? home.id : away.id;
      }
    }
    if (h == a) return null;
    return h > a ? home.id : away.id;
  }

  /// §4 scoreline resolution rule — the single source of truth for both the
  /// list row and the detail header.
  ResolvedScoreline get scoreline {
    if (phase == MatchPhase.scheduled ||
        phase == MatchPhase.postponed ||
        (phase == MatchPhase.unknown && homeGoals == null)) {
      return const ResolvedScoreline(kind: ScorelineKind.scheduled);
    }
    if (penalty.isPresent) {
      final ScoreLine base = extratime.isPresent ? extratime : fulltime;
      return ResolvedScoreline(
        kind: ScorelineKind.afterPenalties,
        home: base.home ?? homeGoals,
        away: base.away ?? awayGoals,
        secondaryHome: penalty.home,
        secondaryAway: penalty.away,
      );
    }
    if (extratime.isPresent) {
      return ResolvedScoreline(
        kind: ScorelineKind.afterExtraTime,
        home: homeGoals,
        away: awayGoals,
        secondaryHome: fulltime.home,
        secondaryAway: fulltime.away,
      );
    }
    return ResolvedScoreline(
      kind: ScorelineKind.plain,
      home: homeGoals,
      away: awayGoals,
    );
  }

  bool involvesTeam(Set<String> teamIds) =>
      teamIds.contains(home.id) || teamIds.contains(away.id);

  Fixture mergeLive(Fixture live) => Fixture(
        id: id,
        timestamp: live.timestamp,
        referee: live.referee ?? referee,
        venue: live.venue ?? venue,
        status: live.status,
        league: league,
        home: live.home,
        away: live.away,
        homeGoals: live.homeGoals,
        awayGoals: live.awayGoals,
        halftime: live.halftime,
        fulltime: live.fulltime,
        extratime: live.extratime,
        penalty: live.penalty,
        events: live.events.isNotEmpty ? live.events : events,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'timestamp': timestamp,
        'referee': referee,
        'venue': venue?.toJson(),
        'status': status.toJson(),
        'league': league.toJson(),
        'home': home.toJson(),
        'away': away.toJson(),
        'goals': <int?>[homeGoals, awayGoals],
        'ht': halftime.toJson(),
        'ft': fulltime.toJson(),
        'et': extratime.toJson(),
        'pk': penalty.toJson(),
        if (events.isNotEmpty)
          'events': events.map((MatchEvent e) => e.toJson()).toList(),
      };

  static Fixture fromJson(Map<String, dynamic> json) {
    final List<Object?> goals = (json['goals'] as List<Object?>?) ?? const <Object?>[];
    return Fixture(
      id: json['id']?.toString() ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      referee: json['referee'] as String?,
      venue: Venue.fromJson(json['venue']),
      status: MatchStatus.fromJson(
          (json['status'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      league: LeagueRef.fromJson(
          (json['league'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      home: TeamRef.fromJson(
          (json['home'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      away: TeamRef.fromJson(
          (json['away'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      homeGoals: goals.isNotEmpty ? (goals[0] as num?)?.toInt() : null,
      awayGoals: goals.length > 1 ? (goals[1] as num?)?.toInt() : null,
      halftime: ScoreLine.fromJson(json['ht']),
      fulltime: ScoreLine.fromJson(json['ft']),
      extratime: ScoreLine.fromJson(json['et']),
      penalty: ScoreLine.fromJson(json['pk']),
      events: ((json['events'] as List<Object?>?) ?? const <Object?>[])
          .whereType<Map<String, dynamic>>()
          .map(MatchEvent.fromJson)
          .toList(growable: false),
    );
  }
}
