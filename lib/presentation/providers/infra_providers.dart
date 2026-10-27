import 'dart:io';

import 'package:goal_api/goal_api.dart';
import 'package:marma/app/app_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marma/data/local/bucket_cache.dart';
import 'package:marma/data/local/journal_store.dart';
import 'package:marma/data/local/prefs_store.dart';
import 'package:marma/data/local/ttl_cache.dart';
import 'package:marma/data/remote/goal_source.dart';
import 'package:marma/data/repositories/fixture_repository_impl.dart';
import 'package:marma/data/repositories/journal_repository_impl.dart';
import 'package:marma/data/repositories/settings_repository_impl.dart';
import 'package:marma/domain/repositories/repositories.dart';
import 'package:marma/presentation/providers/analytics.dart';

/// Injected in `main()` after `SharedPreferences.getInstance()`. Throws if a
/// test forgets to override it — silent defaults hide bugs.
final Provider<SharedPreferences> prefsProvider = Provider<SharedPreferences>(
  (Ref ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

/// Injected in `main()` from `getApplicationSupportDirectory()`.
final Provider<Directory> cacheDirProvider = Provider<Directory>(
  (Ref ref) => throw UnimplementedError('cacheDirProvider must be overridden'),
);

final Provider<PrefsStore> prefsStoreProvider =
    Provider<PrefsStore>((Ref ref) => PrefsStore(ref.watch(prefsProvider)));

/// The ONE GoalApi for the process: it pools connections and holds the
/// rate-limit snapshot the repository uses to back off.
final Provider<GoalSource> goalSourceProvider = Provider<GoalSource>((Ref ref) {
  final GoalSource source = GoalSource(GoalApi(
    apiKey: AppEnv.apiKey,
    baseUrl: AppEnv.baseUrl,
    timeout: const Duration(seconds: 20),
  ));
  ref.onDispose(source.close);
  return source;
});

final Provider<TtlCache> ttlCacheProvider = Provider<TtlCache>((Ref ref) => TtlCache(
    Directory('${ref.watch(cacheDirProvider).path}/${AppEnv.cacheDirName}/catalog')));

final Provider<CatalogRepository> catalogRepositoryProvider = Provider<CatalogRepository>(
    (Ref ref) => CatalogRepositoryImpl(ref.watch(goalSourceProvider), ref.watch(ttlCacheProvider)));

final Provider<BucketCache> bucketCacheProvider =
    Provider<BucketCache>((Ref ref) => BucketCache(ref.watch(cacheDirProvider)));

final Provider<FixtureRepository> fixtureRepositoryProvider =
    Provider<FixtureRepository>(
  (Ref ref) => FixtureRepositoryImpl(
    ref.watch(goalSourceProvider),
    ref.watch(bucketCacheProvider),
    ref.watch(prefsStoreProvider),
  ),
);

final Provider<JournalStore> journalStoreProvider =
    Provider<JournalStore>((Ref ref) => JournalStore(ref.watch(cacheDirProvider)));

final Provider<JournalRepository> journalRepositoryProvider =
    Provider<JournalRepository>(
        (Ref ref) => JournalRepositoryImpl(ref.watch(journalStoreProvider)));

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
        (Ref ref) => SettingsRepositoryImpl(ref.watch(prefsStoreProvider)));

final Provider<FavouritesRepository> favouritesRepositoryProvider =
    Provider<FavouritesRepository>(
        (Ref ref) => FavouritesRepositoryImpl(ref.watch(prefsStoreProvider)));

final Provider<AnalyticsSink> analyticsProvider =
    Provider<AnalyticsSink>((Ref ref) => const NoopAnalytics());
