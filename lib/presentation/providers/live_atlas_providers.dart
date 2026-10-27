import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/utils/dev_log.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/services/live_atlas.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';

/// Surface B reads the SAME `/live` snapshot as surface A and the competition
/// list. No extra request, no extra timer.
final AutoDisposeProviderFamily<List<CountryLiveGroup>, String>
    liveAtlasProvider =
    Provider.autoDispose.family<List<CountryLiveGroup>, String>(
        (Ref ref, String languageCode) {
  final LiveSnapshot? snapshot = ref.watch(liveFeedProvider).valueOrNull;
  if (snapshot == null) return const <CountryLiveGroup>[];
  final List<CountryLiveGroup> atlas =
      buildLiveAtlas(snapshot, languageCode: languageCode);
  devLog(
    'VERIFY-ATLAS',
    'fetchedAt=${snapshot.fetchedAt.toIso8601String()} '
    'countries=${atlasCountryCount(atlas)} matches=${snapshot.count} '
    '${atlas.map((CountryLiveGroup g) => '${g.rawCountry}:${g.matchCount}').join(' ')}',
  );
  return atlas;
});

/// Expanded countries, keyed by the INVARIANT raw country name so the set
/// survives reordering, locale changes and rebuilds.
class AtlasExpansionNotifier extends AutoDisposeNotifier<Set<String>> {
  @override
  Set<String> build() => AppEnv.devExpandCountry.isEmpty
      ? <String>{}
      : <String>{AppEnv.devExpandCountry};

  void toggle(String rawCountry) {
    final Set<String> next = <String>{...state};
    if (!next.remove(rawCountry)) next.add(rawCountry);
    state = next;
  }

  /// A country whose matches all finish disappears from the next snapshot and
  /// leaves a stale key behind. Stale keys are harmless — the set is only ever
  /// queried by countries that are present — but pruning keeps it bounded.
  void pruneTo(Set<String> present) {
    if (state.every(present.contains)) return;
    state = state.where(present.contains).toSet();
  }
}

final AutoDisposeNotifierProvider<AtlasExpansionNotifier, Set<String>>
    atlasExpansionProvider =
    NotifierProvider.autoDispose<AtlasExpansionNotifier, Set<String>>(
        AtlasExpansionNotifier.new);
