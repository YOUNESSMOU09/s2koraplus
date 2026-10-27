/// Team identity as the app models it.
///
/// [logo] is the provider's badge URL. GOAL ids are opaque cuids, so a crest
/// URL can no longer be derived from the id — it has to travel with the data.
class TeamRef {
  const TeamRef({required this.id, required this.name, this.winner, this.logo});

  /// GOAL cuid, e.g. `cmr7ben6t0y4frx06dpe5n1sq`.
  final String id;
  final String name;

  /// NULLABLE and unreliable — null on draws *and* on many finished rows.
  /// The UI derives the winner from goals instead.
  final bool? winner;

  /// Badge URL from the provider; null when it sent none.
  final String? logo;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'name': name, 'winner': winner, 'logo': logo};

  static TeamRef fromJson(Map<String, dynamic> json) => TeamRef(
        id: json['id']?.toString() ?? '',
        name: (json['name'] as String?) ?? '',
        winner: json['winner'] as bool?,
        logo: json['logo'] as String?,
      );

  @override
  bool operator ==(Object other) => other is TeamRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Competition identity.
///
/// Country flags stay Unicode emoji derived from [country]. [country] holds the
/// HYPHENATED key the flag and Arabic-name tables use ("Saudi-Arabia");
/// the parser normalises GOAL's spaced names to it. De-hyphenate only at the
/// point of display, via `countryDisplayName`.
class LeagueRef {
  const LeagueRef({
    required this.id,
    required this.name,
    required this.country,
    required this.season,
    this.round,
    this.logo,
    this.popularity,
  });

  /// GOAL cuid. One league id spans all of its stages.
  final String id;
  final String name;
  final String country;
  final int season;
  final String? round;

  /// Competition logo URL from the provider.
  final String? logo;

  /// The provider's popularity score; higher competitions sort first.
  final int? popularity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'country': country,
        'season': season,
        'round': round,
        'logo': logo,
        'pop': popularity,
      };

  static LeagueRef fromJson(Map<String, dynamic> json) => LeagueRef(
        id: json['id']?.toString() ?? '',
        name: (json['name'] as String?) ?? '',
        country: (json['country'] as String?) ?? '',
        season: (json['season'] as num?)?.toInt() ?? 0,
        round: json['round'] as String?,
        logo: json['logo'] as String?,
        popularity: (json['pop'] as num?)?.toInt(),
      );

  @override
  bool operator ==(Object other) => other is LeagueRef && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// One of `score.halftime` / `fulltime` / `extratime` / `penalty`.
/// The object is always present; both leaves are nullable.
class ScoreLine {
  const ScoreLine(this.home, this.away);
  const ScoreLine.empty() : home = null, away = null;

  final int? home;
  final int? away;

  bool get isPresent => home != null && away != null;

  List<int?> toJson() => <int?>[home, away];

  static ScoreLine fromJson(Object? json) {
    if (json is List && json.length == 2) {
      return ScoreLine((json[0] as num?)?.toInt(), (json[1] as num?)?.toInt());
    }
    if (json is Map) {
      return ScoreLine(
        (json['home'] as num?)?.toInt(),
        (json['away'] as num?)?.toInt(),
      );
    }
    return const ScoreLine.empty();
  }
}

class Venue {
  const Venue({this.name, this.city});

  final String? name;
  final String? city;

  bool get isEmpty => name == null && city == null;

  /// `Åråsen · Lillestrøm`, or whichever half exists.
  String get label => <String>[
        if (name != null && name!.isNotEmpty) name!,
        if (city != null && city!.isNotEmpty) city!,
      ].join(' · ');

  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'city': city};

  static Venue? fromJson(Object? json) {
    if (json is! Map) return null;
    final String? name = json['name'] as String?;
    final String? city = json['city'] as String?;
    if ((name == null || name.isEmpty) && (city == null || city.isEmpty)) {
      return null;
    }
    return Venue(name: name, city: city);
  }
}
