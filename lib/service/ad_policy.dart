import 'package:marma/app/app_env.dart';
import 'package:marma/const.dart';
import 'package:marma/service/ads_bootstrap.dart';

/// When a full-screen ad is allowed to show.
///
/// There is NO frequency limit: every qualifying action shows an ad. No
/// cadence, no cooldown, no cold-start grace — if the SDK has one loaded, it
/// shows.
class AdPolicy {
  const AdPolicy._();

  /// What a rewarded view buys.
  static const Duration adFreeReward = Duration(minutes: 30);

  /// Set from the ad-free window persisted in prefs (a rewarded view), so it
  /// survives a relaunch.
  static DateTime? adFreeUntil;

  static bool get isAdFree =>
      adFreeUntil != null && DateTime.now().isBefore(adFreeUntil!);

  static Duration get adFreeRemaining {
    final DateTime? until = adFreeUntil;
    if (until == null) return Duration.zero;
    final Duration left = until.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  /// Whether the remote config offers rewarded ads at all. The document's own
  /// `config.allowReward` flag is the switch — the app never overrides it.
  static bool get rewardsAllowed {
    if (!AdsBootstrap.isReady) return false;
    final Object? allow = configApp['allowReward'];
    return allow is bool ? allow : false;
  }

  /// Called for every qualifying button press. True unless the SDK is not up,
  /// a rewarded ad-free window is running, or this is a test.
  static bool shouldShowInterstitial() {
    if (AppEnv.isTest || !AdsBootstrap.isReady || isAdFree) return false;
    return true;
  }

  /// Test seam.
  static void resetForTest() => adFreeUntil = null;
}
