import 'dart:isolate';

import 'package:marma/app/app_env.dart';
import 'package:marma/core/failures.dart';
import 'package:marma/data/local/bucket_cache.dart';
import 'package:marma/data/local/prefs_store.dart';
import 'package:marma/data/local/ttl_cache.dart';
import 'package:marma/data/parsing/day_bucket_parser.dart';
import 'package:marma/data/parsing/goal_catalog_parser.dart';
import 'package:marma/data/remote/goal_source.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/catalog.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/repositories/repositories.dart';

/// Day buckets and the live snapshot, from GOAL, behind TTL caches.
///
/// Budget (1000 requests/day): a day is 4–12 pages, so a bucket is refreshed
/// only once its TTL ([staleAfter]) has passed, and even an explicit pull is
/// floored at [minRefreshGap]. The live poll is the one recurring call (one
/// request, every [AppEnv.livePollInterval] while a live surface is open) and
/// backs off hard once the provider reports fewer than [lowQuota] requests left.
class FixtureRepositoryImpl implements FixtureRepository {
  FixtureRepositoryImpl(this._source, this._cache, this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final GoalSource _source;
  final BucketCache _cache;
  final PrefsStore _prefs;
  final DateTime Function() _clock;

  static const int lowQuota = 50;
  static const Duration lowQuotaLiveGap = Duration(minutes: 5);
  static const Duration liveFloor = Duration(seconds: 20);

  /// The UTC calendar date each bucket stands for, as `YYYY-MM-DD`.
  static String dateFor(DayKey day, {DateTime? now}) {
    final DateTime utc = (now ?? DateTime.now()).toUtc();
    final DateTime d = DateTime.utc(utc.year, utc.month, utc.day).add(Duration(
      days: switch (day) {
        DayKey.yesterday => -1,
        DayKey.today => 0,
        DayKey.tomorrow => 1,
      },
    ));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<DayBucket?> readCachedDay(DayKey day) async {
    final DayBucket? bucket = await _cache.readDay(day);
    if (bucket == null) return null;
    recordFixtureCrests(bucket.byId.values);
    // Prefs hold the authoritative freshness stamps; the file may be older.
    return bucket.copyWith(
      fetchedAt: _prefs.fetchedAt(day),
      checkedAt: _prefs.checkedAt(day),
    );
  }

  @override
  Future<DayBucket> refreshDay(DayKey day, {DayBucket? previous}) async {
    final DateTime now = _clock();
    final String date = dateFor(day, now: now);

    // A pull-to-refresh moments after the last fetch costs 4–12 requests and
    // changes nothing; live scores keep moving through the live poll anyway.
    if (previous != null &&
        previous.serverDate == date &&
        now.difference(previous.checkedAt) < minRefreshGap(day)) {
      return previous;
    }

    final List<Object?> rows = await _source.fixturesOn(date);
    final DayBucket parsed;
    try {
      parsed = await Isolate.run(() => parseDayBucketIsolate(DayParseRequest(
            rows: rows,
            day: day,
            serverDate: date,
            fetchedAtMs: now.millisecondsSinceEpoch,
            checkedAtMs: now.millisecondsSinceEpoch,
          )));
    } on Object catch (e) {
      throw AppFailure.badResponse(e.toString());
    }
    recordFixtureCrests(parsed.byId.values);

    await _cache.writeDay(parsed);
    await _prefs.setBucketMeta(day, fetchedAt: now, checkedAt: now, serverDate: date);
    return parsed;
  }

  @override
  Future<LiveSnapshot?> readCachedLive() async {
    final LiveSnapshot? snapshot = await _cache.readLive();
    if (snapshot != null) recordFixtureCrests(snapshot.byId.values);
    return snapshot;
  }

  @override
  Future<LiveSnapshot> refreshLive({LiveSnapshot? previous}) async {
    final DateTime now = _clock();
    if (previous != null) {
      final Duration age = now.difference(previous.fetchedAt);
      final int? remaining = _source.remainingRequests;
      final bool starved = remaining != null && remaining < lowQuota;
      if (age < liveFloor || (starved && age < lowQuotaLiveGap)) return previous;
    }

    final List<Object?> rows = await _source.liveFixtures();
    final LiveSnapshot raw;
    try {
      raw = await Isolate.run(() => parseLiveIsolate(rows));
    } on Object catch (e) {
      throw AppFailure.badResponse(e.toString());
    }
    // Stamped with this repository's clock, which the floors above measure.
    final LiveSnapshot parsed = LiveSnapshot(fetchedAt: now, byId: raw.byId, groups: raw.groups);
    recordFixtureCrests(parsed.byId.values);
    await _cache.writeLive(parsed);
    return parsed;
  }

  @override
  Future<Health> fetchHealth() async {
    final Map<String, dynamic> s = await _source.status();
    final String status = (s['status'] ?? 'unknown').toString();
    return Health(
      status: status,
      redisConnected: true,
      dataAvailable: status.toLowerCase() == 'operational',
      lastUpdated: DateTime.tryParse((s['updatedAt'] ?? '').toString()),
    );
  }

  @override
  Future<void> clearCache() async {
    await _cache.clear();
    await _prefs.clearCacheMetadata();
  }

  @override
  Future<int> cacheSizeBytes() => _cache.sizeInBytes();

  /// TTL per bucket: yesterday is settled, tomorrow barely moves, and today's
  /// scores are kept current by the live poll between refreshes.
  static Duration staleAfter(DayKey day) => switch (day) {
        DayKey.yesterday => const Duration(hours: 6),
        DayKey.today => const Duration(minutes: 10),
        DayKey.tomorrow => const Duration(hours: 1),
      };

  /// The shortest gap allowed between two fetches of the same day, even on an
  /// explicit pull-to-refresh.
  static Duration minRefreshGap(DayKey day) =>
      day == DayKey.today ? const Duration(minutes: 2) : const Duration(minutes: 10);

  static bool isStale(DayBucket? bucket, DayKey day, {DateTime? now}) {
    if (bucket == null) return true;
    if (bucket.checkedAt.millisecondsSinceEpoch == 0) return true;
    final DateTime reference = now ?? DateTime.now();
    // After midnight UTC "today" is a different date: the cached day is wrong,
    // not merely old.
    if (bucket.serverDate.isNotEmpty && bucket.serverDate != dateFor(day, now: reference)) {
      return true;
    }
    return reference.difference(bucket.checkedAt) > staleAfter(day);
  }
}

/// Standings, squads and the league catalog, each behind a TTL file cache.
/// A failed refresh falls back to the expired copy when there is one.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._source, this._cache);

  final GoalSource _source;
  final TtlCache _cache;

  static const Duration standingsTtl = Duration(hours: 6);
  static const Duration squadTtl = Duration(days: 1);
  static const Duration leaguesTtl = Duration(days: 7);

  @override
  Future<List<StandingRow>> standings(String leagueId) async =>
      standingsFromGoal(await _cached('standings_$leagueId', standingsTtl,
          () => _source.standings(leagueId)));

  @override
  Future<List<SquadPlayer>> squad(String teamId) async =>
      squadFromGoal(await _cached('squad_$teamId', squadTtl, () => _source.squad(teamId)));

  @override
  Future<List<LeagueSummary>> leagues() async =>
      leaguesFromGoal(await _cached('leagues_active', leaguesTtl, _source.activeLeagues));

  @override
  Future<void> clear() => _cache.clear();

  Future<List<Object?>> _cached(
      String key, Duration ttl, Future<List<Object?>> Function() fetch) async {
    final Object? fresh = await _cache.read(key, ttl);
    if (fresh is List) return fresh;
    try {
      final List<Object?> rows = await fetch();
      await _cache.write(key, rows);
      return rows;
    } on AppFailure catch (e) {
      if (e.kind == FailureKind.notFound) return const <Object?>[];
      final Object? stale = await _cache.readStale(key);
      if (stale is List) return stale;
      rethrow;
    }
  }
}

const int kCacheSchemaVersion = AppEnv.cacheSchemaVersion;
