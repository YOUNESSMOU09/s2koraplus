import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/core/utils/country_flag.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/services/live_atlas.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/live_atlas_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/directional_icon.dart';
import 'package:marma/presentation/widgets/match_row.dart';
import 'package:marma/presentation/widgets/motion_size.dart';

/// One country's live football, collapsed to a single row until tapped.
///
/// FLATNESS IS THE POINT: England's row and Norway's row are byte-identical in
/// treatment. The only difference between them is the number. No highlight, no
/// ordering privilege, no tier, no priority-league boost.
class CountryBlock extends ConsumerWidget {
  const CountryBlock({
    required this.group,
    required this.forceExpanded,
    this.rewardedOnOpen = false,
    super.key,
  });

  final CountryLiveGroup group;

  /// Passed straight to `MatchRow` — see its doc.
  final bool rewardedOnOpen;

  /// A lone collapsed row is a pointless tap, so a single-country snapshot
  /// opens itself.
  final bool forceExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final bool expanded = forceExpanded ||
        ref.watch(atlasExpansionProvider).contains(group.rawCountry);
    final bool motionOn = AppMotion.enabled(context) &&
        !MediaQuery.of(context).accessibleNavigation;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: colors.card(hairline: context.hairline),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CountryRow(
            group: group,
            expanded: expanded,
            motionOn: motionOn,
            onTap: forceExpanded
                ? null
                : () => ref
                    .read(atlasExpansionProvider.notifier)
                    .toggle(group.rawCountry),
          ),
          MotionSize(
            enabled: motionOn,
            child: expanded
                ? _Expansion(group: group, rewardedOnOpen: rewardedOnOpen)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.group,
    required this.expanded,
    required this.motionOn,
    required this.onTap,
  });

  final CountryLiveGroup group;
  final bool expanded;
  final bool motionOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String name = group.isInternational
        ? context.l10n.atlasInternational
        : localisedCountryName(group.rawCountry, context.languageCode);

    return Semantics(
      button: true,
      expanded: expanded,
      // Without this the flag emoji is announced as
      // "earth globe europe-africa" before the country's own name.
      excludeSemantics: true,
      label: context.l10n.semanticsCountryRow(
        name,
        context.l10n.atlasMatches(group.matchCount),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.surfaceHighest,
          splashFactory: NoSplash.splashFactory,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.lg, end: AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Text(
                  // Unicode emoji, supplied by the OS. No asset, no SVG, no
                  // federation mark, no network request.
                  countryFlagEmoji(group.rawCountry),
                  style: const TextStyle(fontSize: 20),
                  textScaler: TextScaler.noScaling,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    // Isolating an already-RTL run is a no-op for rendering and
                    // removes the need to branch on whether the name resolved
                    // to Arabic or fell back to the English form.
                    bidiIsolate(name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.titleMedium
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 24),
                  child: Text(
                    '${group.matchCount}',
                    textAlign: TextAlign.end,
                    // A bare numeral at the end of an RTL row: a neutral
                    // neighbour would otherwise reorder it.
                    textDirection: TextDirection.ltr,
                    style: context.type.mono.copyWith(color: colors.textSecondary),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: motionOn ? AppMotion.quick : Duration.zero,
                  curve: AppMotion.emphasis,
                  child: Icon(
                    DirectionalIcon.disclosure(context),
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Expansion extends StatelessWidget {
  const _Expansion({required this.group, required this.rewardedOnOpen});

  final CountryLiveGroup group;
  final bool rewardedOnOpen;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(height: 1, thickness: 1, color: colors.outline),
        for (final CompetitionGroup competition in group.competitions) ...<Widget>[
          _CompetitionLabel(league: competition),
          for (int i = 0; i < competition.fixtures.length; i++) ...<Widget>[
            if (i > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
                child: Divider(height: 1, thickness: 1, color: colors.outline),
              ),
            MatchRow(
              key: ValueKey<String>(competition.fixtures[i].id),
              fixtureId: competition.fixtures[i].id,
              fallback: competition.fixtures[i],
              rewardedOnOpen: rewardedOnOpen,
            ),
          ],
        ],
      ],
    );
  }
}

/// Deliberately NOT `CompetitionSectionHeader`: that widget carries the flag,
/// the country and the follow star, all of which are redundant or wrong inside
/// a country block. Following a competition stays available via long-press on
/// any row.
class _CompetitionLabel extends StatelessWidget {
  const _CompetitionLabel({required this.league});

  final CompetitionGroup league;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String? round = league.league.round;
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs),
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              bidiIsolate(league.league.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.label.copyWith(color: colors.textSecondary),
            ),
          ),
          if (round != null && round.isNotEmpty) ...<Widget>[
            const SizedBox(width: AppSpacing.xs + 2),
            Text('·', style: context.type.label.copyWith(color: colors.textTertiary)),
            const SizedBox(width: AppSpacing.xs + 2),
            Flexible(
              child: Text(
                bidiIsolate(round),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.label.copyWith(color: colors.textTertiary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
