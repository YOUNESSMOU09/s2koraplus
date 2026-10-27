import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/l10n/app_localizations.dart';

/// Enum → localised label. One place, so no widget ever hard-codes a
/// vocabulary word and no locale can drift from another.
extension ReactionL10n on ReactionKind {
  String label(AppL10n l) => switch (this) {
        ReactionKind.incredible => l.journalReactionIncredible,
        ReactionKind.loved => l.journalReactionLoved,
        ReactionKind.unbelievable => l.journalReactionUnbelievable,
        ReactionKind.funny => l.journalReactionFunny,
        ReactionKind.angry => l.journalReactionAngry,
        ReactionKind.heartbreaking => l.journalReactionHeartbreaking,
        ReactionKind.crazy => l.journalReactionCrazy,
        ReactionKind.boring => l.journalReactionBoring,
        ReactionKind.greatPerformance => l.journalReactionGreatPerformance,
        ReactionKind.disaster => l.journalReactionDisaster,
      };
}

extension MoodL10n on MoodKind {
  String label(AppL10n l) => switch (this) {
        MoodKind.hype => l.journalMoodHype,
        MoodKind.happy => l.journalMoodHappy,
        MoodKind.emotional => l.journalMoodEmotional,
        MoodKind.angry => l.journalMoodAngry,
        MoodKind.nervous => l.journalMoodNervous,
        MoodKind.shocked => l.journalMoodShocked,
        MoodKind.entertained => l.journalMoodEntertained,
        MoodKind.relaxed => l.journalMoodRelaxed,
        MoodKind.bored => l.journalMoodBored,
      };
}

extension GoalKindL10n on GoalKind {
  String label(AppL10n l) => switch (this) {
        GoalKind.longShot => l.journalGoalKindLongShot,
        GoalKind.counterAttack => l.journalGoalKindCounterAttack,
        GoalKind.freeKick => l.journalGoalKindFreeKick,
        GoalKind.header => l.journalGoalKindHeader,
        GoalKind.penalty => l.journalGoalKindPenalty,
        GoalKind.teamGoal => l.journalGoalKindTeamGoal,
        GoalKind.soloGoal => l.journalGoalKindSoloGoal,
      };
}

extension JournalEventL10n on JournalEventKind {
  String label(AppL10n l) => switch (this) {
        JournalEventKind.goal => l.journalEventGoal,
        JournalEventKind.yellowCard => l.journalEventYellowCard,
        JournalEventKind.redCard => l.journalEventRedCard,
        JournalEventKind.substitution => l.journalEventSubstitution,
        JournalEventKind.save => l.journalEventSave,
        JournalEventKind.assist => l.journalEventAssist,
        JournalEventKind.missedChance => l.journalEventMissedChance,
        JournalEventKind.refereeDecision => l.journalEventRefereeDecision,
      };
}

extension TacticalAspectL10n on TacticalAspect {
  String label(AppL10n l) => switch (this) {
        TacticalAspect.possession => l.journalAspectPossession,
        TacticalAspect.pressing => l.journalAspectPressing,
        TacticalAspect.counterAttacks => l.journalAspectCounterAttacks,
        TacticalAspect.defensiveOrganisation => l.journalAspectDefensiveOrganisation,
        TacticalAspect.setPieces => l.journalAspectSetPieces,
        TacticalAspect.buildUp => l.journalAspectBuildUp,
      };
}

extension PresetTagL10n on PresetTag {
  String label(AppL10n l) => switch (this) {
        PresetTag.masterclass => l.journalTagMasterclass,
        PresetTag.derby => l.journalTagDerby,
        PresetTag.championsLeague => l.journalTagChampionsLeague,
        PresetTag.comeback => l.journalTagComeback,
        PresetTag.historic => l.journalTagHistoric,
        PresetTag.crazyMatch => l.journalTagCrazyMatch,
        PresetTag.favourite => l.journalTagFavourite,
        PresetTag.goalFest => l.journalTagGoalFest,
        PresetTag.defensiveMasterclass => l.journalTagDefensiveMasterclass,
        PresetTag.badReferee => l.journalTagBadReferee,
        PresetTag.mustWatch => l.journalTagMustWatch,
      };
}

extension MatchOutcomeL10n on MatchOutcome {
  String label(AppL10n l) => switch (this) {
        MatchOutcome.home => l.journalPredictionWinnerHome,
        MatchOutcome.draw => l.journalPredictionWinnerDraw,
        MatchOutcome.away => l.journalPredictionWinnerAway,
      };
}

extension JournalActivityL10n on JournalActivityKind {
  /// [detail] is already-formatted user content (a glyph, a name, a number).
  String label(AppL10n l, String? detail) {
    final String d = detail ?? '';
    return switch (this) {
      JournalActivityKind.created => l.journalActivityCreated,
      JournalActivityKind.noteUpdated => l.journalActivityNoteUpdated,
      JournalActivityKind.rated => l.journalActivityRated(d),
      JournalActivityKind.reactionAdded => l.journalActivityReactionAdded(
          _vocab(d, ReactionKind.values, (ReactionKind r) => r.id, (ReactionKind r) => r.glyph,
              (ReactionKind r) => r.label(l))),
      JournalActivityKind.moodSet => l.journalActivityMoodSet(
          _vocab(d, MoodKind.values, (MoodKind m) => m.id, (MoodKind m) => m.glyph,
              (MoodKind m) => m.label(l))),
      JournalActivityKind.momentAdded => l.journalActivityMomentAdded(d),
      JournalActivityKind.favouriteGoalSet => l.journalActivityFavouriteGoalSet(d),
      JournalActivityKind.manOfTheMatchSet => l.journalActivityManOfTheMatchSet(d),
      JournalActivityKind.playerRated => l.journalActivityPlayerRated(d),
      JournalActivityKind.predictionMade => l.journalActivityPredictionMade,
      JournalActivityKind.tacticalUpdated => l.journalActivityTacticalUpdated,
      JournalActivityKind.memoryWritten => l.journalActivityMemoryWritten,
      JournalActivityKind.eventAdded => l.journalActivityEventAdded(
          _vocab(d, JournalEventKind.values, (JournalEventKind e) => e.id,
              (JournalEventKind e) => e.glyph, (JournalEventKind e) => e.label(l))),
      JournalActivityKind.statAdded => l.journalActivityStatAdded(d),
      JournalActivityKind.tagAdded => l.journalActivityTagAdded(d),
      JournalActivityKind.watchedAgain => l.journalActivityWatchedAgain,
    };
  }
}

/// Activity details for closed vocabularies are logged as ids; entries written
/// before that hold the emoji. Either resolves to the localised word.
String _vocab<T>(
  String detail,
  List<T> values,
  String Function(T) id,
  String Function(T) glyph,
  String Function(T) label,
) {
  for (final T v in values) {
    if (id(v) == detail || glyph(v) == detail) return label(v);
  }
  return detail;
}
