import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// The brand mark: the same football tile the splash opens on.
///
/// [soft] is the quiet variant for empty and error states — a tinted disc with
/// a hairline ring — so a "nothing here" screen never shouts. [icon] swaps the
/// football for a state-specific glyph inside the same shape.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 96, this.soft = false, this.icon, super.key});

  final double size;
  final bool soft;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = MarmaColors.of(context);
    final IconData glyph = icon ?? MarmaIcons.matches;

    if (soft) {
      return ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.accent.withValues(alpha: colors.isDark ? 0.14 : 0.08),
            border: Border.all(
              color: colors.accent.withValues(alpha: colors.isDark ? 0.28 : 0.16),
              width: 1.5,
            ),
          ),
          child: Icon(glyph, size: size * 0.46, color: colors.accent),
        ),
      );
    }

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.29),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: <Color>[colors.heroStart, colors.heroEnd],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.heroStart.withValues(alpha: colors.isDark ? 0.2 : 0.3),
              blurRadius: size * 0.25,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: Icon(glyph, size: size * 0.56, color: colors.onHero, fill: 1),
      ),
    );
  }
}
