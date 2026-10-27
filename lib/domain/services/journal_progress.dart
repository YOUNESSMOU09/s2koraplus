import 'package:marma/domain/entities/journal/football_note.dart';

/// The four workspaces a journal is split into.
enum JournalTab { write, rate, moments, analysis }

/// Every section of a journal, in the order a viewer naturally fills them in.
///
/// The order matters: [JournalProgress.nextUp] walks it to suggest what to do
/// next, so the first entries are the quick, low-effort ones.
enum JournalSection {
  note(JournalTab.write),
  reactions(JournalTab.write),
  mood(JournalTab.write),
  rating(JournalTab.rate),
  players(JournalTab.rate),
  manOfTheMatch(JournalTab.rate),
  moments(JournalTab.moments),
  favouriteGoal(JournalTab.moments),
  timeline(JournalTab.moments),
  prediction(JournalTab.analysis),
  tactical(JournalTab.analysis),
  memory(JournalTab.write),
  tags(JournalTab.write),
  stats(JournalTab.analysis),
  rewatch(JournalTab.analysis);

  const JournalSection(this.tab);

  final JournalTab tab;

  bool isDoneIn(FootballNote n) => switch (this) {
        JournalSection.note => n.note.trim().isNotEmpty,
        JournalSection.reactions => n.reactions.isNotEmpty,
        JournalSection.mood => n.moods.isNotEmpty,
        JournalSection.rating => !n.ratings.isEmpty,
        JournalSection.players => n.playerRatings.isNotEmpty,
        JournalSection.manOfTheMatch => n.manOfTheMatch != null,
        JournalSection.moments => n.moments.isNotEmpty,
        JournalSection.favouriteGoal => n.favouriteGoal != null,
        JournalSection.timeline => n.events.isNotEmpty,
        JournalSection.prediction => !n.prediction.isEmpty,
        JournalSection.tactical => !n.tactical.isEmpty,
        JournalSection.memory => !n.memory.isEmpty,
        JournalSection.tags => n.tags.isNotEmpty,
        JournalSection.stats => n.statistics.isNotEmpty,
        JournalSection.rewatch => n.watchedCount > 0,
      };
}

/// Pure read-model over a journal's fill state. No Flutter, no I/O.
class JournalProgress {
  JournalProgress(this.note);

  final FootballNote note;

  static List<JournalSection> sectionsOf(JournalTab tab) => JournalSection.values
      .where((JournalSection s) => s.tab == tab)
      .toList(growable: false);

  int get total => JournalSection.values.length;

  int get done =>
      JournalSection.values.where((JournalSection s) => s.isDoneIn(note)).length;

  double get fraction => total == 0 ? 0 : done / total;

  bool get isComplete => done == total;

  int doneIn(JournalTab tab) =>
      sectionsOf(tab).where((JournalSection s) => s.isDoneIn(note)).length;

  double fractionOf(JournalTab tab) {
    final int count = sectionsOf(tab).length;
    return count == 0 ? 0 : doneIn(tab) / count;
  }

  /// The first unfilled section, preferring ones on [current] when the user
  /// is already working in that tab and it still has gaps. Null once every
  /// section has something in it.
  JournalSection? nextUp({JournalTab? current}) {
    if (current != null) {
      for (final JournalSection s in sectionsOf(current)) {
        if (!s.isDoneIn(note)) return s;
      }
    }
    for (final JournalSection s in JournalSection.values) {
      if (!s.isDoneIn(note)) return s;
    }
    return null;
  }
}
