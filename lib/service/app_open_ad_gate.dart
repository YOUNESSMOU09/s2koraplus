import 'dart:async';

import 'package:marma/app/app_env.dart';
import 'package:marma/const.dart';
import 'package:marma/core/utils/dev_log.dart';
import 'package:marma/service/ads_bootstrap.dart';

/// The App Open ad shown on the way into the app.
///
/// It fires ONCE per cold start, at the moment the user first reaches real
/// content — right after the splash, because the shell that calls it does not
/// exist until the splash gate has lifted.
///
/// Resumes from background are handled separately, by `AppLifecycleObserver`.
class AppOpenAdGate {
  const AppOpenAdGate._();

  /// Gives the shell one frame to paint before the ad covers it, so the user
  /// sees the app they opened rather than an ad over a grey rectangle.
  static const Duration settle = Duration(milliseconds: 400);

  static bool _shown = false;

  /// True once this cold start has had its chance at an open ad — whether or
  /// not one was actually available to show.
  static bool get hasShown => _shown;

  /// Test-only reset; the flag is otherwise a one-way latch for the process.
  static void resetForTest() => _shown = false;

  /// Shows the app-open ad if one is loaded. Safe to call from anywhere, any
  /// number of times: everything after the first call is a no-op.
  static Future<void> showOnce() async {
    if (_shown) return;
    _shown = true;

    if (AppEnv.isTest) return;

    // The globals in `const.dart` are `late`. If the remote config never
    // landed, `gAds` is unset and touching it would throw a
    // LateInitializationError on the user's first screen.
    if (!AdsBootstrap.isReady) {
      devLog('ads', 'open ad skipped: config never landed');
      return;
    }

    await Future<void>.delayed(settle);

    try {
      // `showAdIfAvailableOpenAds` is itself a no-op when nothing is loaded,
      // and re-requests for next time — so a cold start with a slow network
      // costs the user nothing and warms the next launch.
      gAds.openAdsInstance.showAdIfAvailableOpenAds();
      // A full-screen ad the app itself opened must not be followed by a
      // second one when the OS hands focus back on dismissal.
      isInterShowed = true;
      devLog('ads', 'open ad requested at first content');
    } on Object catch (error) {
      devLog('ads', 'open ad failed: $error');
    }
  }
}
