import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/services/live_atlas.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// `19 countries · 82 matches`.
///
/// Both numbers are DERIVED, never estimated: `matches` is the loaded snapshot
/// size and `countries` is the number of non-International groups in it. A
/// match count is an observed fact, not a derived rating — which is why the
/// atlas is allowed a number at all and Worth Watching is not.
class AtlasSummaryHeader extends StatelessWidget {
  const AtlasSummaryHeader({
    required this.atlas,
    required this.matchCount,
    required this.freshness,
    super.key,
  });

  final List<CountryLiveGroup> atlas;
  final int matchCount;
  final Freshness freshness;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final int countries = atlasCountryCount(atlas);
    final bool internationalOnly = countries == 0 && atlas.isNotEmpty;

    // "0 countries · 6 matches" is absurd, so an International-only snapshot
    // says what it actually is.
    final String headline = internationalOnly
        ? context.l10n.atlasInternationalOnly
        : context.l10n.atlasSummary(
            context.l10n.atlasCountries(countries),
            context.l10n.atlasMatches(matchCount),
          );

    final bool offline = freshness.level == FreshnessLevel.offline;
    final String? aged = offline
        ? context.l10n.atlasOfflineAsOf(freshness.minutesAgo)
        : (freshness.minutesAgo >= 2
            ? context.l10n.atlasAsOf(freshness.minutesAgo)
            : null);

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        header: true,
        label: aged == null ? headline : '$headline, $aged',
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.type.titleMedium.copyWith(color: colors.textPrimary),
            ),
            if (aged != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                aged,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.monoSmall.copyWith(color: colors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
