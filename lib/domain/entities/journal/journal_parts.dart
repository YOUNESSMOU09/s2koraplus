import 'package:marma/domain/entities/journal/journal_enums.dart';

/// The value objects a [FootballNote] is composed of.
///
/// All of them are immutable with `copyWith`, and all of them round-trip
/// through JSON with SHORT keys — a heavy journal is written to disk on every
/// autosave tick, so the keys are the one place where verbosity costs real
/// milliseconds.

/// A snapshot of the thing the journal is about, taken when the note is
/// created and refreshed whenever live data is available.
///
/// This is NOT a convenience cache: the app only ever holds yesterday, today
/// and tomorrow, so a note written in June has no fixture behind it in August.
/// Without the snapshot the header would be blank for every note older than
/// three days, which is most of them.
class JournalHeader {
  const JournalHeader({
    required this.title,
    this.subtitle,
    this.homeTeamId,
    this.homeTeamName,
    this.awayTeamId,
    this.awayTeamName,
    this.homeGoals,
    this.awayGoals,
    this.competition,
    this.country,
    this.kickoffUtcMillis,
    this.venue,
    this.statusLabel,
    this.position,
    this.nationality,
  });

  /// Home team, team or player name — whatever the note is about.
  final String title;

  /// Away team for a match; competition for a team; club for a player.
  final String? subtitle;

  final String? homeTeamId;
  final String? homeTeamName;
  final String? awayTeamId;
  final String? awayTeamName;
  final int? homeGoals;
  final int? awayGoals;
  final String? competition;
  final String? country;
  final int? kickoffUtcMillis;
  final String? venue;
  final String? statusLabel;
  final String? position;
  final String? nationality;

  bool get hasScore => homeGoals != null && awayGoals != null;

  DateTime? get kickoffLocal => kickoffUtcMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(kickoffUtcMillis!, isUtc: true).toLocal();

  /// The actual outcome, once there is a score to read it from.
  MatchOutcome? get actualOutcome =>
      hasScore ? MatchOutcome.fromGoals(homeGoals!, awayGoals!) : null;

  JournalHeader copyWith({
    String? title,
    String? subtitle,
    String? homeTeamId,
    String? homeTeamName,
    String? awayTeamId,
    String? awayTeamName,
    int? homeGoals,
    int? awayGoals,
    String? competition,
    String? country,
    int? kickoffUtcMillis,
    String? venue,
    String? statusLabel,
    String? position,
    String? nationality,
  }) =>
      JournalHeader(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        homeTeamId: homeTeamId ?? this.homeTeamId,
        homeTeamName: homeTeamName ?? this.homeTeamName,
        awayTeamId: awayTeamId ?? this.awayTeamId,
        awayTeamName: awayTeamName ?? this.awayTeamName,
        homeGoals: homeGoals ?? this.homeGoals,
        awayGoals: awayGoals ?? this.awayGoals,
        competition: competition ?? this.competition,
        country: country ?? this.country,
        kickoffUtcMillis: kickoffUtcMillis ?? this.kickoffUtcMillis,
        venue: venue ?? this.venue,
        statusLabel: statusLabel ?? this.statusLabel,
        position: position ?? this.position,
        nationality: nationality ?? this.nationality,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        't': title,
        if (subtitle != null) 's': subtitle,
        if (homeTeamId != null) 'hi': homeTeamId,
        if (homeTeamName != null) 'hn': homeTeamName,
        if (awayTeamId != null) 'ai': awayTeamId,
        if (awayTeamName != null) 'an': awayTeamName,
        if (homeGoals != null) 'hg': homeGoals,
        if (awayGoals != null) 'ag': awayGoals,
        if (competition != null) 'c': competition,
        if (country != null) 'co': country,
        if (kickoffUtcMillis != null) 'k': kickoffUtcMillis,
        if (venue != null) 'v': venue,
        if (statusLabel != null) 'st': statusLabel,
        if (position != null) 'p': position,
        if (nationality != null) 'na': nationality,
      };

  static JournalHeader fromJson(Map<String, dynamic> json) => JournalHeader(
        title: (json['t'] as String?) ?? '',
        subtitle: json['s'] as String?,
        homeTeamId: json['hi']?.toString(),
        homeTeamName: json['hn'] as String?,
        awayTeamId: json['ai']?.toString(),
        awayTeamName: json['an'] as String?,
        homeGoals: (json['hg'] as num?)?.toInt(),
        awayGoals: (json['ag'] as num?)?.toInt(),
        competition: json['c'] as String?,
        country: json['co'] as String?,
        kickoffUtcMillis: (json['k'] as num?)?.toInt(),
        venue: json['v'] as String?,
        statusLabel: json['st'] as String?,
        position: json['p'] as String?,
        nationality: json['na'] as String?,
      );
}

/// §4 — the five 1–10 dials, plus the experience score derived from them.
class MatchRatings {
  const MatchRatings({
    this.overall,
    this.home,
    this.away,
    this.referee,
    this.atmosphere,
  });

  final int? overall;
  final int? home;
  final int? away;
  final int? referee;
  final int? atmosphere;

  static const MatchRatings empty = MatchRatings();

  bool get isEmpty =>
      overall == null &&
      home == null &&
      away == null &&
      referee == null &&
      atmosphere == null;

  List<int> get _given => <int>[?overall, ?home, ?away, ?referee, ?atmosphere];

  /// The overall match EXPERIENCE: the mean of every dial the user actually
  /// set. Unset dials are skipped rather than counted as zero — a match you
  /// rated 9 is not a 1.8 because you skipped the referee.
  double? get experience {
    final List<int> given = _given;
    if (given.isEmpty) return null;
    final int sum = given.reduce((int a, int b) => a + b);
    return sum / given.length;
  }

  int get dialsSet => _given.length;

  /// `null` clears a dial, so `copyWith` cannot express "leave unchanged" for
  /// these fields — the sentinel does.
  static const int keep = -1;

  MatchRatings copyWith({
    int? overall = keep,
    int? home = keep,
    int? away = keep,
    int? referee = keep,
    int? atmosphere = keep,
  }) =>
      MatchRatings(
        overall: overall == keep ? this.overall : overall,
        home: home == keep ? this.home : home,
        away: away == keep ? this.away : away,
        referee: referee == keep ? this.referee : referee,
        atmosphere: atmosphere == keep ? this.atmosphere : atmosphere,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (overall != null) 'o': overall,
        if (home != null) 'h': home,
        if (away != null) 'a': away,
        if (referee != null) 'r': referee,
        if (atmosphere != null) 'at': atmosphere,
      };

  static MatchRatings fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return MatchRatings(
      overall: (json['o'] as num?)?.toInt(),
      home: (json['h'] as num?)?.toInt(),
      away: (json['a'] as num?)?.toInt(),
      referee: (json['r'] as num?)?.toInt(),
      atmosphere: (json['at'] as num?)?.toInt(),
    );
  }
}

/// §5 — one player's performance, as the user saw it.
class PlayerRating {
  const PlayerRating({
    required this.id,
    required this.name,
    required this.rating,
    this.goals = 0,
    this.assists = 0,
    this.keyPasses = 0,
    this.defending,
    this.comment,
  });

  final String id;
  final String name;

  /// Tenths, 10–100, so `8.5/10` survives a round-trip without a float.
  final int rating;
  final int goals;
  final int assists;
  final int keyPasses;

  /// Defensive performance, 1–10. Optional — a winger's journal rarely has one.
  final int? defending;
  final String? comment;

  double get ratingOutOfTen => rating / 10;

  PlayerRating copyWith({
    String? name,
    int? rating,
    int? goals,
    int? assists,
    int? keyPasses,
    int? defending,
    bool clearDefending = false,
    String? comment,
    bool clearComment = false,
  }) =>
      PlayerRating(
        id: id,
        name: name ?? this.name,
        rating: rating ?? this.rating,
        goals: goals ?? this.goals,
        assists: assists ?? this.assists,
        keyPasses: keyPasses ?? this.keyPasses,
        defending: clearDefending ? null : (defending ?? this.defending),
        comment: clearComment ? null : (comment ?? this.comment),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'i': id,
        'n': name,
        'r': rating,
        if (goals != 0) 'g': goals,
        if (assists != 0) 'a': assists,
        if (keyPasses != 0) 'k': keyPasses,
        if (defending != null) 'd': defending,
        if (comment != null) 'c': comment,
      };

  static PlayerRating fromJson(Map<String, dynamic> json) => PlayerRating(
        id: (json['i'] as String?) ?? '',
        name: (json['n'] as String?) ?? '',
        rating: (json['r'] as num?)?.toInt().clamp(10, 100) ?? 50,
        goals: (json['g'] as num?)?.toInt() ?? 0,
        assists: (json['a'] as num?)?.toInt() ?? 0,
        keyPasses: (json['k'] as num?)?.toInt() ?? 0,
        defending: (json['d'] as num?)?.toInt(),
        comment: json['c'] as String?,
      );
}

/// §6 — a moment worth keeping.
class FavouriteMoment {
  const FavouriteMoment({
    required this.id,
    required this.title,
    this.minute,
    this.second,
    this.description,
    this.player,
    this.glyph,
  });

  final String id;
  final String title;

  /// Match clock. Null for "somewhere in the second half" — the timeline still
  /// carries it, just at the end.
  final int? minute;
  final int? second;
  final String? description;
  final String? player;
  final String? glyph;

  /// `67:32`, or `67` when no second was entered.
  String get clockLabel {
    if (minute == null) return '';
    if (second == null) return '$minute';
    return '$minute:${second!.toString().padLeft(2, '0')}';
  }

  int get sortKey => (minute ?? 999) * 60 + (second ?? 0);

  FavouriteMoment copyWith({
    String? title,
    int? minute,
    bool clearMinute = false,
    int? second,
    bool clearSecond = false,
    String? description,
    String? player,
    String? glyph,
  }) =>
      FavouriteMoment(
        id: id,
        title: title ?? this.title,
        minute: clearMinute ? null : (minute ?? this.minute),
        second: clearSecond ? null : (second ?? this.second),
        description: description ?? this.description,
        player: player ?? this.player,
        glyph: glyph ?? this.glyph,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'i': id,
        't': title,
        if (minute != null) 'm': minute,
        if (second != null) 's': second,
        if (description != null) 'd': description,
        if (player != null) 'p': player,
        if (glyph != null) 'g': glyph,
      };

  static FavouriteMoment fromJson(Map<String, dynamic> json) => FavouriteMoment(
        id: (json['i'] as String?) ?? '',
        title: (json['t'] as String?) ?? '',
        minute: (json['m'] as num?)?.toInt(),
        second: (json['s'] as num?)?.toInt(),
        description: json['d'] as String?,
        player: json['p'] as String?,
        glyph: json['g'] as String?,
      );
}

/// §8 — the one goal worth replaying.
class FavouriteGoal {
  const FavouriteGoal({
    required this.player,
    required this.kind,
    this.minute,
    this.description,
  });

  final String player;
  final GoalKind kind;
  final int? minute;
  final String? description;

  FavouriteGoal copyWith({
    String? player,
    GoalKind? kind,
    int? minute,
    bool clearMinute = false,
    String? description,
  }) =>
      FavouriteGoal(
        player: player ?? this.player,
        kind: kind ?? this.kind,
        minute: clearMinute ? null : (minute ?? this.minute),
        description: description ?? this.description,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'p': player,
        'k': kind.id,
        if (minute != null) 'm': minute,
        if (description != null) 'd': description,
      };

  static FavouriteGoal fromJson(Map<String, dynamic> json) => FavouriteGoal(
        player: (json['p'] as String?) ?? '',
        kind: GoalKind.fromId(json['k'] as String?),
        minute: (json['m'] as num?)?.toInt(),
        description: json['d'] as String?,
      );
}

/// §14 — the user's man of the match.
class ManOfTheMatch {
  const ManOfTheMatch({required this.player, this.rating, this.reason});

  final String player;

  /// Tenths, 10–100.
  final int? rating;
  final String? reason;

  double? get ratingOutOfTen => rating == null ? null : rating! / 10;

  ManOfTheMatch copyWith({
    String? player,
    int? rating,
    bool clearRating = false,
    String? reason,
  }) =>
      ManOfTheMatch(
        player: player ?? this.player,
        rating: clearRating ? null : (rating ?? this.rating),
        reason: reason ?? this.reason,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'p': player,
        if (rating != null) 'r': rating,
        if (reason != null) 'w': reason,
      };

  static ManOfTheMatch fromJson(Map<String, dynamic> json) => ManOfTheMatch(
        player: (json['p'] as String?) ?? '',
        rating: (json['r'] as num?)?.toInt(),
        reason: json['w'] as String?,
      );
}

/// §7 — a user-entered timeline marker.
class JournalMatchEvent {
  const JournalMatchEvent({
    required this.id,
    required this.kind,
    required this.minute,
    this.extra,
    this.label,
    this.forHome = true,
  });

  final String id;
  final JournalEventKind kind;
  final int minute;

  /// Added time: `90+3` is minute 90, extra 3. Kept apart so the marker lands
  /// at the end of the axis rather than beyond it.
  final int? extra;
  final String? label;

  /// Which half of the pitch axis the marker sits on.
  final bool forHome;

  String get minuteLabel => extra != null && extra! > 0 ? '$minute+$extra' : '$minute';

  int get sortKey => minute * 100 + (extra ?? 0);

  JournalMatchEvent copyWith({
    JournalEventKind? kind,
    int? minute,
    int? extra,
    bool clearExtra = false,
    String? label,
    bool? forHome,
  }) =>
      JournalMatchEvent(
        id: id,
        kind: kind ?? this.kind,
        minute: minute ?? this.minute,
        extra: clearExtra ? null : (extra ?? this.extra),
        label: label ?? this.label,
        forHome: forHome ?? this.forHome,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'i': id,
        'k': kind.id,
        'm': minute,
        if (extra != null) 'x': extra,
        if (label != null) 'l': label,
        'h': forHome,
      };

  static JournalMatchEvent fromJson(Map<String, dynamic> json) => JournalMatchEvent(
        id: (json['i'] as String?) ?? '',
        kind: JournalEventKind.fromId(json['k'] as String?),
        minute: (json['m'] as num?)?.toInt() ?? 0,
        extra: (json['x'] as num?)?.toInt(),
        label: json['l'] as String?,
        forHome: (json['h'] as bool?) ?? true,
      );
}

/// §9 — formation, the three prose lines, and the six rated aspects.
class TacticalAnalysis {
  const TacticalAnalysis({
    this.formation,
    this.bestTactic,
    this.keyWeakness,
    this.bestPlayer,
    this.comment,
    this.aspects = const <TacticalAspect, int>{},
  });

  final String? formation;
  final String? bestTactic;
  final String? keyWeakness;
  final String? bestPlayer;
  final String? comment;

  /// 1–10 per aspect. Absent means "not rated", never zero.
  final Map<TacticalAspect, int> aspects;

  static const TacticalAnalysis empty = TacticalAnalysis();

  bool get isEmpty =>
      (formation ?? '').isEmpty &&
      (bestTactic ?? '').isEmpty &&
      (keyWeakness ?? '').isEmpty &&
      (bestPlayer ?? '').isEmpty &&
      (comment ?? '').isEmpty &&
      aspects.isEmpty;

  TacticalAnalysis copyWith({
    String? formation,
    String? bestTactic,
    String? keyWeakness,
    String? bestPlayer,
    String? comment,
    Map<TacticalAspect, int>? aspects,
  }) =>
      TacticalAnalysis(
        formation: formation ?? this.formation,
        bestTactic: bestTactic ?? this.bestTactic,
        keyWeakness: keyWeakness ?? this.keyWeakness,
        bestPlayer: bestPlayer ?? this.bestPlayer,
        comment: comment ?? this.comment,
        aspects: aspects ?? this.aspects,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (formation != null) 'f': formation,
        if (bestTactic != null) 'b': bestTactic,
        if (keyWeakness != null) 'w': keyWeakness,
        if (bestPlayer != null) 'p': bestPlayer,
        if (comment != null) 'c': comment,
        if (aspects.isNotEmpty)
          'a': <String, int>{
            for (final MapEntry<TacticalAspect, int> e in aspects.entries) e.key.id: e.value,
          },
      };

  static TacticalAnalysis fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    final Map<String, dynamic> raw =
        (json['a'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final Map<TacticalAspect, int> aspects = <TacticalAspect, int>{};
    raw.forEach((String key, Object? value) {
      final TacticalAspect? aspect = TacticalAspect.fromId(key);
      final int? score = (value as num?)?.toInt();
      if (aspect != null && score != null) aspects[aspect] = score;
    });
    return TacticalAnalysis(
      formation: json['f'] as String?,
      bestTactic: json['b'] as String?,
      keyWeakness: json['w'] as String?,
      bestPlayer: json['p'] as String?,
      comment: json['c'] as String?,
      aspects: aspects,
    );
  }
}

/// §10 — what the user called before kickoff, and how it turned out.
class MatchPrediction {
  const MatchPrediction({
    this.homeScore,
    this.awayScore,
    this.winner,
    this.firstScorer,
    this.manOfTheMatch,
    this.madeAtMillis,
  });

  final int? homeScore;
  final int? awayScore;
  final MatchOutcome? winner;
  final String? firstScorer;
  final String? manOfTheMatch;
  final int? madeAtMillis;

  static const MatchPrediction empty = MatchPrediction();

  bool get isEmpty =>
      homeScore == null &&
      awayScore == null &&
      winner == null &&
      (firstScorer ?? '').isEmpty &&
      (manOfTheMatch ?? '').isEmpty;

  bool get hasScore => homeScore != null && awayScore != null;

  /// The outcome the predicted SCORE implies, which is what gets scored when
  /// the user set a scoreline but never tapped a winner.
  MatchOutcome? get impliedWinner =>
      hasScore ? MatchOutcome.fromGoals(homeScore!, awayScore!) : winner;

  MatchPrediction copyWith({
    int? homeScore,
    bool clearHomeScore = false,
    int? awayScore,
    bool clearAwayScore = false,
    MatchOutcome? winner,
    bool clearWinner = false,
    String? firstScorer,
    String? manOfTheMatch,
    int? madeAtMillis,
  }) =>
      MatchPrediction(
        homeScore: clearHomeScore ? null : (homeScore ?? this.homeScore),
        awayScore: clearAwayScore ? null : (awayScore ?? this.awayScore),
        winner: clearWinner ? null : (winner ?? this.winner),
        firstScorer: firstScorer ?? this.firstScorer,
        manOfTheMatch: manOfTheMatch ?? this.manOfTheMatch,
        madeAtMillis: madeAtMillis ?? this.madeAtMillis,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (homeScore != null) 'h': homeScore,
        if (awayScore != null) 'a': awayScore,
        if (winner != null) 'w': winner!.id,
        if (firstScorer != null) 'f': firstScorer,
        if (manOfTheMatch != null) 'm': manOfTheMatch,
        if (madeAtMillis != null) 't': madeAtMillis,
      };

  static MatchPrediction fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return MatchPrediction(
      homeScore: (json['h'] as num?)?.toInt(),
      awayScore: (json['a'] as num?)?.toInt(),
      winner: MatchOutcome.fromId(json['w'] as String?),
      firstScorer: json['f'] as String?,
      manOfTheMatch: json['m'] as String?,
      madeAtMillis: (json['t'] as num?)?.toInt(),
    );
  }
}

/// §12 — where you were, and who you were with.
class MatchMemory {
  const MatchMemory({
    this.story,
    this.location,
    this.people,
    this.occasion,
    this.watchedAtMillis,
  });

  final String? story;
  final String? location;
  final String? people;
  final String? occasion;
  final int? watchedAtMillis;

  static const MatchMemory empty = MatchMemory();

  bool get isEmpty =>
      (story ?? '').isEmpty &&
      (location ?? '').isEmpty &&
      (people ?? '').isEmpty &&
      (occasion ?? '').isEmpty &&
      watchedAtMillis == null;

  DateTime? get watchedAtLocal => watchedAtMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(watchedAtMillis!, isUtc: true).toLocal();

  MatchMemory copyWith({
    String? story,
    String? location,
    String? people,
    String? occasion,
    int? watchedAtMillis,
    bool clearWatchedAt = false,
  }) =>
      MatchMemory(
        story: story ?? this.story,
        location: location ?? this.location,
        people: people ?? this.people,
        occasion: occasion ?? this.occasion,
        watchedAtMillis:
            clearWatchedAt ? null : (watchedAtMillis ?? this.watchedAtMillis),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (story != null) 's': story,
        if (location != null) 'l': location,
        if (people != null) 'p': people,
        if (occasion != null) 'o': occasion,
        if (watchedAtMillis != null) 'w': watchedAtMillis,
      };

  static MatchMemory fromJson(Map<String, dynamic>? json) {
    if (json == null) return empty;
    return MatchMemory(
      story: json['s'] as String?,
      location: json['l'] as String?,
      people: json['p'] as String?,
      occasion: json['o'] as String?,
      watchedAtMillis: (json['w'] as num?)?.toInt(),
    );
  }
}

/// §16 — one manually recorded statistic, `62 – 38`.
class CustomStat {
  const CustomStat({
    required this.id,
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });

  final String id;
  final String label;
  final String homeValue;
  final String awayValue;

  CustomStat copyWith({String? label, String? homeValue, String? awayValue}) =>
      CustomStat(
        id: id,
        label: label ?? this.label,
        homeValue: homeValue ?? this.homeValue,
        awayValue: awayValue ?? this.awayValue,
      );

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'i': id, 'l': label, 'h': homeValue, 'a': awayValue};

  static CustomStat fromJson(Map<String, dynamic> json) => CustomStat(
        id: (json['i'] as String?) ?? '',
        label: (json['l'] as String?) ?? '',
        homeValue: (json['h'] as String?) ?? '',
        awayValue: (json['a'] as String?) ?? '',
      );
}

/// §15 — one line of the journal's own history.
class JournalActivity {
  const JournalActivity({
    required this.kind,
    required this.atMillis,
    this.detail,
  });

  final JournalActivityKind kind;
  final int atMillis;

  /// A short, already-formatted fragment: the rating, the moment's title, the
  /// reaction glyph. Never a sentence — the sentence is localised at render.
  final String? detail;

  DateTime get atLocal =>
      DateTime.fromMillisecondsSinceEpoch(atMillis, isUtc: true).toLocal();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'k': kind.id,
        't': atMillis,
        if (detail != null) 'd': detail,
      };

  static JournalActivity fromJson(Map<String, dynamic> json) => JournalActivity(
        kind: JournalActivityKind.fromId(json['k'] as String?),
        atMillis: (json['t'] as num?)?.toInt() ?? 0,
        detail: json['d'] as String?,
      );
}
