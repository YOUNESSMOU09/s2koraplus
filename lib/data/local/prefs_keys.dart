/// Every `shared_preferences` key the app uses (§6.2). Declared in one place so
/// a typo cannot silently create a second, empty setting.
class PrefsKeys {
  const PrefsKeys._();

  static const String schemaVersion = 'prefs_schema_version';
  static const String installAt = 'install_at';

  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';

  /// Written by removed features (kickoff reminders, onboarding); kept only
  /// so `PrefsStore.migrate` can delete them from existing installs.
  static const List<String> retiredKeys = <String>[
    'reminders_enabled',
    'reminder_offset_minutes',
    'notif_ledger',
    'has_onboarded',
  ];

  static const String favTeamIds = 'fav_team_ids';
  static const String favTeamsMeta = 'fav_teams_meta';
  static const String favLeagueIds = 'fav_league_ids';
  static const String favLeaguesMeta = 'fav_leagues_meta';

  static const String analyticsOptIn = 'analytics_opt_in';

  /// Epoch millis until which a rewarded view has bought an ad-free window.
  static const String adFreeUntil = 'ad_free_until';

  static String etag(String bucket) => 'etag_$bucket';
  static String fetchedAt(String bucket) => 'fetched_at_$bucket';
  static String checkedAt(String bucket) => 'checked_at_$bucket';
  static String serverDate(String bucket) => 'server_date_$bucket';
}
