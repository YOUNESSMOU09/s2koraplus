/// Standings, squads and the competition catalog — the GOAL data beyond the
/// three day buckets. Plain values; parsing lives in `goal_catalog_parser`.
library;

class StandingRow {
  const StandingRow({
    required this.position,
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    this.teamLogo,
    this.zone,
  });

  final int position;
  final String teamId;
  final String teamName;
  final String? teamLogo;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  /// e.g. "Promotion - Champions League (League phase)"; null mid-table.
  final String? zone;

  /// The API has no goal-difference field; it is always GF − GA.
  int get goalDifference => goalsFor - goalsAgainst;
}

enum SquadPosition { goalkeeper, defender, midfielder, forward, unknown }

class SquadPlayer {
  const SquadPlayer({
    required this.id,
    required this.name,
    required this.position,
    this.number,
    this.photo,
    this.age,
    this.isCaptain = false,
  });

  final String id;
  final String name;
  final SquadPosition position;

  /// Shirt number; the API sends it as a string, sometimes blank.
  final int? number;
  final String? photo;
  final int? age;
  final bool isCaptain;
}

class LeagueSummary {
  const LeagueSummary({
    required this.id,
    required this.name,
    required this.country,
    this.logo,
    this.popularity,
  });

  final String id;
  final String name;

  /// Hyphenated flag/name-table key, as on `LeagueRef.country`.
  final String country;
  final String? logo;
  final int? popularity;
}
