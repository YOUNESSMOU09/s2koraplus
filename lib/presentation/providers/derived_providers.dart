import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/core/utils/crest_url.dart';
import 'package:marma/domain/entities/catalog.dart';
import 'package:marma/presentation/providers/infra_providers.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/services/following_feed.dart';
import 'package:marma/domain/services/group_order.dart';
import 'package:marma/domain/services/search_index.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/app_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/providers/settings_providers.dart';

/// Competition groups for one day, with the favourites-aware ordering applied
/// in memory (never re-parsed).
final ProviderFamily<List<CompetitionGroup>, DayKey> orderedGroupsProvider =
    Provider.family<List<CompetitionGroup>, DayKey>((Ref ref, DayKey day) {
      final DayBucket? bucket = ref.watch(dayBucketProvider(day)).valueOrNull;
      if (bucket == null) return const <CompetitionGroup>[];
      return orderGroups(bucket.groups, ref.watch(favouritesProvider));
    });

/// Live competition groups, most-live-first, favourites still on top.
final Provider<List<CompetitionGroup>> liveGroupsProvider =
    Provider<List<CompetitionGroup>>((Ref ref) {
      final LiveSnapshot? snapshot = ref.watch(liveFeedProvider).valueOrNull;
      if (snapshot == null) return const <CompetitionGroup>[];
      return orderGroups(
        snapshot.groups,
        ref.watch(favouritesProvider),
        liveFirst: true,
      );
    });

/// Resolves a fixture by id from the live snapshot first, then today, tomorrow,
/// yesterday. This is both the per-row live merge and the deep-link fallback
/// (§7.3) — one lookup, one behaviour, no "not found" nav bug.
final ProviderFamily<Fixture?, String> resolvedFixtureProvider =
    Provider.family<Fixture?, String>((Ref ref, String fixtureId) {
      final Fixture? live = ref.watch(
        liveFeedProvider.select(
          (AsyncValue<LiveSnapshot> v) => v.valueOrNull?.byId[fixtureId],
        ),
      );

      Fixture? fromDay(DayKey day) => ref.watch(
        dayBucketProvider(
          day,
        ).select((AsyncValue<DayBucket> v) => v.valueOrNull?.byId[fixtureId]),
      );

      final Fixture? base =
          fromDay(DayKey.today) ??
          fromDay(DayKey.tomorrow) ??
          fromDay(DayKey.yesterday);

      if (live != null && base != null) return base.mergeLive(live);
      return live ?? base;
    });

/// The union of everything currently cached — the input to Following and
/// Search.
final Provider<List<DayBucket>> loadedBucketsProvider =
    Provider<List<DayBucket>>((Ref ref) {
      final List<DayBucket> buckets = <DayBucket>[];
      for (final DayKey day in DayKey.values) {
        final DayBucket? bucket = ref.watch(dayBucketProvider(day)).valueOrNull;
        if (bucket != null) buckets.add(bucket);
      }
      return buckets;
    });

final Provider<FollowingFeed> followingFeedProvider = Provider<FollowingFeed>((
  Ref ref,
) {
  return buildFollowingFeed(
    favourites: ref.watch(favouritesProvider),
    buckets: ref.watch(loadedBucketsProvider),
    live: ref.watch(liveFeedProvider).valueOrNull ?? LiveSnapshot.empty(),
  );
});

/// Built once per bucket set, not per keystroke.
///
/// Arabic country names are folded into the haystacks regardless of the active
/// locale: every string the API returns is Latin script, so without this an
/// Arabic-speaking user typing "السعودية" would match nothing at all.
final Provider<SearchIndex> searchIndexProvider = Provider<SearchIndex>(
  (Ref ref) => SearchIndex.build(
    ref.watch(loadedBucketsProvider),
    countryAliases: (String raw) => localisedCountryName(raw, 'ar'),
  ),
);

class SearchQueryNotifier extends AutoDisposeNotifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;

  void clear() => state = '';
}

final AutoDisposeNotifierProvider<SearchQueryNotifier, String>
searchQueryProvider = NotifierProvider.autoDispose<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final AutoDisposeProvider<SearchResults> searchResultsProvider =
    Provider.autoDispose<SearchResults>((Ref ref) {
      final String query = ref.watch(searchQueryProvider);
      if (query.trim().length < 2) return SearchResults.empty;
      final SearchResults local = ref.watch(searchIndexProvider).query(query);
      final List<LeagueSummary> catalog =
          ref.watch(leagueCatalogProvider).valueOrNull ??
          const <LeagueSummary>[];
      return withCatalogLeagues(local, catalog, query);
    });

/// Every active GOAL competition (~1019 rows, ~11 requests, cached 7 days on
/// disk). LAZY: only the search screen watches it, so it never loads at app
/// start. Kept alive once loaded so reopening search costs nothing.
final FutureProvider<List<LeagueSummary>> leagueCatalogProvider =
    FutureProvider<List<LeagueSummary>>((Ref ref) async {
      final List<LeagueSummary> leagues = await ref
          .watch(catalogRepositoryProvider)
          .leagues();
      for (final LeagueSummary l in leagues) {
        recordCrests(leagueId: l.id, leagueLogo: l.logo);
      }
      return leagues;
    });

/// A competition's table, sorted, with goal difference computed. Cached 6 h.
final FutureProviderFamily<List<StandingRow>, String> standingsProvider =
    FutureProvider.family<List<StandingRow>, String>(
      (Ref ref, String leagueId) =>
          ref.watch(catalogRepositoryProvider).standings(leagueId),
    );

/// A team's squad, goalkeepers to forwards. Cached 24 h.
final FutureProviderFamily<List<SquadPlayer>, String> squadProvider =
    FutureProvider.family<List<SquadPlayer>, String>(
      (Ref ref, String teamId) =>
          ref.watch(catalogRepositoryProvider).squad(teamId),
    );

/// "Updated N min ago" for one day surface. Recomputed on the shared ticker.
final ProviderFamily<Freshness, DayKey> freshnessProvider =
    Provider.family<Freshness, DayKey>((Ref ref, DayKey day) {
      ref.watch(tickerProvider);
      final DayBucket? bucket = ref.watch(dayBucketProvider(day)).valueOrNull;
      return Freshness.from(
        bucket?.checkedAt,
        online: ref.watch(isOnlineProvider),
      );
    });

final Provider<Freshness> liveFreshnessProvider = Provider<Freshness>((
  Ref ref,
) {
  ref.watch(tickerProvider);
  final LiveSnapshot? snapshot = ref.watch(liveFeedProvider).valueOrNull;
  return Freshness.from(
    snapshot?.fetchedAt,
    online: ref.watch(isOnlineProvider),
  );
});
