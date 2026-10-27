/// Environment / build-time configuration.
///
/// Everything here is a compile-time or process-level constant; nothing in this
/// file reads from disk or the network.
class AppEnv {
  const AppEnv._();

  /// The GOAL API. Overridable for staging with `--dart-define=MARMA_API_BASE=...`.
  static const String baseUrl = String.fromEnvironment(
    'MARMA_API_BASE',
    defaultValue: 'https://api.goal-api.com/v1',
  );

  /// GOAL API key, sent as `Authorization: Bearer` by the SDK. Override per
  /// build with `--dart-define=MARMA_API_KEY=...`.
  ///
  /// SECURITY — KNOWN, NOT FIXED: this key ships inside the app binary, so it
  /// is effectively public; anyone can extract it and spend the plan's quota.
  /// The real fix is a small proxy the app calls instead of GOAL directly.
  static const String apiKey = String.fromEnvironment(
    'MARMA_API_KEY',
    defaultValue: 'gapi_7ff9918497fad69969d1c27422a49d4cf8b035703c2d283d80273b22e76abdff',
  );

  /// Bump to invalidate every on-disk cache file. Sibling `marma_cache_v*`
  /// directories with a different version are deleted on launch.
  /// 2: GOAL API (string ids, logos). v1 caches are API-Football shaped.
  static const int cacheSchemaVersion = 2;

  static const String cacheDirPrefix = 'marma_cache_v';

  static const String cacheDirName = '$cacheDirPrefix$cacheSchemaVersion';

  /// The pre-rename cache directory prefix. An install that predates the
  /// Terrace → Marma rename still has a `terrace_cache_v*` directory in
  /// Application Support; it is deleted on the next launch so the old blobs are
  /// never orphaned. Nothing is migrated — the cache is a pure derivative of
  /// the API and refills itself on the first fetch.
  static const String legacyCacheDirPrefix = 'terrace_cache_v';

  /// `shared_preferences` schema version (see `prefs_schema_version`).
  /// 2: GOAL API. Favourites saved as API-Football integer ids match nothing
  /// any more, so the bump drops them (see `PrefsStore.migrate`).
  static const int prefsSchemaVersion = 2;

  /// The splash shows the brand for at least this long, even when everything
  /// is already cached.
  static const Duration splashMinHold = Duration(milliseconds: 1200);

  /// The longest the splash waits for today's matches before opening anyway.
  /// (The remote config is still required; it is never skipped.)
  static const Duration splashHold = Duration(seconds: 5);

  /// `/live` poll interval (foreground only).
  /// One GOAL request per tick while a live surface is open; at 60 s that is
  /// at most 60 an hour against a 1000/day budget.
  static const Duration livePollInterval = Duration(seconds: 60);

  /// The single app-wide clock tick used by the freshness chip and day rollover.
  static const Duration tickInterval = Duration(seconds: 30);

  static const String supportEmail = 'henryliam2213@icloud.com';
  static const String privacyUrl = 'https://sites.google.com/view/koorapleus/accueil';
  static const String termsUrl = 'https://sites.google.com/view/khgkhkjh/terms';
  static const String supportUrl = 'https://sites.google.com/view/koraplues-super/accueil';

  /// Dev-only screenshot seam. When set, the router starts at this location and
  /// treats the splash gate as already satisfied.
  ///
  /// It is `''` in every real build — there is no way to reach it without
  /// passing `--dart-define=MARMA_DEV_ROUTE=...` at compile time. It exists
  /// because the simulator offers no scripted tap API, so QA screenshots of the
  /// inner routes cannot otherwise be captured.
  static const String devRoute = String.fromEnvironment('MARMA_DEV_ROUTE');
  static bool get hasDevRoute => devRoute.isNotEmpty;

  /// Dev-only companion to [devRoute]: a RAW country name to open on the live
  /// atlas at launch.
  ///
  /// Same justification and same safety property as [devRoute] — `''` in every
  /// real build, unreachable without `--dart-define` at compile time. It exists
  /// because `simctl` has no scripted-tap API and this machine has no
  /// accessibility permission for `osascript`, so an expanded country block
  /// cannot otherwise be photographed on a device.
  static const String devExpandCountry =
      String.fromEnvironment('MARMA_DEV_EXPAND_COUNTRY');

  /// Dev-only: disables the iPad content clamp (`ContentWidth`) so the
  /// before/after of QA defect M1 can be photographed on the SAME screen with
  /// the SAME data, rather than compared against an older capture.
  ///
  /// `false` in every real build; a compile-time constant, so the branch it
  /// guards is tree-shaken out of release.
  static const bool devNoClamp = bool.fromEnvironment('MARMA_DEV_NO_CLAMP');

  /// Dev-only: the journal's initial scroll offset, in logical pixels.
  ///
  /// Same justification and same safety property as [devRoute] — `0` in every
  /// real build, unreachable without a `--dart-define` at compile time. The
  /// journal is one long page and `simctl` has no scripted-scroll API, so the
  /// sections below the fold cannot otherwise be photographed on a device, and
  /// "compiles clean" has already been shown here not to mean "renders clean".
  static const int devJournalScroll = int.fromEnvironment('MARMA_DEV_JOURNAL_SCROLL');

  /// Dev-only screenshot seam: the journal tab (0–3) a started journal opens
  /// on. Unset (−1) in every real build.
  static const int devJournalTab = int.fromEnvironment('MARMA_DEV_JOURNAL_TAB', defaultValue: -1);

  /// Dev-only verification logging switch — see `core/utils/dev_log.dart`.
  ///
  /// `false` in every real build; only a `--dart-define=MARMA_DEV_VERIFY=true`
  /// turns it on, and the sites that use it are `debugPrint`, which is itself a
  /// no-op in release.
  static const bool devVerify = bool.fromEnvironment('MARMA_DEV_VERIFY');

  /// True inside a headless widget/unit test.
  ///
  /// Two sources: a `--dart-define` for integration runs, and a mutable static
  /// flipped by the test harness (`AppEnv.forceTestMode = true`) so that
  /// repeating animations and the 5 s splash hold never leave a pending timer.
  static const bool _defineIsTest = bool.fromEnvironment('MARMA_TEST');
  static bool forceTestMode = false;
  static bool get isTest => _defineIsTest || forceTestMode;
}
