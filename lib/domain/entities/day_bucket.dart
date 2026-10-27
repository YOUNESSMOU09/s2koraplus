import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/entities/refs.dart';

/// Fixtures of one competition on one day, kickoff-ascending.
class CompetitionGroup {
  const CompetitionGroup({required this.league, required this.fixtures});

  final LeagueRef league;
  final List<Fixture> fixtures;

  int get liveCount =>
      fixtures.where((Fixture f) => f.phase.isLiveish).length;

  /// Earliest kickoff in the group — used as a tiebreak in ordering.
  int get firstKickoff => fixtures.isEmpty ? 0 : fixtures.first.timestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'league': league.toJson(),
        'fixtures': fixtures.map((Fixture f) => f.toJson()).toList(),
      };

  static CompetitionGroup fromJson(Map<String, dynamic> json) => CompetitionGroup(
        league: LeagueRef.fromJson(
            (json['league'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
        fixtures: ((json['fixtures'] as List<Object?>?) ?? const <Object?>[])
            .whereType<Map<String, dynamic>>()
            .map(Fixture.fromJson)
            .toList(growable: false),
      );
}

/// One normalised search record per fixture, built inside the parse isolate.
class SearchDoc {
  const SearchDoc({required this.fixtureId, required this.haystack});

  final String fixtureId;

  /// Normalised `home|away|league|country`.
  final String haystack;
}

/// One day's fully parsed, grouped and indexed scoreboard.
class DayBucket {
  DayBucket({
    required this.day,
    required this.serverDate,
    required this.fetchedAt,
    required this.checkedAt,
    required this.groups,
    required this.byId,
    required this.searchIndex,
  });

  final DayKey day;

  /// Modal UTC calendar date across the fixtures — the server, not the device,
  /// defines which day this is.
  final String serverDate;

  /// Last time the response BODY changed (HTTP 200).
  final DateTime fetchedAt;

  /// Last successful validation (200 **or** 304). Drives the freshness chip.
  final DateTime checkedAt;

  final List<CompetitionGroup> groups;
  final Map<String, Fixture> byId;
  final List<SearchDoc> searchIndex;

  int get fixtureCount => byId.length;
  bool get isEmpty => byId.isEmpty;

  DayBucket copyWith({DateTime? fetchedAt, DateTime? checkedAt}) => DayBucket(
        day: day,
        serverDate: serverDate,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        checkedAt: checkedAt ?? this.checkedAt,
        groups: groups,
        byId: byId,
        searchIndex: searchIndex,
      );

  static DayBucket empty(DayKey day) => DayBucket(
        day: day,
        serverDate: '',
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(0),
        checkedAt: DateTime.fromMillisecondsSinceEpoch(0),
        groups: const <CompetitionGroup>[],
        byId: <String, Fixture>{},
        searchIndex: const <SearchDoc>[],
      );
}

/// The most recent `/live` response.
class LiveSnapshot {
  const LiveSnapshot({
    required this.fetchedAt,
    required this.byId,
    required this.groups,
  });

  final DateTime fetchedAt;
  final Map<String, Fixture> byId;

  /// Live fixtures grouped by competition, most-live-first.
  final List<CompetitionGroup> groups;

  int get count => byId.length;

  static LiveSnapshot empty() => LiveSnapshot(
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(0),
        byId: const <String, Fixture>{},
        groups: const <CompetitionGroup>[],
      );
}
