import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/app/app_env.dart';

/// The ONLY clock in the app. Freshness chips, the live pulse and day-rollover
/// detection all hang off this one 30 s stream instead of each starting a timer.
final StreamProvider<int> tickerProvider = StreamProvider<int>((Ref ref) {
  if (AppEnv.isTest) return const Stream<int>.empty();
  final StreamController<int> controller = StreamController<int>();
  int tick = 0;
  final Timer timer = Timer.periodic(AppEnv.tickInterval, (_) {
    if (!controller.isClosed) controller.add(++tick);
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Online/offline. Defaults to `true` while unknown so a first launch shows a
/// loading state rather than a wrong "you're offline".
final StreamProvider<bool> connectivityProvider = StreamProvider<bool>((Ref ref) {
  if (AppEnv.isTest) return Stream<bool>.value(true);
  final Connectivity connectivity = Connectivity();
  bool online(List<ConnectivityResult> results) =>
      results.isNotEmpty && !results.every((ConnectivityResult r) => r == ConnectivityResult.none);
  return connectivity.onConnectivityChanged.map(online).asBroadcastStream();
});

final Provider<bool> isOnlineProvider = Provider<bool>(
  (Ref ref) => ref.watch(connectivityProvider).maybeWhen(
        data: (bool online) => online,
        orElse: () => true,
      ),
);

/// One `AppLifecycleListener` for the whole app; the live poller listens to
/// this rather than registering its own observer.
class AppLifecycleNotifier extends Notifier<AppLifecycleState> {
  AppLifecycleListener? _listener;
  bool _disposed = false;

  @override
  AppLifecycleState build() {
    // Same reuse rule as the fixture notifiers: clear the latch on every build.
    _disposed = false;
    if (!AppEnv.isTest) {
      _listener = AppLifecycleListener(
        onStateChange: (AppLifecycleState next) {
          if (_disposed) return;
          state = next;
        },
      );
      ref.onDispose(() {
        _disposed = true;
        _listener?.dispose();
        _listener = null;
      });
    }
    return WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }
}

final NotifierProvider<AppLifecycleNotifier, AppLifecycleState> appLifecycleProvider =
    NotifierProvider<AppLifecycleNotifier, AppLifecycleState>(AppLifecycleNotifier.new);

final Provider<bool> isForegroundProvider = Provider<bool>(
  (Ref ref) => ref.watch(appLifecycleProvider) == AppLifecycleState.resumed,
);

/// The bottom-nav branch indexes, named once.
///
/// `StatefulShellRoute.indexedStack` identifies a branch by POSITION, and the
/// live poller keys off that position. Inserting Journal ahead of Settings
/// silently renumbered it, which is exactly the kind of change a magic `3`
/// survives and a name does not.
class ShellBranch {
  const ShellBranch._();

  static const int matches = 0;
  static const int live = 1;
  static const int following = 2;
  static const int journal = 3;
  static const int settings = 4;

  static const int count = 5;

  /// The branches whose content is live: `/live` is polled only on these.
  static const Set<int> polling = <int>{live, following};
}

/// Which bottom-nav branch is showing. Drives the live poller: `/live` is only
/// polled while the Live or Following branch is on screen.
final NotifierProvider<ShellBranchNotifier, int> shellBranchProvider =
    NotifierProvider<ShellBranchNotifier, int>(ShellBranchNotifier.new);

class ShellBranchNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}
