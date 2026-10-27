import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';

/// One journal entry — everything a user recorded about ONE match, team or
/// player.
///
/// Identity is the pair ([targetType], [targetId]) and nothing else. That pair
/// becomes [storageKey], which becomes the filename, which is why two different
/// matches can never overwrite each other even if their ids collide across
/// types (§21).
class FootballNote {
  const FootballNote({
    required this.targetType,
    required this.targetId,
    required this.header,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    this.note = '',
    this.ratings = MatchRatings.empty,
    this.watchedCount = 0,
    this.firstWatchedAtMillis,
    this.lastWatchedAtMillis,
    this.reactions = const <ReactionKind>{},
    this.moods = const <MoodKind>{},
    this.tags = const <String>[],
    this.moments = const <FavouriteMoment>[],
    this.favouriteGoal,
    this.manOfTheMatch,
    this.playerRatings = const <PlayerRating>[],
    this.tactical = TacticalAnalysis.empty,
    this.prediction = MatchPrediction.empty,
    this.memory = MatchMemory.empty,
    this.events = const <JournalMatchEvent>[],
    this.statistics = const <CustomStat>[],
    this.activity = const <JournalActivity>[],
  });

  /// A brand-new, empty journal for [target].
  factory FootballNote.blank({
    required JournalTargetType targetType,
    required String targetId,
    required JournalHeader header,
    required DateTime now,
  }) {
    final int millis = now.toUtc().millisecondsSinceEpoch;
    return FootballNote(
      targetType: targetType,
      targetId: targetId,
      header: header,
      createdAtMillis: millis,
      updatedAtMillis: millis,
      activity: <JournalActivity>[
        JournalActivity(kind: JournalActivityKind.created, atMillis: millis),
      ],
    );
  }

  final JournalTargetType targetType;
  /// GOAL cuid for new journals; journals written before the migration keep
  /// their old numeric id as a string, so their file name is unchanged.
  final String targetId;
  final JournalHeader header;
  final String note;
  final MatchRatings ratings;
  final int watchedCount;
  final int? firstWatchedAtMillis;
  final int? lastWatchedAtMillis;
  final Set<ReactionKind> reactions;
  final Set<MoodKind> moods;

  /// Preset tags are stored as `#id` tokens, custom tags as the raw words.
  final List<String> tags;
  final List<FavouriteMoment> moments;
  final FavouriteGoal? favouriteGoal;
  final ManOfTheMatch? manOfTheMatch;
  final List<PlayerRating> playerRatings;
  final TacticalAnalysis tactical;
  final MatchPrediction prediction;
  final MatchMemory memory;
  final List<JournalMatchEvent> events;
  final List<CustomStat> statistics;

  /// Newest first, capped at [activityCap] — an autosaving journal would
  /// otherwise grow an unbounded log of "note updated".
  final List<JournalActivity> activity;

  final int createdAtMillis;
  final int updatedAtMillis;

  static const int activityCap = 80;

  /// The schema version written into every file. Bump only for a change the
  /// reader cannot absorb; [fromJson] tolerates missing keys by design.
  static const int schemaVersion = 1;

  static String keyFor(JournalTargetType type, String id) => '${type.id}_$id';

  String get storageKey => keyFor(targetType, targetId);

  DateTime get updatedAtLocal =>
      DateTime.fromMillisecondsSinceEpoch(updatedAtMillis, isUtc: true).toLocal();

  DateTime? get firstWatchedLocal => firstWatchedAtMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(firstWatchedAtMillis!, isUtc: true).toLocal();

  DateTime? get lastWatchedLocal => lastWatchedAtMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(lastWatchedAtMillis!, isUtc: true).toLocal();

  /// Chronological, added time last.
  List<JournalMatchEvent> get sortedEvents =>
      List<JournalMatchEvent>.of(events)
        ..sort((JournalMatchEvent a, JournalMatchEvent b) => a.sortKey.compareTo(b.sortKey));

  List<FavouriteMoment> get sortedMoments => List<FavouriteMoment>.of(moments)
    ..sort((FavouriteMoment a, FavouriteMoment b) => a.sortKey.compareTo(b.sortKey));

  List<PlayerRating> get playersByRating => List<PlayerRating>.of(playerRatings)
    ..sort((PlayerRating a, PlayerRating b) => b.rating.compareTo(a.rating));

  int get wordCount {
    final String trimmed = note.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  int get characterCount => note.characters;

  /// Whether ANYTHING has been recorded. Drives the §22 empty state, and is
  /// deliberately not `note.isEmpty` — a journal with three moments and a
  /// rating but no prose is very much not empty.
  bool get isEmpty =>
      note.trim().isEmpty &&
      ratings.isEmpty &&
      reactions.isEmpty &&
      moods.isEmpty &&
      tags.isEmpty &&
      moments.isEmpty &&
      favouriteGoal == null &&
      manOfTheMatch == null &&
      playerRatings.isEmpty &&
      tactical.isEmpty &&
      prediction.isEmpty &&
      memory.isEmpty &&
      events.isEmpty &&
      statistics.isEmpty &&
      watchedCount == 0;

  bool get isNotEmpty => !isEmpty;

  /// How much of the journal has been filled in, 0–1. Used by the header's
  /// completeness ring; not a score, and never shown as a percentage.
  double get completeness {
    const int sections = 12;
    int done = 0;
    if (note.trim().isNotEmpty) done++;
    if (!ratings.isEmpty) done++;
    if (reactions.isNotEmpty) done++;
    if (moods.isNotEmpty) done++;
    if (moments.isNotEmpty) done++;
    if (favouriteGoal != null) done++;
    if (manOfTheMatch != null) done++;
    if (playerRatings.isNotEmpty) done++;
    if (!tactical.isEmpty) done++;
    if (!prediction.isEmpty) done++;
    if (!memory.isEmpty) done++;
    if (events.isNotEmpty || statistics.isNotEmpty || tags.isNotEmpty) done++;
    return done / sections;
  }

  FootballNote copyWith({
    JournalHeader? header,
    String? note,
    MatchRatings? ratings,
    int? watchedCount,
    int? firstWatchedAtMillis,
    int? lastWatchedAtMillis,
    Set<ReactionKind>? reactions,
    Set<MoodKind>? moods,
    List<String>? tags,
    List<FavouriteMoment>? moments,
    FavouriteGoal? favouriteGoal,
    bool clearFavouriteGoal = false,
    ManOfTheMatch? manOfTheMatch,
    bool clearManOfTheMatch = false,
    List<PlayerRating>? playerRatings,
    TacticalAnalysis? tactical,
    MatchPrediction? prediction,
    MatchMemory? memory,
    List<JournalMatchEvent>? events,
    List<CustomStat>? statistics,
    List<JournalActivity>? activity,
    int? updatedAtMillis,
  }) =>
      FootballNote(
        targetType: targetType,
        targetId: targetId,
        header: header ?? this.header,
        note: note ?? this.note,
        ratings: ratings ?? this.ratings,
        watchedCount: watchedCount ?? this.watchedCount,
        firstWatchedAtMillis: firstWatchedAtMillis ?? this.firstWatchedAtMillis,
        lastWatchedAtMillis: lastWatchedAtMillis ?? this.lastWatchedAtMillis,
        reactions: reactions ?? this.reactions,
        moods: moods ?? this.moods,
        tags: tags ?? this.tags,
        moments: moments ?? this.moments,
        favouriteGoal: clearFavouriteGoal ? null : (favouriteGoal ?? this.favouriteGoal),
        manOfTheMatch: clearManOfTheMatch ? null : (manOfTheMatch ?? this.manOfTheMatch),
        playerRatings: playerRatings ?? this.playerRatings,
        tactical: tactical ?? this.tactical,
        prediction: prediction ?? this.prediction,
        memory: memory ?? this.memory,
        events: events ?? this.events,
        statistics: statistics ?? this.statistics,
        activity: activity ?? this.activity,
        createdAtMillis: createdAtMillis,
        updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      );

  /// The single mutation seam: every edit goes through here so `updatedAt` and
  /// the activity log can never drift from the data they describe.
  FootballNote touched(
    DateTime now, {
    JournalActivityKind? logged,
    String? detail,
    JournalHeader? header,
    String? note,
    MatchRatings? ratings,
    int? watchedCount,
    int? firstWatchedAtMillis,
    int? lastWatchedAtMillis,
    Set<ReactionKind>? reactions,
    Set<MoodKind>? moods,
    List<String>? tags,
    List<FavouriteMoment>? moments,
    FavouriteGoal? favouriteGoal,
    bool clearFavouriteGoal = false,
    ManOfTheMatch? manOfTheMatch,
    bool clearManOfTheMatch = false,
    List<PlayerRating>? playerRatings,
    TacticalAnalysis? tactical,
    MatchPrediction? prediction,
    MatchMemory? memory,
    List<JournalMatchEvent>? events,
    List<CustomStat>? statistics,
  }) {
    final int millis = now.toUtc().millisecondsSinceEpoch;
    List<JournalActivity>? log;
    if (logged != null) {
      final List<JournalActivity> next = <JournalActivity>[
        JournalActivity(kind: logged, atMillis: millis, detail: detail),
        // Consecutive edits of the same kind collapse: typing a paragraph is
        // one "note updated", not forty.
        ...activity.where((JournalActivity a) =>
            !(a.kind == logged && millis - a.atMillis < _collapseWindowMillis)),
      ];
      log = next.length > activityCap ? next.sublist(0, activityCap) : next;
    }
    return copyWith(
      header: header,
      note: note,
      ratings: ratings,
      watchedCount: watchedCount,
      firstWatchedAtMillis: firstWatchedAtMillis,
      lastWatchedAtMillis: lastWatchedAtMillis,
      reactions: reactions,
      moods: moods,
      tags: tags,
      moments: moments,
      favouriteGoal: favouriteGoal,
      clearFavouriteGoal: clearFavouriteGoal,
      manOfTheMatch: manOfTheMatch,
      clearManOfTheMatch: clearManOfTheMatch,
      playerRatings: playerRatings,
      tactical: tactical,
      prediction: prediction,
      memory: memory,
      events: events,
      statistics: statistics,
      activity: log,
      updatedAtMillis: millis,
    );
  }

  static const int _collapseWindowMillis = 10 * 60 * 1000;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'v': schemaVersion,
        'tt': targetType.id,
        'ti': targetId,
        'hd': header.toJson(),
        if (note.isNotEmpty) 'n': note,
        if (!ratings.isEmpty) 'rt': ratings.toJson(),
        if (watchedCount != 0) 'wc': watchedCount,
        if (firstWatchedAtMillis != null) 'fw': firstWatchedAtMillis,
        if (lastWatchedAtMillis != null) 'lw': lastWatchedAtMillis,
        if (reactions.isNotEmpty)
          're': reactions.map((ReactionKind r) => r.id).toList(growable: false),
        if (moods.isNotEmpty) 'mo': moods.map((MoodKind m) => m.id).toList(growable: false),
        if (tags.isNotEmpty) 'tg': tags,
        if (moments.isNotEmpty)
          'mm': moments.map((FavouriteMoment m) => m.toJson()).toList(growable: false),
        if (favouriteGoal != null) 'fg': favouriteGoal!.toJson(),
        if (manOfTheMatch != null) 'motm': manOfTheMatch!.toJson(),
        if (playerRatings.isNotEmpty)
          'pr': playerRatings.map((PlayerRating p) => p.toJson()).toList(growable: false),
        if (!tactical.isEmpty) 'ta': tactical.toJson(),
        if (!prediction.isEmpty) 'pd': prediction.toJson(),
        if (!memory.isEmpty) 'me': memory.toJson(),
        if (events.isNotEmpty)
          'ev': events.map((JournalMatchEvent e) => e.toJson()).toList(growable: false),
        if (statistics.isNotEmpty)
          'st': statistics.map((CustomStat s) => s.toJson()).toList(growable: false),
        if (activity.isNotEmpty)
          'ac': activity.map((JournalActivity a) => a.toJson()).toList(growable: false),
        'ca': createdAtMillis,
        'ua': updatedAtMillis,
      };

  /// Tolerant by construction: a journal is user-authored data that can never
  /// be re-fetched, so a single unreadable field must cost that field and
  /// nothing else.
  static FootballNote fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) =>
        ((json[key] as List<Object?>?) ?? const <Object?>[])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);

    final int created = (json['ca'] as num?)?.toInt() ?? 0;

    return FootballNote(
      targetType: JournalTargetType.fromId(json['tt'] as String?),
      targetId: json['ti']?.toString() ?? '',
      header: JournalHeader.fromJson(
          (json['hd'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      note: (json['n'] as String?) ?? '',
      ratings: MatchRatings.fromJson(json['rt'] as Map<String, dynamic>?),
      watchedCount: (json['wc'] as num?)?.toInt() ?? 0,
      firstWatchedAtMillis: (json['fw'] as num?)?.toInt(),
      lastWatchedAtMillis: (json['lw'] as num?)?.toInt(),
      reactions: ((json['re'] as List<Object?>?) ?? const <Object?>[])
          .map((Object? e) => ReactionKind.fromId(e as String?))
          .whereType<ReactionKind>()
          .toSet(),
      moods: ((json['mo'] as List<Object?>?) ?? const <Object?>[])
          .map((Object? e) => MoodKind.fromId(e as String?))
          .whereType<MoodKind>()
          .toSet(),
      tags: ((json['tg'] as List<Object?>?) ?? const <Object?>[])
          .whereType<String>()
          .toList(growable: false),
      moments: list('mm').map(FavouriteMoment.fromJson).toList(growable: false),
      favouriteGoal: json['fg'] is Map<String, dynamic>
          ? FavouriteGoal.fromJson(json['fg'] as Map<String, dynamic>)
          : null,
      manOfTheMatch: json['motm'] is Map<String, dynamic>
          ? ManOfTheMatch.fromJson(json['motm'] as Map<String, dynamic>)
          : null,
      playerRatings: list('pr').map(PlayerRating.fromJson).toList(growable: false),
      tactical: TacticalAnalysis.fromJson(json['ta'] as Map<String, dynamic>?),
      prediction: MatchPrediction.fromJson(json['pd'] as Map<String, dynamic>?),
      memory: MatchMemory.fromJson(json['me'] as Map<String, dynamic>?),
      events: list('ev').map(JournalMatchEvent.fromJson).toList(growable: false),
      statistics: list('st').map(CustomStat.fromJson).toList(growable: false),
      activity: list('ac').map(JournalActivity.fromJson).toList(growable: false),
      createdAtMillis: created,
      updatedAtMillis: (json['ua'] as num?)?.toInt() ?? created,
    );
  }
}

extension on String {
  /// Grapheme-ish length: a counter that says "12" for a 12-emoji note rather
  /// than "24" is the one a human would count.
  int get characters => runes.length;
}
