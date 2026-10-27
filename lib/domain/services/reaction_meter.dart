import 'package:marma/domain/entities/journal/journal_enums.dart';

/// The overall verdict a set of reactions adds up to, worst to best.
enum MatchVerdict { forgettable, rough, mixed, goodWatch, classic }

extension ReactionScore on ReactionKind {
  /// How much this reaction pulls the verdict up (+) or down (−), −3…+3.
  int get score => switch (this) {
        ReactionKind.incredible => 3,
        ReactionKind.loved => 2,
        ReactionKind.unbelievable => 2,
        ReactionKind.crazy => 2,
        ReactionKind.greatPerformance => 2,
        ReactionKind.funny => 1,
        ReactionKind.angry => -2,
        ReactionKind.heartbreaking => -2,
        ReactionKind.boring => -3,
        ReactionKind.disaster => -3,
      };

  bool get isPositive => score > 0;
}

/// Average score of [reactions] mapped to 0 (worst) … 1 (best). Null when
/// nothing is picked, so the meter can stay empty rather than read "mixed".
double? reactionTemperature(Set<ReactionKind> reactions) {
  if (reactions.isEmpty) return null;
  final int sum = reactions.fold(0, (int acc, ReactionKind r) => acc + r.score);
  final double average = sum / reactions.length;
  return ((average + 3) / 6).clamp(0.0, 1.0);
}

MatchVerdict? verdictFor(Set<ReactionKind> reactions) {
  final double? t = reactionTemperature(reactions);
  return t == null ? null : verdictForTemperature(t);
}

MatchVerdict verdictForTemperature(double t) {
  if (t >= 0.8) return MatchVerdict.classic;
  if (t >= 0.6) return MatchVerdict.goodWatch;
  if (t > 0.4) return MatchVerdict.mixed;
  // A lone Angry/Heartbreaking is rough; Boring/Disaster are forgettable.
  if (t > 0.1) return MatchVerdict.rough;
  return MatchVerdict.forgettable;
}
