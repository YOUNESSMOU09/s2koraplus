/// The closed vocabularies of the Football Journal.
///
/// Every value carries a STABLE `id` that is what goes to disk — never
/// `Enum.index`, which would silently re-map every stored journal the first
/// time someone inserts a value into the middle of a list. `glyph` lives here
/// too because the emoji is part of the vocabulary itself, not a styling
/// choice; the human-readable label is resolved from `l10n` in the UI.
library;

/// What a journal entry is attached to. The pair (type, id) is the identity of
/// a note — see `FootballNote.storageKey`.
enum JournalTargetType {
  match('match'),
  team('team'),
  player('player');

  const JournalTargetType(this.id);

  final String id;

  static JournalTargetType fromId(String? id) => values.firstWhere(
        (JournalTargetType t) => t.id == id,
        orElse: () => JournalTargetType.match,
      );
}

/// §3 — how the match FELT. Multi-select.
enum ReactionKind {
  incredible('incredible', '🔥'),
  loved('loved', '😍'),
  unbelievable('unbelievable', '😱'),
  funny('funny', '😂'),
  angry('angry', '😡'),
  heartbreaking('heartbreaking', '😭'),
  crazy('crazy', '🤯'),
  boring('boring', '😴'),
  greatPerformance('great_performance', '👏'),
  disaster('disaster', '💀');

  const ReactionKind(this.id, this.glyph);

  final String id;
  final String glyph;

  static ReactionKind? fromId(String? id) {
    for (final ReactionKind k in values) {
      if (k.id == id) return k;
    }
    return null;
  }
}

/// §11 — how the WATCHER felt. Deliberately a separate axis from
/// [ReactionKind]: a 0–0 can be boring and still leave you relaxed.
enum MoodKind {
  hype('hype', '🔥'),
  happy('happy', '😍'),
  emotional('emotional', '😭'),
  angry('angry', '😡'),
  nervous('nervous', '😱'),
  shocked('shocked', '🤯'),
  entertained('entertained', '😂'),
  relaxed('relaxed', '😌'),
  bored('bored', '😴');

  const MoodKind(this.id, this.glyph);

  final String id;
  final String glyph;

  static MoodKind? fromId(String? id) {
    for (final MoodKind k in values) {
      if (k.id == id) return k;
    }
    return null;
  }
}

/// §8 — the shape of a goal.
enum GoalKind {
  longShot('long_shot', '🚀'),
  counterAttack('counter_attack', '⚡'),
  freeKick('free_kick', '🎯'),
  header('header', '🧠'),
  penalty('penalty', '🥅'),
  teamGoal('team_goal', '🔥'),
  soloGoal('solo_goal', '🎩');

  const GoalKind(this.id, this.glyph);

  final String id;
  final String glyph;

  static GoalKind fromId(String? id) => values.firstWhere(
        (GoalKind k) => k.id == id,
        orElse: () => GoalKind.teamGoal,
      );
}

/// §7 — the user's own timeline markers. These are NOT the API's
/// `MatchEvent`: the feed only carries events for live matches, and a journal
/// is usually written after full time, so the user enters what they remember.
enum JournalEventKind {
  goal('goal', '⚽'),
  yellowCard('yellow_card', '🟨'),
  redCard('red_card', '🟥'),
  substitution('substitution', '🔄'),
  save('save', '🧤'),
  assist('assist', '🎯'),
  missedChance('missed_chance', '❌'),
  refereeDecision('referee_decision', '🧑‍⚖️');

  const JournalEventKind(this.id, this.glyph);

  final String id;
  final String glyph;

  static JournalEventKind fromId(String? id) => values.firstWhere(
        (JournalEventKind k) => k.id == id,
        orElse: () => JournalEventKind.goal,
      );
}

/// §9 — the six aspects rated 1–10 in the tactical block.
enum TacticalAspect {
  possession('possession'),
  pressing('pressing'),
  counterAttacks('counter_attacks'),
  defensiveOrganisation('defensive_organisation'),
  setPieces('set_pieces'),
  buildUp('build_up');

  const TacticalAspect(this.id);

  final String id;

  static TacticalAspect? fromId(String? id) {
    for (final TacticalAspect a in values) {
      if (a.id == id) return a;
    }
    return null;
  }
}

/// §13 — the suggested tags. A user's own tags are free strings stored
/// alongside these ids, so the presets stay translatable while custom tags keep
/// the exact words the user typed.
enum PresetTag {
  masterclass('masterclass'),
  derby('derby'),
  championsLeague('champions_league'),
  comeback('comeback'),
  historic('historic'),
  crazyMatch('crazy_match'),
  favourite('favourite'),
  goalFest('goal_fest'),
  defensiveMasterclass('defensive_masterclass'),
  badReferee('bad_referee'),
  mustWatch('must_watch');

  const PresetTag(this.id);

  final String id;

  /// The stored form. The `#` prefix is what keeps a preset id from ever
  /// colliding with a custom tag the user typed.
  String get token => '#$id';

  static PresetTag? fromToken(String token) {
    for (final PresetTag t in values) {
      if (t.token == token) return t;
    }
    return null;
  }
}

/// §10 — the predicted (or actual) outcome.
enum MatchOutcome {
  home('home'),
  draw('draw'),
  away('away');

  const MatchOutcome(this.id);

  final String id;

  static MatchOutcome? fromId(String? id) {
    for (final MatchOutcome o in values) {
      if (o.id == id) return o;
    }
    return null;
  }

  static MatchOutcome fromGoals(int home, int away) {
    if (home > away) return MatchOutcome.home;
    if (away > home) return MatchOutcome.away;
    return MatchOutcome.draw;
  }
}

/// §15 — what the activity log records. Stored, not derived: the log is a
/// history ("rated 9/10 on Tuesday"), and a derivation could only ever show
/// the present state.
enum JournalActivityKind {
  created('created'),
  noteUpdated('note_updated'),
  rated('rated'),
  reactionAdded('reaction_added'),
  moodSet('mood_set'),
  momentAdded('moment_added'),
  favouriteGoalSet('favourite_goal_set'),
  manOfTheMatchSet('man_of_the_match_set'),
  playerRated('player_rated'),
  predictionMade('prediction_made'),
  tacticalUpdated('tactical_updated'),
  memoryWritten('memory_written'),
  eventAdded('event_added'),
  statAdded('stat_added'),
  tagAdded('tag_added'),
  watchedAgain('watched_again');

  const JournalActivityKind(this.id);

  final String id;

  static JournalActivityKind fromId(String? id) => values.firstWhere(
        (JournalActivityKind k) => k.id == id,
        orElse: () => JournalActivityKind.noteUpdated,
      );
}
