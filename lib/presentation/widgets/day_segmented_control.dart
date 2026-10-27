import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// Yesterday / Today / Tomorrow, each labelled with the bucket's own server
/// date — so a user in UTC+13 is never confused about which "today" this is.
class DaySegmentedControl extends StatelessWidget {
  const DaySegmentedControl({
    required this.selected,
    required this.serverDates,
    required this.onChanged,
    super.key,
  });

  final DayKey selected;
  final Map<DayKey, String> serverDates;
  final ValueChanged<DayKey> onChanged;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.chipRadius,
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: <Widget>[
          for (final DayKey day in DayKey.values)
            Expanded(
              child: _Segment(
                label: switch (day) {
                  DayKey.yesterday => context.l10n.dayYesterday,
                  DayKey.today => context.l10n.dayToday,
                  DayKey.tomorrow => context.l10n.dayTomorrow,
                },
                date: serverDates[day] ?? '',
                selected: day == selected,
                onTap: () => onChanged(day),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $date',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.accentFill : Colors.transparent,
            borderRadius: AppRadius.chipRadius,
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: colors.accentFill.withValues(alpha: 0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.noScaling,
                style: context.type.label.copyWith(
                  color: selected ? colors.onAccent : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (date.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: TextScaler.noScaling,
                  style: context.type.monoSmall.copyWith(
                    color: selected
                        ? colors.onAccent.withValues(alpha: 0.8)
                        : colors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
