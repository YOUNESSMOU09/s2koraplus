import 'package:flutter/material.dart';
import 'package:marma/const.dart';
import 'package:marma/service/ads_bootstrap.dart';

/// Shows the App Open ad when the user comes BACK to the app.
///
/// The first open ad of a cold start is not this class's job — see
/// `AppOpenAdGate`, which fires once the user reaches content.
class AppLifecycleObserver with WidgetsBindingObserver {
  bool _wasInBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _wasInBackground = true;
    }
    if (state == AppLifecycleState.resumed && _wasInBackground) {
      _wasInBackground = false;
      // `gAds` is a `late` global: a launch whose remote config never landed
      // has none, and reading it here would crash on the first resume.
      if (!AdsBootstrap.isReady) return;
      if (!isInterShowed) {
        gAds.openAdsInstance.showAdIfAvailableOpenAds();
      }
      isInterShowed = false;
    }
  }

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
