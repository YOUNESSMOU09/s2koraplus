import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marma/app/marma_app.dart';
import 'package:marma/data/local/bucket_cache.dart';
import 'package:marma/data/local/prefs_store.dart';
import 'package:marma/presentation/providers/infra_providers.dart';
import 'package:marma/service/ad_policy.dart';
import 'package:marma/service/app_lifecycle_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts are BUNDLED under assets/google_fonts/ — never fetched at runtime.
  // Offline-first, and no runtime licence or privacy surface.
  GoogleFonts.config.allowRuntimeFetching = false;

  await initializeDateFormatting('en');
  await initializeDateFormatting('ar');

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Directory supportDir = await getApplicationSupportDirectory();

  final PrefsStore prefsStore = PrefsStore(prefs);
  await prefsStore.migrate();

  // A rewarded view buys an ad-free window; it must survive a relaunch, so the
  // policy is seeded from disk before any screen can ask it a question.
  AdPolicy.adFreeUntil = prefsStore.readAdFreeUntil();

  final BucketCache cache = BucketCache(supportDir);
  await cache.prepare();

  // Shows the App Open ad when the user returns from background. Its lifetime
  // is the app's, so it is never removed. It no-ops until the remote ad config
  // has landed (`AdsBootstrap.isReady`).
  AppLifecycleObserver().initialize();

  runApp(
    ProviderScope(
      overrides: <Override>[
        prefsProvider.overrideWithValue(prefs),
        cacheDirProvider.overrideWithValue(supportDir),
      ],
      child: const MarmaApp(),
    ),
  );
}
