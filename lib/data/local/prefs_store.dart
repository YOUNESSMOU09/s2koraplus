import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/data/local/prefs_keys.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/match_status.dart';

/// Typed, synchronous wrapper over `SharedPreferences`.
///
/// `main()` awaits `SharedPreferences.getInstance()` once, so every read here
/// is synchronous and no provider needs to be async for a scalar.
class PrefsStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  /// Applies the prefs schema version and stamps the install date.
  Future<void> migrate() async {
    // A missing key is a first run; an explicit older number is a real upgrade.
    // `getInt(...) ?? 0` cannot tell those apart, and would silently skip the
    // migration for a store written by schema 0.
    final bool firstRun = !_prefs.containsKey(PrefsKeys.schemaVersion);
    final int version =
        _prefs.getInt(PrefsKeys.schemaVersion) ?? AppEnv.prefsSchemaVersion;

    if (firstRun || version != AppEnv.prefsSchemaVersion) {
      if (!firstRun) {
        // Favourite-incompatible keys are dropped on a schema bump.
        await _prefs.remove(PrefsKeys.favTeamIds);
        await _prefs.remove(PrefsKeys.favTeamsMeta);
        await _prefs.remove(PrefsKeys.favLeagueIds);
        await _prefs.remove(PrefsKeys.favLeaguesMeta);
      }
      await _prefs.setInt(PrefsKeys.schemaVersion, AppEnv.prefsSchemaVersion);
    }
    for (final String key in PrefsKeys.retiredKeys) {
      if (_prefs.containsKey(key)) await _prefs.remove(key);
    }
    if (!_prefs.containsKey(PrefsKeys.installAt)) {
      await _prefs.setInt(
          PrefsKeys.installAt, DateTime.now().millisecondsSinceEpoch);
    }
  }

  // --- settings -------------------------------------------------------------

  AppSettings readSettings() => AppSettings(
        theme: _enumByName(
            AppThemeChoice.values, _prefs.getString(PrefsKeys.themeMode), AppThemeChoice.system),
        locale: _enumByName(
            AppLocaleChoice.values, _prefs.getString(PrefsKeys.locale), AppLocaleChoice.system),
        analyticsOptIn: _prefs.getBool(PrefsKeys.analyticsOptIn) ?? false,
      );

  Future<void> writeSettings(AppSettings s) async {
    await _prefs.setString(PrefsKeys.themeMode, s.theme.name);
    await _prefs.setString(PrefsKeys.locale, s.locale.name);
    await _prefs.setBool(PrefsKeys.analyticsOptIn, s.analyticsOptIn);
  }


  // --- ads --------------------------------------------------------------

  /// The end of the ad-free window bought by a rewarded view, or null.
  DateTime? readAdFreeUntil() {
    final int? millis = _prefs.getInt(PrefsKeys.adFreeUntil);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> writeAdFreeUntil(DateTime? until) async {
    if (until == null) {
      await _prefs.remove(PrefsKeys.adFreeUntil);
      return;
    }
    await _prefs.setInt(PrefsKeys.adFreeUntil, until.millisecondsSinceEpoch);
  }

  // --- favourites -----------------------------------------------------------

  Favourites readFavourites() {
    final List<String> teamIds = _readIdList(PrefsKeys.favTeamIds);
    final Map<String, dynamic> teamMeta = _readMap(PrefsKeys.favTeamsMeta);
    final List<String> leagueIds = _readIdList(PrefsKeys.favLeagueIds);
    final Map<String, dynamic> leagueMeta = _readMap(PrefsKeys.favLeaguesMeta);

    return Favourites(
      teams: teamIds.map((String id) {
        final Map<String, dynamic> m = _asMap(teamMeta[id]);
        return FavouriteTeam(id: id, name: (m['n'] as String?) ?? 'Team $id');
      }).toList(growable: false),
      leagues: leagueIds.map((String id) {
        final Map<String, dynamic> m = _asMap(leagueMeta[id]);
        return FavouriteLeague(
          id: id,
          name: (m['n'] as String?) ?? 'Competition $id',
          country: (m['c'] as String?) ?? '',
        );
      }).toList(growable: false),
    );
  }

  Future<void> writeFavourites(Favourites f) async {
    await _prefs.setString(
        PrefsKeys.favTeamIds, jsonEncode(f.teams.map((FavouriteTeam t) => t.id).toList()));
    await _prefs.setString(
      PrefsKeys.favTeamsMeta,
      jsonEncode(<String, dynamic>{
        for (final FavouriteTeam t in f.teams) t.id: <String, dynamic>{'n': t.name},
      }),
    );
    await _prefs.setString(PrefsKeys.favLeagueIds,
        jsonEncode(f.leagues.map((FavouriteLeague l) => l.id).toList()));
    await _prefs.setString(
      PrefsKeys.favLeaguesMeta,
      jsonEncode(<String, dynamic>{
        for (final FavouriteLeague l in f.leagues)
          l.id: <String, dynamic>{'n': l.name, 'c': l.country},
      }),
    );
  }

  // --- bucket metadata ------------------------------------------------------

  String? etag(DayKey day) => _prefs.getString(PrefsKeys.etag(day.name));
  String? liveEtag() => _prefs.getString(PrefsKeys.etag('live'));

  Future<void> setEtag(String bucket, String? value) async {
    if (value == null) {
      await _prefs.remove(PrefsKeys.etag(bucket));
    } else {
      await _prefs.setString(PrefsKeys.etag(bucket), value);
    }
  }

  DateTime fetchedAt(DayKey day) => DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(PrefsKeys.fetchedAt(day.name)) ?? 0);

  DateTime checkedAt(DayKey day) => DateTime.fromMillisecondsSinceEpoch(
      _prefs.getInt(PrefsKeys.checkedAt(day.name)) ?? 0);

  String serverDate(DayKey day) =>
      _prefs.getString(PrefsKeys.serverDate(day.name)) ?? '';

  Future<void> setBucketMeta(
    DayKey day, {
    DateTime? fetchedAt,
    DateTime? checkedAt,
    String? serverDate,
  }) async {
    if (fetchedAt != null) {
      await _prefs.setInt(
          PrefsKeys.fetchedAt(day.name), fetchedAt.millisecondsSinceEpoch);
    }
    if (checkedAt != null) {
      await _prefs.setInt(
          PrefsKeys.checkedAt(day.name), checkedAt.millisecondsSinceEpoch);
    }
    if (serverDate != null) {
      await _prefs.setString(PrefsKeys.serverDate(day.name), serverDate);
    }
  }

  /// Clears everything cache-shaped (used by Settings -> Clear cached data).
  Future<void> clearCacheMetadata() async {
    for (final String bucket in <String>['today', 'yesterday', 'tomorrow', 'live']) {
      await _prefs.remove(PrefsKeys.etag(bucket));
      await _prefs.remove(PrefsKeys.fetchedAt(bucket));
      await _prefs.remove(PrefsKeys.checkedAt(bucket));
      await _prefs.remove(PrefsKeys.serverDate(bucket));
    }
  }

  // --- helpers --------------------------------------------------------------

  /// GOAL ids are strings. Numbers (a pre-migration store) are read as
  /// strings too, though the schema bump normally drops those first.
  List<String> _readIdList(String key) {
    final String raw = _prefs.getString(key) ?? '[]';
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return <String>[];
      return <String>[
        for (final Object? v in decoded)
          if (v is String && v.isNotEmpty) v else if (v is num) '$v',
      ];
    } on FormatException {
      return <String>[];
    }
  }

  Map<String, dynamic> _readMap(String key) {
    final String raw = _prefs.getString(key) ?? '{}';
    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  static Map<String, dynamic> _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : const <String, dynamic>{};

  static T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) =>
      values.firstWhere((T v) => v.name == name, orElse: () => fallback);
}
