import 'package:marma/core/utils/text_normalise.dart';
import 'package:marma/domain/entities/catalog.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/refs.dart';

/// A searchable team, deduped by `team.id` across the three buckets.
class TeamHit {
  const TeamHit({
    required this.team,
    required this.country,
    required this.leagueName,
  });
  final TeamRef team;

  /// RAW hyphenated country — de-hyphenate at render time.
  final String country;
  final String leagueName;
}

class SearchResults {
  const SearchResults({
    required this.competitions,
    required this.teams,
    required this.fixtures,
  });

  final List<LeagueRef> competitions;
  final List<TeamHit> teams;
  final List<Fixture> fixtures;

  bool get isEmpty => competitions.isEmpty && teams.isEmpty && fixtures.isEmpty;

  static const SearchResults empty = SearchResults(
    competitions: <LeagueRef>[],
    teams: <TeamHit>[],
    fixtures: <Fixture>[],
  );
}

/// Prebuilt, query-independent indices over the union of the loaded buckets.
/// Built once per bucket set, not per keystroke.
class SearchIndex {
  SearchIndex({
    required this.competitions,
    required this.teams,
    required this.fixtures,
  });

  final List<({LeagueRef league, String haystack})> competitions;
  final List<({TeamHit hit, String haystack})> teams;
  final List<({Fixture fixture, String haystack})> fixtures;

  /// [countryAliases] supplies extra searchable spellings for a RAW country
  /// name — in practice the Arabic name, so a user typing "السعودية" finds the
  /// Saudi competitions even though every string the API returns is Latin.
  /// Domain stays pure: the caller (a provider) injects the lookup.
  static SearchIndex build(
    List<DayBucket> buckets, {
    String Function(String rawCountry)? countryAliases,
  }) {
    String alias(String country) {
      final String? extra = countryAliases?.call(country);
      return (extra == null || extra.isEmpty) ? '' : '|$extra';
    }

    final Map<String, ({LeagueRef league, String haystack})> leagues =
        <String, ({LeagueRef league, String haystack})>{};
    final Map<String, ({TeamHit hit, String haystack})> teams =
        <String, ({TeamHit hit, String haystack})>{};
    final List<({Fixture fixture, String haystack})> fixtures =
        <({Fixture fixture, String haystack})>[];

    for (final DayBucket bucket in buckets) {
      final Map<String, String> haystacks = <String, String>{
        for (final SearchDoc doc in bucket.searchIndex)
          doc.fixtureId: doc.haystack,
      };
      for (final CompetitionGroup group in bucket.groups) {
        leagues.putIfAbsent(
          group.league.id,
          () => (
            league: group.league,
            haystack: normaliseForSearch(
              '${group.league.name}'
              '|${group.league.country}${alias(group.league.country)}',
            ),
          ),
        );
        for (final Fixture f in group.fixtures) {
          final String base =
              haystacks[f.id] ??
              normaliseForSearch('${f.home.name}|${f.away.name}');
          final String extra = normaliseForSearch(alias(f.league.country));
          fixtures.add((
            fixture: f,
            haystack: extra.isEmpty ? base : '$base|$extra',
          ));
          for (final TeamRef t in <TeamRef>[f.home, f.away]) {
            teams.putIfAbsent(
              t.id,
              () => (
                hit: TeamHit(
                  team: t,
                  country: f.league.country,
                  leagueName: f.league.name,
                ),
                haystack: normaliseForSearch(
                  '${t.name}|${f.league.country}${alias(f.league.country)}',
                ),
              ),
            );
          }
        }
      }
    }

    return SearchIndex(
      competitions: leagues.values.toList(growable: false),
      teams: teams.values.toList(growable: false),
      fixtures: fixtures,
    );
  }

  /// Diacritic- and Arabic-normalised prefix/substring search.
  SearchResults query(String rawQuery, {int limit = 40}) {
    final String q = normaliseForSearch(rawQuery);
    if (q.length < 2) return SearchResults.empty;

    bool matches(String haystack) => haystack.contains(q);

    final List<LeagueRef> comps = <LeagueRef>[];
    for (final ({LeagueRef league, String haystack}) e in competitions) {
      if (matches(e.haystack)) comps.add(e.league);
      if (comps.length >= limit) break;
    }

    final List<TeamHit> teamHits = <TeamHit>[];
    for (final ({TeamHit hit, String haystack}) e in teams) {
      if (matches(e.haystack)) teamHits.add(e.hit);
      if (teamHits.length >= limit) break;
    }

    final List<Fixture> fixtureHits = <Fixture>[];
    for (final ({Fixture fixture, String haystack}) e in fixtures) {
      if (matches(e.haystack)) fixtureHits.add(e.fixture);
      if (fixtureHits.length >= limit) break;
    }
    fixtureHits.sort(
      (Fixture a, Fixture b) => a.timestamp.compareTo(b.timestamp),
    );

    return SearchResults(
      competitions: comps,
      teams: teamHits,
      fixtures: fixtureHits,
    );
  }
}

/// Adds competitions from the full GOAL catalog to [base]: leagues with no
/// match in the loaded days can still be found and followed. Ones [base]
/// already lists are skipped; at most [limit] are added, most popular first
/// (the catalog arrives sorted that way).
SearchResults withCatalogLeagues(
  SearchResults base,
  List<LeagueSummary> catalog,
  String rawQuery, {
  int limit = 20,
}) {
  final String q = normaliseForSearch(rawQuery);
  if (q.length < 2 || catalog.isEmpty) return base;
  final List<String> terms = q
      .split(' ')
      .where((String t) => t.isNotEmpty)
      .toList();
  final Set<String> seen = <String>{
    for (final LeagueRef l in base.competitions) l.id,
  };
  final List<LeagueRef> extra = <LeagueRef>[];
  for (final LeagueSummary l in catalog) {
    if (extra.length >= limit) break;
    if (seen.contains(l.id)) continue;
    final String haystack = normaliseForSearch('${l.name}|${l.country}');
    if (!terms.every(haystack.contains)) continue;
    seen.add(l.id);
    extra.add(
      LeagueRef(
        id: l.id,
        name: l.name,
        country: l.country,
        season: 0,
        logo: l.logo,
      ),
    );
  }
  if (extra.isEmpty) return base;
  return SearchResults(
    competitions: <LeagueRef>[...base.competitions, ...extra],
    teams: base.teams,
    fixtures: base.fixtures,
  );
}
