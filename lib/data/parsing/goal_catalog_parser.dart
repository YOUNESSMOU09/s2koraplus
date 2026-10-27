/// GOAL standings / squad / league rows → domain values. Pure Dart.
library;

import 'package:marma/data/parsing/goal_fixture_parser.dart';
import 'package:marma/domain/entities/catalog.dart';

/// Rows come back UNSORTED, so this sorts by `overallLeaguePosition`. Rows with
/// no position (a stage table not yet populated) go last, in team-name order.
List<StandingRow> standingsFromGoal(List<Object?> rows) {
  final List<StandingRow> out = <StandingRow>[];
  for (final Object? raw in rows) {
    if (raw is! Map) continue;
    final Map<String, dynamic> r = raw.cast<String, dynamic>();
    final Map<String, dynamic> team =
        r['team'] is Map ? (r['team'] as Map).cast<String, dynamic>() : const <String, dynamic>{};
    final String teamId = (team['id'] ?? r['teamId'])?.toString() ?? '';
    final String teamName = (team['name'] ?? r['teamName'])?.toString() ?? '';
    if (teamId.isEmpty || teamName.isEmpty) continue;
    final String zone = (r['overallPromotion'] ?? '').toString().trim();
    out.add(StandingRow(
      position: parseGoalInt(r['overallLeaguePosition']) ?? 0,
      teamId: teamId,
      teamName: teamName,
      teamLogo: team['badge']?.toString(),
      played: parseGoalInt(r['overallLeaguePlayed']) ?? 0,
      won: parseGoalInt(r['overallLeagueW']) ?? 0,
      drawn: parseGoalInt(r['overallLeagueD']) ?? 0,
      lost: parseGoalInt(r['overallLeagueL']) ?? 0,
      goalsFor: parseGoalInt(r['overallLeagueGF']) ?? 0,
      goalsAgainst: parseGoalInt(r['overallLeagueGA']) ?? 0,
      points: parseGoalInt(r['overallLeaguePTS']) ?? 0,
      zone: zone.isEmpty ? null : zone,
    ));
  }
  out.sort((StandingRow a, StandingRow b) {
    final int pa = a.position <= 0 ? 1 << 20 : a.position;
    final int pb = b.position <= 0 ? 1 << 20 : b.position;
    return pa != pb ? pa.compareTo(pb) : a.teamName.compareTo(b.teamName);
  });
  return out;
}

SquadPosition squadPositionFromGoal(String? type) => switch ((type ?? '').toLowerCase()) {
      'goalkeepers' => SquadPosition.goalkeeper,
      'defenders' => SquadPosition.defender,
      'midfielders' => SquadPosition.midfielder,
      'forwards' => SquadPosition.forward,
      _ => SquadPosition.unknown,
    };

/// Goalkeepers → forwards, then by shirt number (unnumbered last).
List<SquadPlayer> squadFromGoal(List<Object?> rows) {
  final List<SquadPlayer> out = <SquadPlayer>[];
  for (final Object? raw in rows) {
    if (raw is! Map) continue;
    final Map<String, dynamic> p = raw.cast<String, dynamic>();
    final String id = p['id']?.toString() ?? '';
    final String name = p['name']?.toString().trim() ?? '';
    if (id.isEmpty || name.isEmpty) continue;
    // `/teams/{id}/players` also returns coaching staff, with nothing marking
    // them as such. Verified on Manchester City: the staff rows are the only
    // ones with no position, no shirt number and no age or birthdate. A player
    // missing just a position is kept, and listed after the forwards.
    if (p['type'] == null && p['number'] == null && p['age'] == null && p['birthdate'] == null) {
      continue;
    }
    out.add(SquadPlayer(
      id: id,
      name: name,
      position: squadPositionFromGoal(p['type']?.toString()),
      number: parseGoalInt(p['number']),
      photo: p['image']?.toString(),
      age: parseGoalInt(p['age']),
      isCaptain: p['isCaptain'] == true,
    ));
  }
  out.sort((SquadPlayer a, SquadPlayer b) {
    final int byPos = a.position.index.compareTo(b.position.index);
    if (byPos != 0) return byPos;
    return (a.number ?? 1 << 20).compareTo(b.number ?? 1 << 20);
  });
  return out;
}

List<LeagueSummary> leaguesFromGoal(List<Object?> rows) {
  final List<LeagueSummary> out = <LeagueSummary>[];
  for (final Object? raw in rows) {
    if (raw is! Map) continue;
    final Map<String, dynamic> l = raw.cast<String, dynamic>();
    final String id = l['id']?.toString() ?? '';
    final String name = l['name']?.toString() ?? '';
    if (id.isEmpty || name.isEmpty) continue;
    final Object? country = l['country'];
    out.add(LeagueSummary(
      id: id,
      name: name,
      country: goalCountryKey(
          l['countryName']?.toString() ?? (country is Map ? country['name']?.toString() : null)),
      logo: l['logo']?.toString(),
      popularity: parseGoalInt(l['popularity']),
    ));
  }
  out.sort((LeagueSummary a, LeagueSummary b) =>
      (b.popularity ?? -1).compareTo(a.popularity ?? -1));
  return out;
}
