import 'package:flutter/foundation.dart';
import 'package:marma/app/app_env.dart';

/// Dev-only verification logging seam.
///
/// Both new live surfaces are pure derivations of the `/live` poll, so the only
/// way to PROVE on a device that they re-derive on every poll — rather than
/// rendering one stale snapshot forever — is to watch them change across poll
/// cycles. Step 4 of this project shipped with a clean analyzer, green tests and
/// a completely dead `/live` poll; nothing but a time series catches that.
///
/// It is OFF in every real build: [AppEnv.devVerify] is a `bool.fromEnvironment`
/// that defaults to `false`, so this compiles to a dead branch unless someone
/// passes `--dart-define=MARMA_DEV_VERIFY=true`. `debugPrint` is additionally
/// a no-op in release. Nothing here can reach a user.
void devLog(String tag, String message) {
  if (!AppEnv.devVerify) return;
  debugPrint('[$tag] $message');
}
