library;

import 'dart:convert';

import 'package:marma/core/utils/crest_url.dart';
import 'package:marma/core/utils/text_normalise.dart';
import 'package:marma/data/parsing/goal_fixture_parser.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/entities/refs.dart';

/// Tie-break order for competitions the provider gives no popularity score,
/// keyed `country|name` in lower case (GOAL ids are opaque, so names it is).
const List<String> kPriorityLeagues = <String>[
  'world|uefa champions league',
  'world|uefa europa league',
  'world|uefa europa conference league',
  'world|world cup',
  'england|premier league',
  'spain|la liga',
  'italy|serie a',
  'germany|bundesliga',
  'france|ligue 1',
  'saudi-arabia|pro league',
  'egypt|premier league',
];

final Map<String, int> _priorityIndex = <String, int>{
  for (int i = 0; i < kPriorityLeagues.length; i++) kPriorityLeagues[i]: i,
};

/// One day of GOAL fixture rows, already decoded by the SDK.
class DayParseRequest {
  const DayParseRequest({
    required this.rows,
    required this.day,
    required this.fetchedAtMs,
    required this.checkedAtMs,
    this.serverDate,
  });

  final List<Object?> rows;
  final DayKey day;
  final int fetchedAtMs;
  final int checkedAtMs;

  /// The `YYYY-MM-DD` the rows were requested for.
  final String? serverDate;
}

DayBucket parseDayBucketIsolate(DayParseRequest request) {
  final List<Fixture> fixtures = <Fixture>[];
  for (final Object? element in request.rows) {
    final Fixture? fixture = fixtureFromGoal(element);
    if (fixture != null) fixtures.add(fixture);
  }
  return buildDayBucket(
    day: request.day,
    fixtures: fixtures,
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(request.fetchedAtMs),
    checkedAt: DateTime.fromMillisecondsSinceEpoch(request.checkedAtMs),
    serverDate: request.serverDate,
  );
}

/// Registers every team badge and league logo for id-only widgets. Must run on
/// the MAIN isolate — a registry filled inside `Isolate.run` dies with it.
void recordFixtureCrests(Iterable<Fixture> fixtures) {
  for (final Fixture f in fixtures) {
    recordCrests(leagueId: f.league.id, leagueLogo: f.league.logo);
    recordCrests(teamId: f.home.id, teamLogo: f.home.logo);
    recordCrests(teamId: f.away.id, teamLogo: f.away.logo);
  }
}

DayBucket buildDayBucket({
  required DayKey day,
  required List<Fixture> fixtures,
  required DateTime fetchedAt,
  required DateTime checkedAt,
  String? serverDate,
}) {
  final Map<String, List<Fixture>> byLeague = <String, List<Fixture>>{};
  final Map<String, LeagueRef> leagues = <String, LeagueRef>{};
  final Map<String, Fixture> byId = <String, Fixture>{};
  final List<SearchDoc> index = <SearchDoc>[];
  final Map<String, int> dateTally = <String, int>{};

  for (final Fixture f in fixtures) {
    byId[f.id] = f;
    (byLeague[f.league.id] ??= <Fixture>[]).add(f);
    leagues.putIfAbsent(f.league.id, () => f.league);
    index.add(SearchDoc(
      fixtureId: f.id,
      haystack: normaliseForSearch(
        '${f.home.name}|${f.away.name}|${f.league.name}|${f.league.country}',
      ),
    ));
    final String key = _utcDateKey(f.timestamp);
    dateTally[key] = (dateTally[key] ?? 0) + 1;
  }

  final List<CompetitionGroup> groups = <CompetitionGroup>[];
  for (final MapEntry<String, List<Fixture>> entry in byLeague.entries) {
    final List<Fixture> list = entry.value
      ..sort((Fixture a, Fixture b) {
        final int byTime = a.timestamp.compareTo(b.timestamp);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    groups.add(CompetitionGroup(league: leagues[entry.key]!, fixtures: list));
  }
  sortCompetitionGroups(groups);

  String tallied = '';
  int best = -1;
  for (final MapEntry<String, int> e in dateTally.entries) {
    if (e.value > best) {
      best = e.value;
      tallied = e.key;
    }
  }

  return DayBucket(
    day: day,
    serverDate: serverDate ?? tallied,
    fetchedAt: fetchedAt,
    checkedAt: checkedAt,
    groups: groups,
    byId: byId,
    searchIndex: index,
  );
}

/// Base ordering (rules 4–5 of §5.4). Favourites (rules 1–3) are re-applied in
/// the UI layer so a favourite toggle never forces a re-parse.
/// Most popular competitions first (the provider's own score), then the
/// named priority list, then country and name alphabetically.
void sortCompetitionGroups(List<CompetitionGroup> groups) {
  int priority(LeagueRef l) =>
      _priorityIndex['${l.country.toLowerCase()}|${l.name.toLowerCase()}'] ?? 1 << 20;
  groups.sort((CompetitionGroup a, CompetitionGroup b) {
    final int byPopularity = (b.league.popularity ?? -1).compareTo(a.league.popularity ?? -1);
    if (byPopularity != 0) return byPopularity;
    final int pa = priority(a.league);
    final int pb = priority(b.league);
    if (pa != pb) return pa.compareTo(pb);
    final int byCountry =
        a.league.country.toLowerCase().compareTo(b.league.country.toLowerCase());
    if (byCountry != 0) return byCountry;
    return a.league.name.toLowerCase().compareTo(b.league.name.toLowerCase());
  });
}

String _utcDateKey(int epochSeconds) {
  final DateTime d =
      DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000, isUtc: true);
  final String m = d.month.toString().padLeft(2, '0');
  final String day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}

// ---------------------------------------------------------------------------
// /live
// ---------------------------------------------------------------------------

/// Parses a raw `/live` body. Groups are ordered most-live-first (rule 3).
LiveSnapshot parseLiveIsolate(List<Object?> rows) {
  final List<Fixture> fixtures = <Fixture>[];
  for (final Object? element in rows) {
    final Fixture? fixture = fixtureFromGoal(element);
    if (fixture != null) fixtures.add(fixture);
  }
  return buildLiveSnapshot(fixtures, DateTime.now());
}

LiveSnapshot buildLiveSnapshot(List<Fixture> fixtures, DateTime fetchedAt) {
  final Map<String, Fixture> byId = <String, Fixture>{};
  final Map<String, List<Fixture>> byLeague = <String, List<Fixture>>{};
  final Map<String, LeagueRef> leagues = <String, LeagueRef>{};

  for (final Fixture f in fixtures) {
    byId[f.id] = f;
    (byLeague[f.league.id] ??= <Fixture>[]).add(f);
    leagues.putIfAbsent(f.league.id, () => f.league);
  }

  final List<CompetitionGroup> groups = <CompetitionGroup>[];
  for (final MapEntry<String, List<Fixture>> entry in byLeague.entries) {
    final List<Fixture> list = entry.value
      ..sort((Fixture a, Fixture b) {
        final int byTime = a.timestamp.compareTo(b.timestamp);
        return byTime != 0 ? byTime : a.id.compareTo(b.id);
      });
    groups.add(CompetitionGroup(league: leagues[entry.key]!, fixtures: list));
  }
  sortCompetitionGroups(groups);
  // Rule 3: most live fixtures first, stable within the base ordering.
  groups.sort((CompetitionGroup a, CompetitionGroup b) =>
      b.fixtures.length.compareTo(a.fixtures.length));

  return LiveSnapshot(fetchedAt: fetchedAt, byId: byId, groups: groups);
}

// ---------------------------------------------------------------------------
// Cache round-trip
// ---------------------------------------------------------------------------

/// Serialises a bucket to the on-disk shape (§6.3).
String encodeBucket(DayBucket bucket, int schemaVersion) => jsonEncode(<String, dynamic>{
      'v': schemaVersion,
      'day': bucket.day.name,
      'serverDate': bucket.serverDate,
      'fetchedAt': bucket.fetchedAt.millisecondsSinceEpoch,
      'checkedAt': bucket.checkedAt.millisecondsSinceEpoch,
      'groups': bucket.groups.map((CompetitionGroup g) => g.toJson()).toList(),
    });

class CacheDecodeRequest {
  const CacheDecodeRequest({required this.rawBody, required this.schemaVersion});
  final String rawBody;
  final int schemaVersion;
}

/// Reads a cache file body back into a [DayBucket].
///
/// Throws [FormatException] on a version mismatch or any structural problem;
/// the caller treats that as a cache miss and deletes the file. A corrupt cache
/// must never crash the app.
DayBucket decodeBucketIsolate(CacheDecodeRequest request) {
  final Object? decoded = jsonDecode(request.rawBody);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('cache root is not an object');
  }
  if (decoded['v'] != request.schemaVersion) {
    throw const FormatException('cache schema version mismatch');
  }
  final List<Fixture> fixtures = <Fixture>[];
  final Object? groups = decoded['groups'];
  if (groups is List) {
    for (final Object? g in groups) {
      if (g is! Map<String, dynamic>) continue;
      fixtures.addAll(CompetitionGroup.fromJson(g).fixtures);
    }
  }
  final DayBucket rebuilt = buildDayBucket(
    day: DayKey.fromName(decoded['day'] as String?),
    fixtures: fixtures,
    fetchedAt: DateTime.fromMillisecondsSinceEpoch(
        (decoded['fetchedAt'] as num?)?.toInt() ?? 0),
    checkedAt: DateTime.fromMillisecondsSinceEpoch(
        (decoded['checkedAt'] as num?)?.toInt() ?? 0),
  );
  return rebuilt;
}

String encodeLive(LiveSnapshot snapshot, int schemaVersion) =>
    jsonEncode(<String, dynamic>{
      'v': schemaVersion,
      'fetchedAt': snapshot.fetchedAt.millisecondsSinceEpoch,
      'fixtures': snapshot.byId.values.map((Fixture f) => f.toJson()).toList(),
    });

LiveSnapshot decodeLiveIsolate(CacheDecodeRequest request) {
  final Object? decoded = jsonDecode(request.rawBody);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('cache root is not an object');
  }
  if (decoded['v'] != request.schemaVersion) {
    throw const FormatException('cache schema version mismatch');
  }
  final List<Fixture> fixtures = ((decoded['fixtures'] as List<Object?>?) ??
          const <Object?>[])
      .whereType<Map<String, dynamic>>()
      .map(Fixture.fromJson)
      .toList();
  return buildLiveSnapshot(
    fixtures,
    DateTime.fromMillisecondsSinceEpoch(
        (decoded['fetchedAt'] as num?)?.toInt() ?? 0),
  );
}
