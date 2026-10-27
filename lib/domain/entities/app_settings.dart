enum AppThemeChoice { system, light, dark }

enum AppLocaleChoice { system, en, ar }

class AppSettings {
  const AppSettings({
    this.theme = AppThemeChoice.system,
    this.locale = AppLocaleChoice.system,
    this.analyticsOptIn = false,
  });

  final AppThemeChoice theme;
  final AppLocaleChoice locale;
  final bool analyticsOptIn;

  AppSettings copyWith({
    AppThemeChoice? theme,
    AppLocaleChoice? locale,
    bool? analyticsOptIn,
  }) =>
      AppSettings(
        theme: theme ?? this.theme,
        locale: locale ?? this.locale,
        analyticsOptIn: analyticsOptIn ?? this.analyticsOptIn,
      );
}

/// A followed team or competition, with just enough metadata to render the
/// Following and Manage screens before any bucket has loaded.
class FavouriteTeam {
  const FavouriteTeam({required this.id, required this.name});
  final String id;
  final String name;
}

class FavouriteLeague {
  const FavouriteLeague({
    required this.id,
    required this.name,
    required this.country,
  });
  final String id;
  final String name;

  /// RAW hyphenated country — de-hyphenate with `countryDisplayName` to render.
  final String country;
}

class Favourites {
  const Favourites({
    this.teams = const <FavouriteTeam>[],
    this.leagues = const <FavouriteLeague>[],
  });

  final List<FavouriteTeam> teams;
  final List<FavouriteLeague> leagues;

  bool get isEmpty => teams.isEmpty && leagues.isEmpty;
  bool get isNotEmpty => !isEmpty;

  Set<String> get teamIds => teams.map((FavouriteTeam t) => t.id).toSet();
  Set<String> get leagueIds => leagues.map((FavouriteLeague l) => l.id).toSet();

  bool followsTeam(String id) => teams.any((FavouriteTeam t) => t.id == id);
  bool followsLeague(String id) => leagues.any((FavouriteLeague l) => l.id == id);

  /// Position of a league in the user's saved order, or -1.
  int leagueRank(String id) => leagues.indexWhere((FavouriteLeague l) => l.id == id);
}

/// Freshness of a cached surface, recomputed on the shared 30 s ticker.
enum FreshnessLevel { fresh, recent, stale, offline, never }

class Freshness {
  const Freshness({
    required this.level,
    required this.minutesAgo,
    required this.checkedAt,
  });

  final FreshnessLevel level;
  final int minutesAgo;
  final DateTime? checkedAt;

  static Freshness from(DateTime? checkedAt, {required bool online, DateTime? now}) {
    if (checkedAt == null || checkedAt.millisecondsSinceEpoch == 0) {
      return Freshness(
        level: online ? FreshnessLevel.never : FreshnessLevel.offline,
        minutesAgo: 0,
        checkedAt: null,
      );
    }
    final DateTime reference = now ?? DateTime.now();
    final int minutes = reference.difference(checkedAt).inMinutes.clamp(0, 99999);
    if (!online) {
      return Freshness(
        level: FreshnessLevel.offline,
        minutesAgo: minutes,
        checkedAt: checkedAt,
      );
    }
    final FreshnessLevel level = minutes < 2
        ? FreshnessLevel.fresh
        : (minutes < 10 ? FreshnessLevel.recent : FreshnessLevel.stale);
    return Freshness(level: level, minutesAgo: minutes, checkedAt: checkedAt);
  }
}

/// `/health` — About screen only.
class Health {
  const Health({
    required this.status,
    required this.redisConnected,
    required this.dataAvailable,
    this.lastUpdated,
  });

  final String status;
  final bool redisConnected;
  final bool dataAvailable;
  final DateTime? lastUpdated;

  bool get isHealthy =>
      <String>{'healthy', 'operational'}.contains(status.toLowerCase()) && dataAvailable;

  static Health fromJson(Map<String, dynamic> json) => Health(
        status: (json['status'] as String?) ?? 'unknown',
        redisConnected: (json['redisConnected'] as bool?) ?? false,
        dataAvailable: (json['dataAvailable'] as bool?) ?? false,
        lastUpdated: DateTime.tryParse((json['lastUpdated'] as String?) ?? ''),
      );
}
