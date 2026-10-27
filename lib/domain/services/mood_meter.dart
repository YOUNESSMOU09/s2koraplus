import 'package:marma/domain/entities/journal/journal_enums.dart';

/// The mood meter's four quadrants: energy (high/low) × feeling (good/bad).
enum MoodQuadrant {
  electric(highEnergy: true, positive: true),
  tense(highEnergy: true, positive: false),
  content(highEnergy: false, positive: true),
  flat(highEnergy: false, positive: false);

  const MoodQuadrant({required this.highEnergy, required this.positive});

  final bool highEnergy;
  final bool positive;

  List<MoodKind> get moods => MoodKind.values
      .where((MoodKind m) => m.quadrant == this)
      .toList(growable: false);
}

extension MoodQuadrantOf on MoodKind {
  MoodQuadrant get quadrant => switch (this) {
        MoodKind.hype || MoodKind.entertained || MoodKind.shocked => MoodQuadrant.electric,
        MoodKind.angry || MoodKind.nervous => MoodQuadrant.tense,
        MoodKind.happy || MoodKind.relaxed => MoodQuadrant.content,
        MoodKind.emotional || MoodKind.bored => MoodQuadrant.flat,
      };
}

/// The "vibe" of a set of moods: the quadrant picked most often, ties broken
/// by quadrant order so the answer is stable. Null when nothing is picked.
MoodQuadrant? dominantQuadrant(Set<MoodKind> moods) {
  MoodQuadrant? best;
  int bestCount = 0;
  for (final MoodQuadrant q in MoodQuadrant.values) {
    final int count = moods.where((MoodKind m) => m.quadrant == q).length;
    if (count > bestCount) {
      best = q;
      bestCount = count;
    }
  }
  return best;
}
