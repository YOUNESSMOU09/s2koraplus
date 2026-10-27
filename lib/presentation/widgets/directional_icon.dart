import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// Directional glyphs for a bidirectional UI.
///
/// These return the **LTR-natural** glyph and let Flutter do the mirroring.
/// `Symbols.chevron_left_rounded` / `chevron_right_rounded` are both declared
/// with `matchTextDirection: true`, so `Icon` already wraps them in a
/// horizontal flip when `Directionality.of(context) == rtl`.
///
/// Choosing the opposite glyph here as well produced a DOUBLE mirror: the
/// Arabic atlas rendered a right-pointing chevron on a right-to-left row,
/// which is what a collapsed row looks like in English. Caught by looking at
/// an `ar` render on the simulator — the widget test that only compared
/// `IconData` values could not see it, because both spellings are "correct"
/// until the font's own mirroring is taken into account.
///
/// Never hard-code a chevron for "back" or "disclosure"; go through here so
/// the reasoning above stays attached to the decision.
class DirectionalIcon {
  const DirectionalIcon._();

  /// Points towards the start edge in LTR, and is mirrored to point towards
  /// the start edge in RTL.
  static IconData back(BuildContext context) => MarmaIcons.caretStart;

  /// Points towards the end edge in LTR, and is mirrored to point towards the
  /// end edge in RTL.
  static IconData disclosure(BuildContext context) => MarmaIcons.caretEnd;
}
