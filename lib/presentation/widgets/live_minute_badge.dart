import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// `45'` · `45+2'` · `HT` · `ET` · `PEN` · `LIVE`.
///
/// Colour is never the only signal: green **plus** a pulsing dot **plus** the
/// minute text.
class LiveMinuteBadge extends StatelessWidget {
  const LiveMinuteBadge({required this.status, this.compact = false, super.key});

  final MatchStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.sm - 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colors.liveSurface,
        borderRadius: AppRadius.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _PulseDot(color: colors.live),
          const SizedBox(width: AppSpacing.xs + 1),
          // Flexible so `90+4'` at 1.6x Dynamic Type shrinks rather than
          // overflowing the status column.
          Flexible(
            child: Text(
              status.minuteLabel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.fade,
              // Forced LTR: the prime mark in `45'` is a bidi-neutral
              // character and lands on the wrong side of the digits inside an
              // RTL paragraph.
              textDirection: TextDirection.ltr,
              style: context.type.mono.copyWith(color: colors.live),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final Widget dot = Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    // Infinite animations are the specific headless-test hazard — the guard
    // returns a static dot under test and under Reduce Motion.
    if (!AppMotion.enabled(context)) return dot;
    return dot
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.35, duration: AppMotion.pulse, curve: AppMotion.gentle)
        .fadeOut(begin: 1.0, curve: AppMotion.gentle);
  }
}
