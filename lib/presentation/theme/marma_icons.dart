import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The app's single icon vocabulary.
///
/// §3.1 named `phosphor_flutter` first with `material_symbols_icons` (Rounded)
/// as the stated fallback "if unavailable". `phosphor_flutter` 2.1.0 — the
/// latest release — does not compile against Flutter 3.44: it extends
/// `IconData`, which is now a `final` class. The fallback is therefore in use,
/// with the Rounded variant throughout to keep the soft, un-clinical feel the
/// brand asks for. Weight/fill are the only variations; never mixed styles.
class MarmaIcons {
  const MarmaIcons._();

  // Navigation
  static const IconData matches = Symbols.sports_soccer_rounded;
  static const IconData live = Symbols.sensors_rounded;
  static const IconData following = Symbols.star_rounded;
  static const IconData settings = Symbols.settings_rounded;

  // Actions
  static const IconData search = Symbols.search_rounded;
  static const IconData retry = Symbols.refresh_rounded;
  static const IconData close = Symbols.close_rounded;
  static const IconData add = Symbols.add_rounded;
  static const IconData check = Symbols.check_rounded;
  static const IconData manage = Symbols.tune_rounded;
  static const IconData selected = Symbols.check_circle_rounded;
  static const IconData unselected = Symbols.circle_rounded;

  // Status
  static const IconData offline = Symbols.wifi_off_rounded;
  static const IconData stale = Symbols.schedule_rounded;
  static const IconData health = Symbols.monitor_heart_rounded;
  static const IconData prohibited = Symbols.block_rounded;

  // Match detail
  static const IconData competition = Symbols.trophy_rounded;
  static const IconData round = Symbols.format_list_numbered_rounded;
  static const IconData kickoff = Symbols.schedule_rounded;
  static const IconData venue = Symbols.location_on_rounded;
  static const IconData referee = Symbols.person_rounded;
  static const IconData season = Symbols.calendar_month_rounded;
  static const IconData substitution = Symbols.swap_horiz_rounded;
  static const IconData goal = Symbols.sports_soccer_rounded;
  static const IconData info = Symbols.info_rounded;

  // Journal
  static const IconData journal = Symbols.edit_note_rounded;

  // Bottom tab bar only — kept separate so the shared icons above (the follow
  // star, the football used for goals and the brand mark) are unaffected.
  static const IconData navMatches = Symbols.scoreboard_rounded;
  static const IconData navLive = Symbols.live_tv_rounded;
  static const IconData navFollowing = Symbols.favorite_rounded;
  static const IconData navJournal = Symbols.stylus_note_rounded;
  static const IconData navSettings = Symbols.tune_rounded;
  static const IconData preview = Symbols.visibility_rounded;

  // Settings
  static const IconData appearance = Symbols.dark_mode_rounded;
  static const IconData language = Symbols.translate_rounded;
  static const IconData privacy = Symbols.shield_rounded;
  static const IconData terms = Symbols.description_rounded;
  static const IconData support = Symbols.support_rounded;
  static const IconData external = Symbols.open_in_new_rounded;
  static const IconData clearCache = Symbols.delete_rounded;
  static const IconData rewardAd = Symbols.play_circle_rounded;
  static const IconData adFree = Symbols.do_not_disturb_on_rounded;

  // Directional — mirror these, never hard-code left/right.
  static const IconData caretStart = Symbols.chevron_left_rounded;
  static const IconData caretEnd = Symbols.chevron_right_rounded;
}
