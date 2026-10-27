import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/fixture.dart';

/// Re-applies the favourites-aware part of the §5.4 competition ordering.
///
/// The isolate applies rules 4–5 (priority list, then country/name) once at
/// parse time. Rules 1–3 depend on the user's favourites, so they are applied
/// here, in memory — toggling a favourite must never trigger a re-parse of
/// 1204 fixtures.
List<CompetitionGroup> orderGroups(
  List<CompetitionGroup> parsed,
  Favourites favourites, {
  bool liveFirst = false,
}) {
  if (favourites.isEmpty && !liveFirst) return parsed;

  final Set<String> favTeams = favourites.teamIds;
  final List<CompetitionGroup> ordered = List<CompetitionGroup>.of(parsed);

  int rank(CompetitionGroup g) {
    final int favRank = favourites.leagueRank(g.league.id);
    if (favRank >= 0) return favRank; // rule 1 — user's saved order
    if (favTeams.isNotEmpty &&
        g.fixtures.any((Fixture f) => f.involvesTeam(favTeams))) {
      return 100000; // rule 2
    }
    return 200000; // rules 4–5, already applied by the parser
  }

  ordered.sort((CompetitionGroup a, CompetitionGroup b) {
    final int ra = rank(a), rb = rank(b);
    if (ra != rb) return ra.compareTo(rb);
    if (liveFirst) {
      final int byLive = b.liveCount.compareTo(a.liveCount); // rule 3
      if (byLive != 0) return byLive;
    }
    return 0; // stable: preserves the parser's ordering
  });
  return ordered;
}
