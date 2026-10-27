import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/presentation/providers/infra_providers.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).read();

  Future<void> _persist(AppSettings next) async {
    state = next;
    await ref.read(settingsRepositoryProvider).write(next);
  }

  Future<void> setTheme(AppThemeChoice value) => _persist(state.copyWith(theme: value));

  Future<void> setLocale(AppLocaleChoice value) => _persist(state.copyWith(locale: value));


}

final NotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

final Provider<ThemeMode> themeModeProvider = Provider<ThemeMode>((Ref ref) {
  return switch (ref.watch(settingsProvider.select((AppSettings s) => s.theme))) {
    AppThemeChoice.system => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark => ThemeMode.dark,
  };
});

/// `null` means "follow the device", which `MaterialApp` resolves against
/// `supportedLocales` with an `en` fallback.
final Provider<Locale?> localeProvider = Provider<Locale?>((Ref ref) {
  return switch (ref.watch(settingsProvider.select((AppSettings s) => s.locale))) {
    AppLocaleChoice.system => null,
    AppLocaleChoice.en => const Locale('en'),
    AppLocaleChoice.ar => const Locale('ar'),
  };
});

class FavouritesNotifier extends Notifier<Favourites> {
  @override
  Favourites build() => ref.watch(favouritesRepositoryProvider).read();

  Future<void> _persist(Favourites next) async {
    state = next;
    await ref.read(favouritesRepositoryProvider).write(next);
  }

  Future<void> toggleTeam(FavouriteTeam team) {
    final bool followed = state.followsTeam(team.id);
    final List<FavouriteTeam> teams = List<FavouriteTeam>.of(state.teams);
    if (followed) {
      teams.removeWhere((FavouriteTeam t) => t.id == team.id);
    } else {
      teams.add(team);
    }
    return _persist(Favourites(teams: teams, leagues: state.leagues));
  }

  Future<void> toggleLeague(FavouriteLeague league) {
    final bool followed = state.followsLeague(league.id);
    final List<FavouriteLeague> leagues = List<FavouriteLeague>.of(state.leagues);
    if (followed) {
      leagues.removeWhere((FavouriteLeague l) => l.id == league.id);
    } else {
      leagues.add(league);
    }
    return _persist(Favourites(teams: state.teams, leagues: leagues));
  }

  Future<void> removeTeam(String id) => _persist(Favourites(
        teams: state.teams.where((FavouriteTeam t) => t.id != id).toList(),
        leagues: state.leagues,
      ));

  Future<void> removeLeague(String id) => _persist(Favourites(
        teams: state.teams,
        leagues: state.leagues.where((FavouriteLeague l) => l.id != id).toList(),
      ));

  Future<void> reorderLeagues(int oldIndex, int newIndex) {
    final List<FavouriteLeague> leagues = List<FavouriteLeague>.of(state.leagues);
    if (oldIndex < 0 || oldIndex >= leagues.length) return Future<void>.value();
    final FavouriteLeague moved = leagues.removeAt(oldIndex);
    leagues.insert(newIndex.clamp(0, leagues.length), moved);
    return _persist(Favourites(teams: state.teams, leagues: leagues));
  }

  Future<void> reorderTeams(int oldIndex, int newIndex) {
    final List<FavouriteTeam> teams = List<FavouriteTeam>.of(state.teams);
    if (oldIndex < 0 || oldIndex >= teams.length) return Future<void>.value();
    final FavouriteTeam moved = teams.removeAt(oldIndex);
    teams.insert(newIndex.clamp(0, teams.length), moved);
    return _persist(Favourites(teams: teams, leagues: state.leagues));
  }

  Future<void> setAll(Favourites next) => _persist(next);
}

final NotifierProvider<FavouritesNotifier, Favourites> favouritesProvider =
    NotifierProvider<FavouritesNotifier, Favourites>(FavouritesNotifier.new);
