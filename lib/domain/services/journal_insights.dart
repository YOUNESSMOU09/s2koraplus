import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';

/// How close a prediction landed (§10).
enum PredictionVerdict {
  /// Score and winner both exactly right.
  exact,

  /// Right winner, wrong scoreline.
  rightWinner,

  /// Wrong.
  missed,

  /// The match has no final score yet, so there is nothing to grade.
  pending,
}

/// The graded prediction. Pure derivation — nothing here is stored, so a note
/// written before kickoff grades itself the moment the score lands.
class PredictionResult {
  const PredictionResult({
    required this.verdict,
    required this.accuracy,
    this.predictedHome,
    this.predictedAway,
    this.actualHome,
    this.actualAway,
  });

  final PredictionVerdict verdict;

  /// 0–100. Winner is worth half, each exact scoreline half a quarter — a
  /// 2–1 called as 3–1 is much closer than a 2–1 called as 0–3, and the
  /// number has to say so.
  final int accuracy;

  final int? predictedHome;
  final int? predictedAway;
  final int? actualHome;
  final int? actualAway;

  bool get hasScores =>
      predictedHome != null &&
      predictedAway != null &&
      actualHome != null &&
      actualAway != null;
}

/// Grades [prediction] against the score recorded on [header].
PredictionResult gradePrediction(MatchPrediction prediction, JournalHeader header) {
  if (prediction.isEmpty || !header.hasScore) {
    return PredictionResult(
      verdict: PredictionVerdict.pending,
      accuracy: 0,
      predictedHome: prediction.homeScore,
      predictedAway: prediction.awayScore,
      actualHome: header.homeGoals,
      actualAway: header.awayGoals,
    );
  }

  final int actualHome = header.homeGoals!;
  final int actualAway = header.awayGoals!;
  final MatchOutcome actual = MatchOutcome.fromGoals(actualHome, actualAway);
  final MatchOutcome? called = prediction.impliedWinner;

  int accuracy = 0;
  if (called != null && called == actual) accuracy += 50;
  if (prediction.homeScore == actualHome) accuracy += 25;
  if (prediction.awayScore == actualAway) accuracy += 25;

  final PredictionVerdict verdict;
  if (accuracy == 100) {
    verdict = PredictionVerdict.exact;
  } else if (called != null && called == actual) {
    verdict = PredictionVerdict.rightWinner;
  } else {
    verdict = PredictionVerdict.missed;
  }

  return PredictionResult(
    verdict: verdict,
    accuracy: accuracy,
    predictedHome: prediction.homeScore,
    predictedAway: prediction.awayScore,
    actualHome: actualHome,
    actualAway: actualAway,
  );
}

/// The structured result of "Summarise my match" (§17).
///
/// Deliberately DATA, not prose: the sentences are localised at render, so the
/// summary reads as naturally in Arabic as in English. Everything in it is
/// quoted back from what the user already wrote — nothing is invented, and it
/// never touches [FootballNote.note].
class JournalSummary {
  const JournalSummary({
    this.opinion,
    this.bestPlayer,
    this.bestPlayerRating,
    this.favouriteMoment,
    this.favouriteMomentClock,
    this.tacticalObservation,
    this.disappointment,
    this.finalRating,
    this.reactions = const <ReactionKind>[],
    this.moods = const <MoodKind>[],
  });

  /// The opening of the user's own prose, trimmed to a sentence.
  final String? opinion;
  final String? bestPlayer;
  final double? bestPlayerRating;
  final String? favouriteMoment;
  final String? favouriteMomentClock;
  final String? tacticalObservation;
  final String? disappointment;
  final double? finalRating;
  final List<ReactionKind> reactions;
  final List<MoodKind> moods;

  bool get isEmpty =>
      opinion == null &&
      bestPlayer == null &&
      favouriteMoment == null &&
      tacticalObservation == null &&
      disappointment == null &&
      finalRating == null &&
      reactions.isEmpty &&
      moods.isEmpty;
}

/// Builds the summary from what is already in [note].
JournalSummary summariseJournal(FootballNote note) {
  final PlayerRating? best = note.playerRatings.isEmpty
      ? null
      : note.playersByRating.first;
  final PlayerRating? worst = note.playerRatings.length < 2
      ? null
      : note.playersByRating.last;

  final FavouriteMoment? moment =
      note.moments.isEmpty ? null : note.sortedMoments.first;

  String? disappointment;
  if ((note.tactical.keyWeakness ?? '').trim().isNotEmpty) {
    disappointment = note.tactical.keyWeakness!.trim();
  } else if (worst != null && worst.rating < 60) {
    disappointment = worst.name;
  }

  String? tactical;
  if ((note.tactical.bestTactic ?? '').trim().isNotEmpty) {
    tactical = note.tactical.bestTactic!.trim();
  } else if ((note.tactical.comment ?? '').trim().isNotEmpty) {
    tactical = _firstSentence(note.tactical.comment!);
  }

  return JournalSummary(
    opinion: note.note.trim().isEmpty ? null : _firstSentence(note.note),
    bestPlayer: best?.name ?? note.manOfTheMatch?.player,
    bestPlayerRating: best?.ratingOutOfTen ?? note.manOfTheMatch?.ratingOutOfTen,
    favouriteMoment: moment?.title ?? note.favouriteGoal?.player,
    favouriteMomentClock: moment?.clockLabel,
    tacticalObservation: tactical,
    disappointment: disappointment,
    finalRating: note.ratings.experience,
    reactions: note.reactions.toList(growable: false),
    moods: note.moods.toList(growable: false),
  );
}

/// First sentence, capped — the summary quotes the user, it does not reprint
/// their whole essay.
String _firstSentence(String text, {int cap = 160}) {
  final String flat = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  final int stop = flat.indexOf(RegExp(r'[.!?؟\n]'));
  final String sentence = stop > 0 ? flat.substring(0, stop + 1) : flat;
  if (sentence.length <= cap) return sentence.trim();
  return '${sentence.substring(0, cap).trimRight()}…';
}
