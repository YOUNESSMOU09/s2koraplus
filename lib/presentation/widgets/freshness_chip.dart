import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// "Updated N min ago" — on every list surface, recomputed on the shared 30 s
/// ticker. Tapping it refreshes. Three designed states: fresh, stale, offline.
class FreshnessChip extends StatelessWidget {
  const FreshnessChip({required this.freshness, required this.onTap, super.key});

  final Freshness freshness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;

    late final String text;
    late final Color foreground;
    Color? background;
    Color? border;
    IconData? icon;

    switch (freshness.level) {
      case FreshnessLevel.fresh:
        text = freshness.minutesAgo < 1
            ? context.l10n.freshUpdatedJustNow
            : context.l10n.freshUpdatedMinutesAgo(freshness.minutesAgo);
        foreground = colors.textTertiary;
      case FreshnessLevel.recent:
        text = context.l10n.freshUpdatedMinutesAgo(freshness.minutesAgo);
        foreground = colors.textTertiary;
      case FreshnessLevel.stale:
        text = context.l10n.freshUpdatedMinutesAgo(freshness.minutesAgo);
        foreground = colors.warning;
        background = colors.warningSurface;
        icon = MarmaIcons.stale;
      case FreshnessLevel.offline:
        text = freshness.checkedAt == null
            ? context.l10n.freshOfflineNoData
            : context.l10n.freshOfflineFrom(freshness.minutesAgo);
        foreground = colors.textSecondary;
        border = colors.outlineStrong;
        icon = MarmaIcons.offline;
      case FreshnessLevel.never:
        text = context.l10n.freshNeverUpdated;
        foreground = colors.textTertiary;
    }

    return Semantics(
      button: true,
      label: '$text. ${context.l10n.semanticsRefresh}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipRadius,
        child: Container(
          height: 24,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: background,
            borderRadius: AppRadius.chipRadius,
            border: border == null ? null : Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 12, color: foreground),
                const SizedBox(width: AppSpacing.xs + 1),
              ],
              Text(text, style: context.type.monoSmall.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
