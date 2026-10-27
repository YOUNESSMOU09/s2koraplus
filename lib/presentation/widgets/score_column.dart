import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// A single score numeral that animates when the value changes.
///
/// The old digit slides up and out, the new one slides in from below. Under
/// Reduce Motion (or in tests) this collapses to an instant swap — the flash
/// and haptic that accompany a goal are retained, because they are not motion.
class AnimatedScoreDigit extends StatelessWidget {
  const AnimatedScoreDigit({
    required this.value,
    required this.style,
    super.key,
  });

  final int? value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final Widget digit = Text(
      AppFormat.goals(value),
      key: ValueKey<String>('score-${value ?? 'null'}'),
      style: style,
      textAlign: TextAlign.end,
      textDirection: TextDirection.ltr,
    );

    if (!AppMotion.enabled(context)) return digit;

    return AnimatedSwitcher(
      duration: AppMotion.base,
      switchInCurve: AppMotion.emphasis,
      switchOutCurve: AppMotion.emphasis,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final bool incoming = child.key == digit.key;
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, incoming ? 0.6 : -0.6),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: digit,
    );
  }
}

/// The row's scoreline pill: home digit · dash · away digit.
///
/// RTL: rendered as separate widgets in a logical row, never as a single
/// `"2 - 1"` string — a combined string is reordered by the bidi algorithm next
/// to Arabic text and displays wrong. The row follows the ambient direction so
/// the home digit always sits beside the home crest.
class RowScoreline extends StatelessWidget {
  const RowScoreline({
    required this.home,
    required this.away,
    this.live = false,
    super.key,
  });

  final int? home;
  final int? away;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color ink = live ? colors.live : colors.textPrimary;
    final TextStyle style = context.type.rowScore.copyWith(color: ink);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: live ? colors.liveSurface : colors.surfaceHighest,
        borderRadius: AppRadius.badgeRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedScoreDigit(value: home, style: style),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs + 1),
            child: Text('-', style: style.copyWith(color: ink.withValues(alpha: 0.5))),
          ),
          AnimatedScoreDigit(value: away, style: style),
        ],
      ),
    );
  }
}
