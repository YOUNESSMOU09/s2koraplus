import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/failures.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/data/repositories/fixture_repository_impl.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/repositories/repositories.dart';
import 'package:marma/presentation/providers/app_providers.dart';
import 'package:marma/presentation/providers/infra_providers.dart';

/// One notifier per day. Cache-then-network: the persisted bucket is painted
/// immediately and revalidated in the background, so a cold start never shows a
/// spinner when there is anything on disk (C4).
class DayBucketNotifier extends FamilyAsyncNotifier<DayBucket, DayKey> {
  bool _disposed = false;
  bool _inFlight = false;

  @override
  Future<DayBucket> build(DayKey arg) async {
    // A `Notifier` instance is REUSED across recomputes and `ref.onDispose`
    // fires on every recompute, not just on final disposal — so both latches
    // must be cleared here or the notifier silently stops working after the
    // first rebuild.
    _disposed = false;
    _inFlight = false;
    ref.onDispose(() => _disposed = true);
    final FixtureRepository repo = ref.watch(fixtureRepositoryProvider);

    final DayBucket? cached = await repo.readCachedDay(arg);
    if (cached != null) {
      if (FixtureRepositoryImpl.isStale(cached, arg)) {
        // Fire-and-forget revalidation; the cached bucket paints now.
        unawaited(Future<void>.microtask(revalidateIfStale));
      }
      return cached;
    }
    return _guarded(() => repo.refreshDay(arg));
  }

  /// Pull-to-refresh / tap-the-chip. Always bypasses the staleness window.
  Future<void> refresh() async {
    if (_disposed || _inFlight) return;
    _inFlight = true;
    final DayBucket? previous = state.valueOrNull;
    final AsyncValue<DayBucket> next = await AsyncValue.guard<DayBucket>(
      () => _guarded(() =>
          ref.read(fixtureRepositoryProvider).refreshDay(arg, previous: previous)),
    );
    _inFlight = false;
    if (_disposed) return;
    // On failure `copyWithPrevious` keeps the cached data visible while
    // `hasError` lets the surface age its freshness chip.
    state = next.copyWithPrevious(state, isRefresh: false);
  }

  Future<void> revalidateIfStale() async {
    if (_disposed) return;
    final DayBucket? current = state.valueOrNull;
    if (!FixtureRepositoryImpl.isStale(current, arg)) return;
    await refresh();
  }

  Future<T> _guarded<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on Object catch (e) {
      throw asAppFailure(e);
    }
  }
}

final AsyncNotifierProviderFamily<DayBucketNotifier, DayBucket, DayKey>
    dayBucketProvider =
    AsyncNotifierProvider.family<DayBucketNotifier, DayBucket, DayKey>(
        DayBucketNotifier.new);

/// The last `/live` snapshot. A failed poll never clears it — it only ages the
/// freshness chip (§10.3).
class LiveFeedNotifier extends AsyncNotifier<LiveSnapshot> {
  bool _disposed = false;
  bool _inFlight = false;

  @override
  Future<LiveSnapshot> build() async {
    // See DayBucketNotifier.build — the same reuse rule applies.
    _disposed = false;
    _inFlight = false;
    ref.onDispose(() => _disposed = true);
    final FixtureRepository repo = ref.watch(fixtureRepositoryProvider);
    final LiveSnapshot? cached = await repo.readCachedLive();
    if (cached != null) {
      unawaited(Future<void>.microtask(refresh));
      return cached;
    }
    try {
      return await repo.refreshLive();
    } on Object catch (e) {
      throw asAppFailure(e);
    }
  }

  Future<void> refresh() async {
    if (_disposed || _inFlight) return;
    _inFlight = true;
    final LiveSnapshot? previous = state.valueOrNull;
    final AsyncValue<LiveSnapshot> next = await AsyncValue.guard<LiveSnapshot>(
      () async {
        try {
          return await ref
              .read(fixtureRepositoryProvider)
              .refreshLive(previous: previous);
        } on Object catch (e) {
          throw asAppFailure(e);
        }
      },
    );
    _inFlight = false;
    if (_disposed) return;
    state = next.copyWithPrevious(state, isRefresh: false);
  }
}

final AsyncNotifierProvider<LiveFeedNotifier, LiveSnapshot> liveFeedProvider =
    AsyncNotifierProvider<LiveFeedNotifier, LiveSnapshot>(LiveFeedNotifier.new);

class LivePollState {
  const LivePollState({required this.running, required this.lastPollAt});
  final bool running;
  final DateTime? lastPollAt;
}

/// The 30 s `/live` timer.
///
/// R9 — a pending `Timer` firing after teardown crashed a previous studio app.
/// Mitigations, all of them mandatory:
///   * the timer only runs while the app is FOREGROUND **and** the Live or
///     Following branch is on screen;
///   * `ref.onDispose` cancels it in the same block that creates it;
///   * every async continuation checks `_disposed` before touching `ref`;
///   * it never starts at all under a headless test.
class LivePoller extends Notifier<LivePollState> {
  Timer? _timer;
  bool _disposed = false;

  @override
  LivePollState build() {
    // CRITICAL (R9 + regression): this notifier is recomputed whenever the
    // foreground flag or the shell branch changes, and Riverpod reuses the SAME
    // instance while still firing the previous build's `onDispose`. Without
    // clearing the latch here, `_disposed` stays true for the rest of the
    // process and every subsequent `_poll()` returns immediately — the Live tab
    // then shows a snapshot that never updates. Covered by
    // test/qa/live_poller_test.dart.
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      _timer = null;
    });

    final bool foreground = ref.watch(isForegroundProvider);
    final int branch = ref.watch(shellBranchProvider);
    final bool wantsPolling = foreground && ShellBranch.polling.contains(branch);

    _timer?.cancel();
    _timer = null;

    if (wantsPolling && !AppEnv.isTest) {
      // An immediate catch-up fetch, then the periodic poll.
      unawaited(Future<void>.microtask(_poll));
      _timer = Timer.periodic(AppEnv.livePollInterval, (_) => _poll());
    }

    return LivePollState(running: wantsPolling, lastPollAt: null);
  }

  Future<void> _poll() async {
    if (_disposed) return;
    await ref.read(liveFeedProvider.notifier).refresh();
    if (_disposed) return;
    state = LivePollState(running: state.running, lastPollAt: DateTime.now());
  }
}

final NotifierProvider<LivePoller, LivePollState> livePollerProvider =
    NotifierProvider<LivePoller, LivePollState>(LivePoller.new);

/// Convenience: the live fixture count, used by the bottom-nav badge.
final Provider<int> liveCountProvider = Provider<int>(
  (Ref ref) => ref.watch(liveFeedProvider).valueOrNull?.count ?? 0,
);

/// `/health`, About screen only.
final FutureProviderFamily<Health, int> healthProvider =
    FutureProvider.family<Health, int>((Ref ref, int nonce) async {
  try {
    return await ref.read(fixtureRepositoryProvider).fetchHealth();
  } on Object catch (e) {
    throw asAppFailure(e);
  }
});
