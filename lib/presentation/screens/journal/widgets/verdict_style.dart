import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/services/reaction_meter.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

String verdictName(BuildContext context, MatchVerdict v) => switch (v) {
      MatchVerdict.classic => context.l10n.journalVerdictClassic,
      MatchVerdict.goodWatch => context.l10n.journalVerdictGoodWatch,
      MatchVerdict.mixed => context.l10n.journalVerdictMixed,
      MatchVerdict.rough => context.l10n.journalVerdictRough,
      MatchVerdict.forgettable => context.l10n.journalVerdictForgettable,
    };

Color verdictColour(MarmaColors colors, MatchVerdict v) => switch (v) {
      MatchVerdict.classic || MatchVerdict.goodWatch => colors.success,
      MatchVerdict.mixed => colors.warning,
      MatchVerdict.rough || MatchVerdict.forgettable => colors.danger,
    };

/// A small tinted pill naming a verdict — the text-only stand-in for the
/// reaction emoji that used to sit on journal cards.
class VerdictPill extends StatelessWidget {
  const VerdictPill({required this.verdict, super.key});

  final MatchVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color tint = verdictColour(colors, verdict);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: colors.isDark ? 0.18 : 0.1),
        borderRadius: AppRadius.chipRadius,
      ),
      child: Text(
        verdictName(context, verdict),
        maxLines: 1,
        style: context.type.label.copyWith(color: tint, fontWeight: FontWeight.w700),
      ),
    );
  }
}
