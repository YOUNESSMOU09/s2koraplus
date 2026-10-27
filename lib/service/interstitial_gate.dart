import 'package:marma/app/app_env.dart';
import 'package:marma/const.dart';
import 'package:marma/core/utils/dev_log.dart';
import 'package:marma/service/ad_policy.dart';
import 'package:marma/service/ads_bootstrap.dart';

/// Every button in the app that navigates or completes something calls this,
/// and every one of them shows an interstitial when the SDK has one loaded.
///
/// Widgets never reach the ad SDK themselves, so there is exactly one place
/// this behaviour lives.
class InterstitialGate {
  const InterstitialGate._();

  /// A qualifying user action just happened. Never throws, never blocks: the
  /// caller performs its navigation regardless of what happens here.
  static void onAction(String placement) {
    if (!AdPolicy.shouldShowInterstitial()) return;
    try {
      gAds.interInstance.showInterstitialAd();
      // Suppresses the App Open ad that would otherwise fire when the OS hands
      // focus back as this one is dismissed.
      isInterShowed = true;
      devLog('ads', 'interstitial shown at "$placement"');
    } on Object catch (error) {
      devLog('ads', 'interstitial failed at "$placement": $error');
    }
  }
}

/// The rewarded ad — opt-in, and it pays.
///
/// Rewarded ads cannot be attached to arbitrary buttons: AdMob requires the
/// user to choose to watch and to receive something for it. Here that is a
/// window with no interstitials at all.
class RewardedGate {
  const RewardedGate._();

  /// True when a rewarded ad can be offered: the remote config allows it, the
  /// SDK is up, and there is not already an ad-free window running.
  static bool get isAvailable =>
      !AppEnv.isTest && AdsBootstrap.isReady && AdPolicy.rewardsAllowed;

  /// Shows the rewarded ad. [onRewarded] runs only if the user actually earns
  /// it — it is the SDK's own reward callback, not ours.
  static void show({required void Function() onRewarded}) {
    if (!isAvailable) {
      devLog('ads', 'rewarded unavailable: config or SDK not ready');
      return;
    }
    try {
      gAds.rewardInstance.showRewardAd(() {
        devLog('ads', 'rewarded earned');
        onRewarded();
      });
    } on Object catch (error) {
      devLog('ads', 'rewarded failed: $error');
    }
  }
}
