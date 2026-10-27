import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/domain/repositories/repositories.dart';
import 'package:marma/domain/services/journal_library.dart';
import 'package:marma/domain/services/journal_progress.dart';
import 'package:marma/presentation/providers/infra_providers.dart';

/// Identity of one journal. A value type, because it is a provider family key.
class JournalKey {
  const JournalKey(this.type, this.id);

  const JournalKey.match(this.id) : type = JournalTargetType.match;

  final JournalTargetType type;
  final String id;

  @override
  bool operator ==(Object other) =>
      other is JournalKey && other.type == type && other.id == id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => FootballNote.keyFor(type, id);
}

enum SaveState { idle, pending, saved }

/// What the screen renders: the journal, whether it has been started, and where
/// autosave has got to.
class JournalViewState {
  const JournalViewState({
    required this.note,
    required this.started,
    this.save = SaveState.idle,
    this.savedAtMillis,
  });

  final FootballNote note;

  /// False until the user taps "Start football journal" (or a journal already
  /// exists on disk). Drives the §22 empty state.
  final bool started;

  final SaveState save;
  final int? savedAtMillis;

  DateTime? get savedAtLocal => savedAtMillis == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(savedAtMillis!, isUtc: true).toLocal();

  JournalViewState copyWith({
    FootballNote? note,
    bool? started,
    SaveState? save,
    int? savedAtMillis,
  }) =>
      JournalViewState(
        note: note ?? this.note,
        started: started ?? this.started,
        save: save ?? this.save,
        savedAtMillis: savedAtMillis ?? this.savedAtMillis,
      );
}

/// Reads, mutates and autosaves ONE journal.
///
/// Every mutation is a method here rather than a `copyWith` at the call site,
/// so `updatedAt`, the activity log and the debounce can never be forgotten by
/// a widget.
class JournalController extends FamilyAsyncNotifier<JournalViewState, JournalKey> {
  /// Long enough that a fast typist writes one file per sentence rather than
  /// one per keystroke; short enough that leaving the screen never loses work
  /// (the flush on dispose covers the rest).
  static const Duration autosaveDebounce = Duration(milliseconds: 700);

  Timer? _debounce;
  FootballNote? _pending;
  late JournalRepository _repository;

  /// The header the screen resolved from live fixture data, if any. Kept so a
  /// journal opened months later still shows the right teams and score.
  JournalHeader? _incomingHeader;

  @override
  Future<JournalViewState> build(JournalKey arg) async {
    _repository = ref.watch(journalRepositoryProvider);

    ref.onDispose(() {
      _debounce?.cancel();
      final FootballNote? unsaved = _pending;
      if (unsaved != null) {
        // Fire-and-forget on the way out: the widget tree is already gone, and
        // dropping the last sentence someone typed is not an acceptable
        // failure mode.
        unawaited(_repository.write(unsaved));
        _pending = null;
      }
    });

    final FootballNote? stored = await _repository.read(arg.type, arg.id);
    final JournalHeader header = _incomingHeader ??
        stored?.header ??
        const JournalHeader(title: '');

    if (stored == null) {
      return JournalViewState(
        note: FootballNote.blank(
          targetType: arg.type,
          targetId: arg.id,
          header: header,
          now: DateTime.now(),
        ),
        started: false,
      );
    }

    return JournalViewState(
      note: _incomingHeader == null ? stored : stored.copyWith(header: header),
      started: true,
      save: SaveState.saved,
      savedAtMillis: stored.updatedAtMillis,
    );
  }

  /// Called by the screen once the fixture behind this journal is resolved.
  /// Refreshes the stored snapshot (score, status) without touching anything
  /// the user wrote.
  void attachHeader(JournalHeader header) {
    _incomingHeader = header;
    final JournalViewState? current = state.valueOrNull;
    if (current == null) return;
    if (_sameHeader(current.note.header, header)) return;
    final FootballNote next = current.note.copyWith(header: header);
    state = AsyncData<JournalViewState>(current.copyWith(note: next));
    if (current.started) _schedule(next);
  }

  static bool _sameHeader(JournalHeader a, JournalHeader b) =>
      a.title == b.title &&
      a.subtitle == b.subtitle &&
      a.homeGoals == b.homeGoals &&
      a.awayGoals == b.awayGoals &&
      a.statusLabel == b.statusLabel &&
      a.venue == b.venue &&
      a.competition == b.competition;

  /// §22 — the empty state's CTA. Writes immediately so the journal exists on
  /// disk from the moment the user commits to it.
  Future<void> start() async {
    final JournalViewState? current = state.valueOrNull;
    if (current == null || current.started) return;
    final FootballNote note = current.note.touched(
      DateTime.now(),
      logged: JournalActivityKind.created,
    );
    state = AsyncData<JournalViewState>(
      current.copyWith(note: note, started: true, save: SaveState.pending),
    );
    await _flushNow(note);
  }

  // --- mutations ------------------------------------------------------------

  void setNote(String text) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          note: text,
          logged: JournalActivityKind.noteUpdated,
        ),
      );

  void setRatings(MatchRatings ratings, {String? detail}) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          ratings: ratings,
          logged: JournalActivityKind.rated,
          detail: detail,
        ),
      );

  void toggleReaction(ReactionKind reaction) => _mutate(
        (FootballNote n, DateTime now) {
          final Set<ReactionKind> next = Set<ReactionKind>.of(n.reactions);
          final bool added = next.add(reaction);
          if (!added) next.remove(reaction);
          return n.touched(
            now,
            reactions: next,
            logged: added ? JournalActivityKind.reactionAdded : null,
            detail: added ? reaction.id : null,
          );
        },
      );

  void toggleMood(MoodKind mood) => _mutate(
        (FootballNote n, DateTime now) {
          final Set<MoodKind> next = Set<MoodKind>.of(n.moods);
          final bool added = next.add(mood);
          if (!added) next.remove(mood);
          return n.touched(
            now,
            moods: next,
            logged: added ? JournalActivityKind.moodSet : null,
            detail: added ? mood.id : null,
          );
        },
      );

  void toggleTag(String token) => _mutate(
        (FootballNote n, DateTime now) {
          final List<String> next = List<String>.of(n.tags);
          final bool added = !next.remove(token);
          if (added) next.add(token);
          return n.touched(
            now,
            tags: next,
            logged: added ? JournalActivityKind.tagAdded : null,
            detail: added ? token : null,
          );
        },
      );

  void upsertMoment(FavouriteMoment moment) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          moments: _upsert<FavouriteMoment>(
              n.moments, moment, (FavouriteMoment m) => m.id == moment.id),
          logged: JournalActivityKind.momentAdded,
          detail: moment.title,
        ),
      );

  void removeMoment(String id) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          moments: n.moments
              .where((FavouriteMoment m) => m.id != id)
              .toList(growable: false),
        ),
      );

  void setFavouriteGoal(FavouriteGoal? goal) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          favouriteGoal: goal,
          clearFavouriteGoal: goal == null,
          logged: goal == null ? null : JournalActivityKind.favouriteGoalSet,
          detail: goal?.player,
        ),
      );

  void setManOfTheMatch(ManOfTheMatch? motm) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          manOfTheMatch: motm,
          clearManOfTheMatch: motm == null,
          logged: motm == null ? null : JournalActivityKind.manOfTheMatchSet,
          detail: motm?.player,
        ),
      );

  void upsertPlayerRating(PlayerRating rating) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          playerRatings: _upsert<PlayerRating>(
              n.playerRatings, rating, (PlayerRating p) => p.id == rating.id),
          logged: JournalActivityKind.playerRated,
          detail: rating.name,
        ),
      );

  void removePlayerRating(String id) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          playerRatings:
              n.playerRatings.where((PlayerRating p) => p.id != id).toList(growable: false),
        ),
      );

  void setTactical(TacticalAnalysis tactical) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          tactical: tactical,
          logged: JournalActivityKind.tacticalUpdated,
        ),
      );

  void setPrediction(MatchPrediction prediction) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          prediction: prediction.madeAtMillis == null
              ? prediction.copyWith(madeAtMillis: now.toUtc().millisecondsSinceEpoch)
              : prediction,
          logged: JournalActivityKind.predictionMade,
        ),
      );

  void setMemory(MatchMemory memory) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          memory: memory,
          logged: JournalActivityKind.memoryWritten,
        ),
      );

  void upsertEvent(JournalMatchEvent event) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          events: _upsert<JournalMatchEvent>(
              n.events, event, (JournalMatchEvent e) => e.id == event.id),
          logged: JournalActivityKind.eventAdded,
          detail: event.kind.id,
        ),
      );

  void removeEvent(String id) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          events:
              n.events.where((JournalMatchEvent e) => e.id != id).toList(growable: false),
        ),
      );

  void upsertStat(CustomStat stat) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          statistics:
              _upsert<CustomStat>(n.statistics, stat, (CustomStat s) => s.id == stat.id),
          logged: JournalActivityKind.statAdded,
          detail: stat.label,
        ),
      );

  void removeStat(String id) => _mutate(
        (FootballNote n, DateTime now) => n.touched(
          now,
          statistics: n.statistics.where((CustomStat s) => s.id != id).toList(growable: false),
        ),
      );

  /// §18 — "+ Watched again". Stamps first/last watch dates on the way.
  void watchedAgain() => _mutate(
        (FootballNote n, DateTime now) {
          final int millis = now.toUtc().millisecondsSinceEpoch;
          return n.touched(
            now,
            watchedCount: n.watchedCount + 1,
            firstWatchedAtMillis: n.firstWatchedAtMillis ?? millis,
            lastWatchedAtMillis: millis,
            logged: JournalActivityKind.watchedAgain,
            detail: '${n.watchedCount + 1}',
          );
        },
      );

  /// Wipes the journal for this target. The confirmation lives in the UI; by
  /// the time this runs the decision is made.
  Future<void> deleteJournal() async {
    _debounce?.cancel();
    _pending = null;
    await _repository.delete(arg.type, arg.id);
    ref.invalidate(allJournalsProvider);
    state = AsyncData<JournalViewState>(
      JournalViewState(
        note: FootballNote.blank(
          targetType: arg.type,
          targetId: arg.id,
          header: _incomingHeader ?? state.valueOrNull?.note.header ?? const JournalHeader(title: ''),
          now: DateTime.now(),
        ),
        started: false,
      ),
    );
  }

  /// Undo for [deleteJournal]: puts a previously deleted journal back,
  /// exactly as it was, and writes it straight to disk.
  Future<void> restore(FootballNote note) async {
    _debounce?.cancel();
    state = AsyncData<JournalViewState>(JournalViewState(
      note: note,
      started: true,
      save: SaveState.pending,
    ));
    await _flushNow(note);
  }

  /// Writes anything outstanding right now — called when the app backgrounds
  /// and when the user leaves the screen.
  Future<void> flush() async {
    _debounce?.cancel();
    final FootballNote? unsaved = _pending;
    if (unsaved == null) return;
    await _flushNow(unsaved);
  }

  // --- plumbing -------------------------------------------------------------

  static List<T> _upsert<T>(List<T> items, T value, bool Function(T) matches) {
    final int index = items.indexWhere(matches);
    final List<T> next = List<T>.of(items);
    if (index >= 0) {
      next[index] = value;
    } else {
      next.add(value);
    }
    return next;
  }

  void _mutate(FootballNote Function(FootballNote note, DateTime now) change) {
    final JournalViewState? current = state.valueOrNull;
    if (current == null) return;
    final FootballNote next = change(current.note, DateTime.now());
    state = AsyncData<JournalViewState>(current.copyWith(
      note: next,
      // The first edit from the empty state counts as starting the journal.
      started: true,
      save: SaveState.pending,
    ));
    _schedule(next);
  }

  void _schedule(FootballNote note) {
    _pending = note;
    _debounce?.cancel();
    _debounce = Timer(autosaveDebounce, () => unawaited(_flushNow(note)));
  }

  Future<void> _flushNow(FootballNote note) async {
    await _repository.write(note);
    _pending = null;
    // The Journal tab lists what is on disk; without this it would show a
    // stale ordering (and a stale snippet) until the app restarted.
    ref.invalidate(allJournalsProvider);
    final JournalViewState? current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData<JournalViewState>(current.copyWith(
      save: SaveState.saved,
      savedAtMillis: note.updatedAtMillis,
    ));
  }
}

final AsyncNotifierProviderFamily<JournalController, JournalViewState, JournalKey>
    journalProvider =
    AsyncNotifierProvider.family<JournalController, JournalViewState, JournalKey>(
  JournalController.new,
);

/// Every journal on disk, newest first. Used by the match row's "has a journal"
/// marker and by any future journal index.
final FutureProvider<List<FootballNote>> allJournalsProvider =
    FutureProvider<List<FootballNote>>(
        (Ref ref) => ref.watch(journalRepositoryProvider).readAll());

// --- Journal tab (library) ---------------------------------------------------

class JournalQueryNotifier extends Notifier<JournalQuery> {
  @override
  JournalQuery build() => const JournalQuery();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setFilter(JournalFilter value) => state = state.copyWith(filter: value);
  void setSort(JournalSort value) => state = state.copyWith(sort: value);
  void reset() => state = const JournalQuery();
}

final NotifierProvider<JournalQueryNotifier, JournalQuery> journalQueryProvider =
    NotifierProvider<JournalQueryNotifier, JournalQuery>(JournalQueryNotifier.new);

/// Everything the Journal tab renders, derived from disk + the current query.
class JournalLibraryView {
  const JournalLibraryView({
    required this.all,
    required this.stats,
    required this.groups,
    required this.visibleCount,
  });

  /// Every journal on disk, unfiltered — decides empty state vs. no results.
  final List<FootballNote> all;
  final JournalLibraryStats stats;
  final List<JournalMonthGroup> groups;
  final int visibleCount;
}

final Provider<AsyncValue<JournalLibraryView>> journalLibraryProvider =
    Provider<AsyncValue<JournalLibraryView>>((Ref ref) {
  final JournalQuery query = ref.watch(journalQueryProvider);
  return ref.watch(allJournalsProvider).whenData((List<FootballNote> notes) {
    final List<FootballNote> visible = JournalLibrary.apply(notes, query);
    return JournalLibraryView(
      all: notes,
      stats: JournalLibraryStats.from(notes),
      groups: JournalLibrary.group(visible, query.sort),
      visibleCount: visible.length,
    );
  });
});

/// Deletes a journal from outside its own screen (swipe on the Journal tab).
/// The open controller, if any, is invalidated so it cannot resurrect a stale
/// copy from memory.
Future<void> deleteJournalNote(WidgetRef ref, FootballNote note) async {
  await ref.read(journalRepositoryProvider).delete(note.targetType, note.targetId);
  ref.invalidate(journalProvider(JournalKey(note.targetType, note.targetId)));
  ref.invalidate(allJournalsProvider);
}

/// Undo for [deleteJournalNote].
Future<void> restoreJournalNote(WidgetRef ref, FootballNote note) async {
  await ref.read(journalRepositoryProvider).write(note);
  ref.invalidate(journalProvider(JournalKey(note.targetType, note.targetId)));
  ref.invalidate(allJournalsProvider);
}

// --- Journal screen ----------------------------------------------------------

/// The workspace tab last used, so the next journal opens where you left off.
class JournalTabNotifier extends Notifier<JournalTab> {
  @override
  JournalTab build() => AppEnv.devJournalTab >= 0 && AppEnv.devJournalTab < JournalTab.values.length
      ? JournalTab.values[AppEnv.devJournalTab]
      : JournalTab.write;

  void set(JournalTab tab) => state = tab;
}

final NotifierProvider<JournalTabNotifier, JournalTab> journalLastTabProvider =
    NotifierProvider<JournalTabNotifier, JournalTab>(JournalTabNotifier.new);
