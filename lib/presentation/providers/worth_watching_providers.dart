import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/core/utils/dev_log.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/services/worth_watching.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';

/// Surface A's state. No `Timer`, no `StreamSubscription`, no
/// `AppLifecycleListener` anywhere in this file — see [WorthWatchingNotifier].

enum WorthWatchingMode {
  /// Nothing to say: quiet hours, or too few live matches to be worth a note.
  hidden,

  /// One to three ranked rows.
  rows,

  /// Live matches exist, none of them is tight.
  noneTight,

  /// The snapshot is too old for a present-tense claim.
  paused,
}

class WorthWatchingState {
  const WorthWatchingState({
    required this.mode,
    required this.rows,
    required this.commitVersion,
  });

  final WorthWatchingMode mode;

  /// Already trimmed to at most three. NEVER padded to reach three.
  final List<WorthWatchingEntry> rows;

  /// Increments on every committed reorder — the `AnimatedSwitcher` key.
  final int commitVersion;

  static const WorthWatchingState empty = WorthWatchingState(
    mode: WorthWatchingMode.hidden,
    rows: <WorthWatchingEntry>[],
    commitVersion: 0,
  );
}

/// Pure derivation from the existing `/live` poll. There is no second poller
/// and no new endpoint: both new surfaces read `liveFeedProvider` and nothing
/// else, so `LivePoller` is byte-unchanged and its foreground/branch rules
/// already cover them.
final AutoDisposeProvider<List<WorthWatchingEntry>> worthWatchingCandidatesProvider =
    Provider.autoDispose<List<WorthWatchingEntry>>((Ref ref) {
  final LiveSnapshot? snapshot = ref.watch(liveFeedProvider).valueOrNull;
  if (snapshot == null) return const <WorthWatchingEntry>[];
  final List<WorthWatchingEntry> ranked = rankLiveMatches(snapshot);
  devLog(
    'VERIFY-WW',
    'fetchedAt=${snapshot.fetchedAt.toIso8601String()} live=${snapshot.count} '
    'ranked=${ranked.map((WorthWatchingEntry e) => '${e.fixtureId}@${e.minute}\'/${e.reason.name}').join(' > ')}',
  );
  return ranked;
});

/// Injectable clock, in milliseconds since epoch.
///
/// The anti-mis-tap freeze (§11.2) is a TIMESTAMP COMPARISON evaluated when a
/// snapshot arrives — never a `Timer`. Overriding this in a test is how the
/// 3 s window is exercised without a real wait and without a pending timer at
/// teardown.
final AutoDisposeProvider<int Function()> worthWatchingClockProvider =
    Provider.autoDispose<int Function()>(
        (Ref ref) => () => DateTime.now().millisecondsSinceEpoch);

/// The committed view of surface A.
///
/// Reordering under a moving thumb causes mis-taps into the wrong match, so
/// membership and order commit only when the user is not interacting. Scores,
/// minutes and reason lines are NEVER frozen — they come from
/// `resolvedFixtureProvider` and the current snapshot on every poll.
class WorthWatchingNotifier extends AutoDisposeNotifier<WorthWatchingState> {
  /// ~3 s of quiet after the last touch before a reorder is allowed.
  static const int kFreezeWindowMs = 3000;

  /// After three deferred snapshots (~90 s of continuous interaction) the
  /// reorder is forced, so the list cannot freeze indefinitely.
  static const int kMaxDeferrals = 3;

  /// A snapshot older than this cannot support a present-tense claim.
  static const int kStaleMinutes = 10;

  /// Below this many live matches, "nothing tight" is not worth saying.
  static const int kMinLiveForNote = 4;

  int _lastTouchMs = 0;
  int _deferredCount = 0;
  int _commitVersion = 0;
  List<String> _committedIds = const <String>[];

  @override
  WorthWatchingState build() {
    // A `Notifier` instance is REUSED across recomputes while the previous
    // build's `onDispose` still fires (this is the exact shape that once
    // latched `LivePoller` off for the life of the process). Nothing here is
    // latched: every field below is either monotonic or recomputed, and no
    // disposal flag gates the work.
    final List<WorthWatchingEntry> candidates =
        ref.watch(worthWatchingCandidatesProvider);
    final int liveCount = ref.watch(liveCountProvider);
    final Freshness freshness = ref.watch(liveFreshnessProvider);
    final int Function() clock = ref.watch(worthWatchingClockProvider);

    final WorthWatchingMode mode = _resolveMode(
      liveCount: liveCount,
      freshness: freshness,
      hasCandidates: candidates.isNotEmpty,
    );

    if (mode != WorthWatchingMode.rows) {
      _committedIds = const <String>[];
      return WorthWatchingState(
        mode: mode,
        rows: const <WorthWatchingEntry>[],
        commitVersion: _commitVersion,
      );
    }

    final Map<String, WorthWatchingEntry> byId = <String, WorthWatchingEntry>{
      for (final WorthWatchingEntry e in candidates) e.fixtureId: e,
    };
    final List<WorthWatchingEntry> next =
        candidates.take(3).toList(growable: false);
    final List<String> nextIds =
        next.map((WorthWatchingEntry e) => e.fixtureId).toList(growable: false);

    // REMOVAL IS NEVER DEFERRED. A fixture that stops being eligible (full
    // time, half time, suspended, `elapsed` goes null) is dropped immediately:
    // leaving a finished match in "worth watching NOW" is a correctness bug,
    // and its row would navigate to a finished match.
    final List<WorthWatchingEntry> survivors = <WorthWatchingEntry>[
      for (final String id in _committedIds)
        if (byId.containsKey(id)) byId[id]!,
    ];

    final bool allowed = _lastTouchMs == 0 ||
        clock() - _lastTouchMs > kFreezeWindowMs ||
        _deferredCount >= kMaxDeferrals;

    if (allowed) {
      if (!_sameOrder(_committedIds, nextIds)) _commitVersion++;
      _committedIds = nextIds;
      _deferredCount = 0;
      return WorthWatchingState(
        mode: mode,
        rows: next,
        commitVersion: _commitVersion,
      );
    }

    // Not allowed: keep the surviving rows in their committed order with
    // FRESH content, stash the new order, and promote nothing under the thumb.
    // It defers to the next snapshot, not to a timer.
    final List<String> survivingIds =
        survivors.map((WorthWatchingEntry e) => e.fixtureId).toList(growable: false);
    if (!_sameOrder(survivingIds, nextIds)) _deferredCount++;
    _committedIds = survivingIds;
    return WorthWatchingState(
      mode: mode,
      rows: survivors,
      commitVersion: _commitVersion,
    );
  }

  /// Called from the Live screen's scroll notification listener and from a
  /// pointer-down listener around the module.
  void touch() =>
      _lastTouchMs = ref.read(worthWatchingClockProvider)();

  WorthWatchingMode _resolveMode({
    required int liveCount,
    required Freshness freshness,
    required bool hasCandidates,
  }) {
    // A brand decision, not a technical one: "worth watching NOW" is a
    // present-tense claim, and making it from a 20-minute-old snapshot is a
    // lie. The freshness chip beside it already says why.
    if (freshness.level == FreshnessLevel.offline ||
        freshness.minutesAgo >= kStaleMinutes) {
      return WorthWatchingMode.paused;
    }
    if (liveCount == 0) return WorthWatchingMode.hidden;
    if (hasCandidates) return WorthWatchingMode.rows;
    if (liveCount >= kMinLiveForNote) return WorthWatchingMode.noneTight;
    return WorthWatchingMode.hidden;
  }

  static bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

final AutoDisposeNotifierProvider<WorthWatchingNotifier, WorthWatchingState>
    worthWatchingProvider =
    NotifierProvider.autoDispose<WorthWatchingNotifier, WorthWatchingState>(
        WorthWatchingNotifier.new);
