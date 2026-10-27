import 'package:flutter/material.dart';
import 'package:marma/app/app_env.dart';

/// Centres and clamps scrollable content on wide displays (QA defect M1).
///
/// `TARGETED_DEVICE_FAMILY = "1,2"`, so App Review evaluates this app on an
/// iPad. Without a clamp the phone layout simply stretches: a match row leaves
/// two-thirds of its width empty between the team name and the score column,
/// and a full-width button becomes a ~950 pt-wide slab. Neither crashes
/// nor overflows — it just looks unfinished, which is its own kind of failure.
///
/// A width clamp was chosen over a two-column master/detail split because the
/// app's information architecture is a single scrolling scoreboard with a
/// modal detail route; splitting it would fork every list surface and the
/// navigation model with it, for a scoreboard that is read, not worked in.
///
/// On a phone this returns the child UNTOUCHED — no extra `Center`, no extra
/// `ConstrainedBox`, no layout change and no risk to the existing render tree.
class ContentWidth extends StatelessWidget {
  const ContentWidth({required this.child, this.maxWidth = kMaxContentWidth, super.key});

  /// Roughly the width of a large phone plus its gutters: wide enough that a
  /// match row still reads as one line, narrow enough that the eye does not
  /// have to travel from a team name to a score at the far edge of a 13-inch
  /// display.
  static const double kMaxContentWidth = 700;

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (AppEnv.devNoClamp) return child;
    if (MediaQuery.sizeOf(context).width <= maxWidth) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
