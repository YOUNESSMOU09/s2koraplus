import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:marma/app/app_env.dart';
import 'package:marma/core/utils/dev_log.dart';

/// App Tracking Transparency — the iOS-only IDFA consent prompt.
///
/// Requesting it is what lets the ad networks serve PERSONALISED ads; without
/// authorisation they still serve, just contextually and at a lower rate. It is
/// therefore never allowed to block launch: every failure path here is a log
/// line, not an error the caller has to handle.
///
/// The prompt can only be presented once per install — iOS itself refuses a
/// second one — so `notDetermined` is the only status worth acting on.
class AppTrackingService {
  factory AppTrackingService() => _instance;
  AppTrackingService._internal();

  static final AppTrackingService _instance = AppTrackingService._internal();

  /// iOS will not present the prompt until the app is fully active. The splash
  /// gate is already on screen when this runs, but the settle keeps the request
  /// clear of the launch transition, where the system silently drops it.
  static const Duration _settle = Duration(seconds: 2);

  bool _hasRequestedPermission = false;

  /// Requests tracking authorisation if it has never been determined.
  ///
  /// Never throws and never rethrows: a caller can always `await` it and carry
  /// on regardless of the outcome.
  Future<void> initializeTracking() async {
    if (!Platform.isIOS) return;
    if (AppEnv.isTest) return;

    try {
      devLog('att', 'starting initialisation');

      await Future<void>.delayed(_settle);

      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      devLog('att', 'current status: $status');

      if (status != TrackingStatus.notDetermined || _hasRequestedPermission) {
        devLog('att', 'already determined or requested this session: $status');
        return;
      }

      // Set BEFORE the await: a second caller arriving while the system sheet
      // is up must not queue a second request.
      _hasRequestedPermission = true;
      devLog('att', 'requesting tracking permission');
      await AppTrackingTransparency.requestTrackingAuthorization();

      final TrackingStatus resolved =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      devLog('att', 'new status: $resolved');

      if (resolved == TrackingStatus.authorized) {
        final String idfa =
            await AppTrackingTransparency.getAdvertisingIdentifier();
        // Dev-only (`devLog` is gated behind --dart-define and debugPrint is a
        // no-op in release), so the IDFA never reaches a shipped log.
        devLog('att', 'advertising identifier: $idfa');
      }
    } on Object catch (error) {
      devLog('att', 'initialisation failed: $error');
    }
  }
}
