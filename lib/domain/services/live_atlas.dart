/// "World right now" — the same live snapshot, arranged by country
/// (08_feature_worth_watching.md §7).
///
/// This is the breadth wedge made literal: the Norwegian second tier gets
/// exactly the same row as the Premier League. Flatness, not prestige.
///
/// Pure Dart. No Flutter import, no `Ref`, no `BuildContext`.
library;

import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/l10n/country_names.dart';

/// Every live fixture of one country, keeping its competitions intact.
class CountryLiveGroup {
  const CountryLiveGroup({
    required this.rawCountry,
    required this.competitions,
    required this.matchCount,
  });

  /// The API's RAW, HYPHENATED name (`Saudi-Arabia`, `Congo-DR`) — the join
  /// key, and the only stable identity a fixture carries for its country.
  ///
  /// NEVER RENDERED. Display goes through `localisedCountryName`, the flag
  /// through `countryFlagEmoji`. Grouping on the de-hyphenated display name
  /// would risk collapsing two distinct raw names into one bucket.
  final String rawCountry;

  /// >= 1, ordered by §7.4. Competitions are kept intact and never merged —
  /// the competition label is needed inside the expansion.
  final List<CompetitionGroup> competitions;

  /// Sum of fixtures across [competitions]. An OBSERVED COUNT, never an
  /// estimate and never a rating.
  final int matchCount;

  /// 98 of 997 competitions report `country: "World"` with a null country
  /// code. On an atlas these are conceptually not a country at all, so they
  /// are pinned as "International" rather than ranked among countries.
  bool get isInternational => rawCountry == kInternationalRawCountry;
}

/// The API's sentinel for a competition with no country.
const String kInternationalRawCountry = 'World';

/// Groups the live snapshot by country and orders both levels (§7.2–7.4).
///
/// Budget < 2 ms for ~82 fixtures / ~40 competitions / ~19 countries. Memoise
/// it behind a `Provider`; never call it from `build()`.
///
/// [languageCode] is required because the alphabetical tiebreak sorts on the
/// LOCALISED name — the list a user reads must be alphabetised in the language
/// they read it in.
List<CountryLiveGroup> buildLiveAtlas(
  LiveSnapshot snapshot, {
  required String languageCode,
}) {
  final Map<String, List<CompetitionGroup>> byCountry =
      <String, List<CompetitionGroup>>{};

  for (final CompetitionGroup group in snapshot.groups) {
    if (group.fixtures.isEmpty) continue;
    // Group by COUNTRY, not by competition: a country routinely has several
    // live competitions at once (England: Premier League + EFL Cup + National
    // League), and the atlas answers "where is football happening", not
    // "which competitions are on".
    byCountry.putIfAbsent(group.league.country, () => <CompetitionGroup>[]).add(group);
  }

  final List<CountryLiveGroup> out = <CountryLiveGroup>[];
  for (final MapEntry<String, List<CompetitionGroup>> entry in byCountry.entries) {
    final List<CompetitionGroup> competitions = entry.value.toList()
      ..sort(_compareCompetitions);
    int count = 0;
    for (final CompetitionGroup g in competitions) {
      count += g.fixtures.length;
    }
    out.add(CountryLiveGroup(
      rawCountry: entry.key,
      competitions: List<CompetitionGroup>.unmodifiable(competitions),
      matchCount: count,
    ));
  }

  out.sort((CountryLiveGroup a, CountryLiveGroup b) =>
      _compareCountries(a, b, languageCode));
  return List<CountryLiveGroup>.unmodifiable(out);
}

/// §7.4 — inside a country: live-match count desc, then name, then id.
///
/// Deliberate omission: `kPriorityLeagueIds` is NOT applied. Inside England the
/// Premier League and the National League are ordered by live-match count
/// alone. That is the flatness wedge, made literal (§3.7).
int _compareCompetitions(CompetitionGroup a, CompetitionGroup b) {
  final int byCount = b.fixtures.length.compareTo(a.fixtures.length);
  if (byCount != 0) return byCount;
  final int byName =
      a.league.name.toLowerCase().compareTo(b.league.name.toLowerCase());
  if (byName != 0) return byName;
  return a.league.id.compareTo(b.league.id);
}

/// §7.3 — STABILITY IS THE REQUIREMENT.
///
/// `matchCount` is the only key that changes between polls, and it only
/// changes when a match actually starts or finishes. Keys 3 and 4 are
/// invariant for the life of the app, so equal-count countries can never swap
/// positions and the list does not churn every 30 s.
///
/// Earliest kickoff was rejected as a tiebreak for exactly that reason: it is
/// derived from time and would reorder the whole list on every poll.
///
/// Collation caveat, accepted explicitly: Dart's `compareTo` is code-unit
/// ordering, so in `ar` an unmapped (Latin-fallback) name clusters at the top
/// of its count tier. `intl` ships no ICU collator and adding one is not worth
/// the binary size. Determinism is guaranteed; strict Arabic alphabetisation
/// is not claimed.
int _compareCountries(CountryLiveGroup a, CountryLiveGroup b, String languageCode) {
  final int byInternational =
      (a.isInternational ? 0 : 1).compareTo(b.isInternational ? 0 : 1);
  if (byInternational != 0) return byInternational;

  final int byCount = b.matchCount.compareTo(a.matchCount);
  if (byCount != 0) return byCount;

  final int byName = localisedCountryName(a.rawCountry, languageCode)
      .toLowerCase()
      .compareTo(localisedCountryName(b.rawCountry, languageCode).toLowerCase());
  if (byName != 0) return byName;

  return a.rawCountry.compareTo(b.rawCountry);
}

/// Countries with at least one live match — the header's headline number.
///
/// EXCLUDES the International group, because it is not a country and counting
/// it would make "19 countries" false.
int atlasCountryCount(List<CountryLiveGroup> atlas) =>
    atlas.where((CountryLiveGroup g) => !g.isInternational).length;
