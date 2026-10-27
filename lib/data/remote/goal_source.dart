import 'package:goal_api/goal_api.dart';
import 'package:marma/core/failures.dart';

/// The app's only door to the GOAL API. Holds the ONE shared [GoalApi] (it
/// pools connections and tracks the rate-limit snapshot) and turns its typed
/// exceptions into the app's [AppFailure] taxonomy.
///
/// QUOTA: the plan is budgeted at 1000 requests/day. A day of fixtures is 4–12
/// pages, so paging is capped at [maxDayRows] and every caller sits behind a
/// TTL cache; nothing here is called on a timer except the live poll.
class GoalSource {
  GoalSource(this._api);

  final GoalApi _api;

  /// 12 pages of 100. A busier day is truncated rather than allowed to spend
  /// an unbounded share of the daily budget.
  static const int maxDayRows = 1200;

  /// Remaining requests in the current window, from the last response's
  /// headers; null until the first authenticated call.
  int? get remainingRequests => _api.rateLimit.remaining;

  Future<List<Object?>> fixturesOn(String isoDate) => _guard(() => _api.collect(
        (Map<String, dynamic> page) => _api.fixtures.byDate(isoDate, page),
        maxItems: maxDayRows,
      ));

  Future<List<Object?>> liveFixtures() =>
      _guard(() async => _data(await _api.fixtures.live()));

  /// Bare object, no envelope (`/public/status` needs no key either).
  Future<Map<String, dynamic>> status() => _guard(() => _api.status.get());

  Future<List<Object?>> standings(String leagueId) =>
      _guard(() async => _data(await _api.standings.get(leagueId)));

  Future<List<Object?>> squad(String teamId) => _guard(() => _api.collect(
        (Map<String, dynamic> page) => _api.teams.players(teamId, page),
        maxItems: 100,
      ));

  /// ~1019 active leagues ≈ 11 requests: only ever loaded lazily, and cached.
  Future<List<Object?>> activeLeagues() => _guard(() => _api.collect(
        (Map<String, dynamic> page) => _api.leagues.list(<String, dynamic>{'isActive': true, ...page}),
        maxItems: 1200,
      ));

  void close() => _api.close();

  static List<Object?> _data(Map<String, dynamic> envelope) {
    final Object? data = envelope['data'];
    if (data is List) return data;
    throw const AppFailure.badResponse('envelope has no data list');
  }

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (e) {
      throw goalFailure(e);
    }
  }
}

/// GOAL SDK exception → [AppFailure].
AppFailure goalFailure(Object error) => switch (error) {
      AppFailure() => error,
      RateLimitException(:final String message) => AppFailure.rateLimited(message),
      NotFoundException(:final String message) => AppFailure.notFound(message),
      GoalApiTimeoutException(:final String message) => AppFailure.timeout(message),
      GoalApiConnectionException(:final String message) => AppFailure.noConnection(message),
      ServerException(:final String message) ||
      ServiceUnavailableException(:final String message) =>
        AppFailure.server(message),
      // Auth/plan/validation failures are not something a user can fix; they
      // read as the feed being unavailable.
      GoalApiException() => AppFailure.server('${error.code}: ${error.message}'),
      _ => AppFailure.unknown(error.toString()),
    };
