import 'package:marma/core/utils/text_normalise.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/domain/services/reaction_meter.dart';

enum JournalFilter { all, rated, withNotes, predictions, topRated }

enum JournalSort { recent, matchDate, rating }

/// What the Journal tab is currently asking for. A value type so providers can
/// compare it cheaply.
class JournalQuery {
  const JournalQuery({
    this.search = '',
    this.filter = JournalFilter.all,
    this.sort = JournalSort.recent,
  });

  final String search;
  final JournalFilter filter;
  final JournalSort sort;

  /// Ratings at or above this count as "top rated".
  static const int topRatedThreshold = 8;

  bool get isDefault =>
      search.trim().isEmpty && filter == JournalFilter.all && sort == JournalSort.recent;

  JournalQuery copyWith({String? search, JournalFilter? filter, JournalSort? sort}) =>
      JournalQuery(
        search: search ?? this.search,
        filter: filter ?? this.filter,
        sort: sort ?? this.sort,
      );

  @override
  bool operator ==(Object other) =>
      other is JournalQuery &&
      other.search == search &&
      other.filter == filter &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(search, filter, sort);
}

/// One month of journals. [year]/[month] are local-calendar values.
class JournalMonthGroup {
  const JournalMonthGroup({required this.year, required this.month, required this.notes});

  final int year;
  final int month;
  final List<FootballNote> notes;
}

/// Headline numbers for the top of the Journal tab.
class JournalLibraryStats {
  const JournalLibraryStats({
    required this.count,
    required this.averageRating,
    required this.totalWords,
    required this.verdict,
  });

  factory JournalLibraryStats.from(List<FootballNote> notes) {
    final List<int> ratings = <int>[
      for (final FootballNote n in notes)
        if (n.ratings.overall != null) n.ratings.overall!,
    ];
    int words = 0;
    for (final FootballNote n in notes) {
      words += n.wordCount;
    }
    // Each journal's verdict counts once, however many reactions it has.
    final List<double> temps = <double>[
      for (final FootballNote n in notes) ?reactionTemperature(n.reactions),
    ];
    return JournalLibraryStats(
      count: notes.length,
      averageRating: ratings.isEmpty
          ? null
          : ratings.reduce((int a, int b) => a + b) / ratings.length,
      totalWords: words,
      verdict: temps.isEmpty
          ? null
          : verdictForTemperature(temps.reduce((double a, double b) => a + b) / temps.length),
    );
  }

  final int count;
  final double? averageRating;
  final int totalWords;

  /// The verdict your journals average out to; null with no reactions yet.
  final MatchVerdict? verdict;
}

/// A one-line preview of the user's own prose: stops at an appended summary
/// block (the `— title —` marker line) and drops markdown syntax.
String? noteSnippet(String note) {
  final RegExp marker = RegExp(r'^—\s.*\s—$');
  final RegExp leading = RegExp(r'^(#{1,6}\s+|[-*+]\s+|>\s*)');
  final List<String> own = <String>[];
  for (final String raw in note.split('\n')) {
    final String line = raw.trim();
    if (marker.hasMatch(line)) break;
    if (line.isNotEmpty) own.add(line);
  }
  final String text = own
      .map((String l) => l.replaceFirst(leading, '').replaceAll(RegExp(r'\*\*|__|`'), ''))
      .join(' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return text.isEmpty ? null : text;
}

/// Filters, sorts and month-groups journals. Pure: same input, same output.
class JournalLibrary {
  const JournalLibrary._();

  static bool matchesFilter(FootballNote n, JournalFilter filter) => switch (filter) {
        JournalFilter.all => true,
        JournalFilter.rated => n.ratings.overall != null,
        JournalFilter.withNotes => n.note.trim().isNotEmpty,
        JournalFilter.predictions => !n.prediction.isEmpty,
        JournalFilter.topRated =>
          (n.ratings.overall ?? 0) >= JournalQuery.topRatedThreshold,
      };

  /// Accent- and case-insensitive, over teams, competition, country, prose,
  /// tags and memory — everything a person might remember a match by.
  static bool matchesSearch(FootballNote n, String query) {
    final String q = normaliseForSearch(query);
    if (q.isEmpty) return true;
    final JournalHeader h = n.header;
    final String haystack = normaliseForSearch(<String?>[
      h.title,
      h.subtitle,
      h.homeTeamName,
      h.awayTeamName,
      h.competition,
      h.country,
      h.venue,
      n.note,
      ...n.tags,
      n.memory.story,
      n.memory.location,
      n.memory.people,
      n.memory.occasion,
    ].whereType<String>().join(' '));
    return q.split(' ').where((String t) => t.isNotEmpty).every(haystack.contains);
  }

  static List<FootballNote> apply(List<FootballNote> notes, JournalQuery query) {
    final List<FootballNote> out = notes
        .where((FootballNote n) =>
            matchesFilter(n, query.filter) && matchesSearch(n, query.search))
        .toList();
    out.sort(_comparator(query.sort));
    return out;
  }

  static int Function(FootballNote, FootballNote) _comparator(JournalSort sort) =>
      switch (sort) {
        JournalSort.recent => (FootballNote a, FootballNote b) =>
            b.updatedAtMillis.compareTo(a.updatedAtMillis),
        JournalSort.matchDate => (FootballNote a, FootballNote b) =>
            _matchMillis(b).compareTo(_matchMillis(a)),
        JournalSort.rating => (FootballNote a, FootballNote b) {
            final int byRating =
                (b.ratings.overall ?? -1).compareTo(a.ratings.overall ?? -1);
            return byRating != 0
                ? byRating
                : b.updatedAtMillis.compareTo(a.updatedAtMillis);
          },
      };

  /// Kickoff when known, otherwise when the journal was started.
  static int _matchMillis(FootballNote n) =>
      n.header.kickoffUtcMillis ?? n.createdAtMillis;

  /// Groups an already-sorted list by month, keeping the list's order. Rating
  /// order is not chronological, so it is returned as one ungrouped run.
  static List<JournalMonthGroup> group(List<FootballNote> sorted, JournalSort sort) {
    if (sorted.isEmpty) return const <JournalMonthGroup>[];
    if (sort == JournalSort.rating) {
      return <JournalMonthGroup>[JournalMonthGroup(year: 0, month: 0, notes: sorted)];
    }
    final List<JournalMonthGroup> groups = <JournalMonthGroup>[];
    for (final FootballNote n in sorted) {
      final DateTime at = DateTime.fromMillisecondsSinceEpoch(
        sort == JournalSort.matchDate ? _matchMillis(n) : n.updatedAtMillis,
        isUtc: true,
      ).toLocal();
      if (groups.isNotEmpty && groups.last.year == at.year && groups.last.month == at.month) {
        groups.last.notes.add(n);
      } else {
        groups.add(JournalMonthGroup(year: at.year, month: at.month, notes: <FootballNote>[n]));
      }
    }
    return groups;
  }
}
