import 'dart:ui';

import 'package:marma/ads/src/multi_ads_factory.dart';

class Constants {
  /// The remote ad/config document.
  ///
  /// Overridable at compile time with `--dart-define=MARMA_CONFIG_URL=...` so a
  /// staging or local document can be pointed at without editing source. Every
  /// real build uses the default.
  static const String jsonConfigUrl = String.fromEnvironment(
    'MARMA_CONFIG_URL',
    defaultValue:
        'https://drive.google.com/uc?export=download&id=1rPDOpgqTZYzgB87HhxXlgH4LPc9IqoyP',
  );

  static Color mainColor = const Color(0xff33FD24);
}

late Map<String, dynamic> configApp;
late MultiAds gAds;
late bool isInterShowed;
