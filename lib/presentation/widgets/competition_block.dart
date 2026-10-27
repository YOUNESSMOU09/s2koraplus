import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/follow_star.dart';
import 'package:marma/presentation/widgets/league_crest.dart';
import 'package:marma/presentation/widgets/match_row.dart';

/// The grouped container: `surfaceHigh` fill, 18 radius, 1 px hairline border,
/// a header and its rows separated by hairlines inset from the START edge
/// (RTL-correct — never `EdgeInsets.only(left:)`).
class CompetitionBlock extends ConsumerWidget {
  const CompetitionBlock({
    required this.group,
    this.showFollowAffordance = false,
    this.rewardedOnOpen = false,
    super.key,
  });

  final CompetitionGroup group;
  final bool showFollowAffordance;

  /// Passed straight to `MatchRow` — see its doc.
  final bool rewardedOnOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final bool followed = ref.watch(
      favouritesProvider.select((Favourites f) => f.followsLeague(group.league.id)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: colors.card(hairline: context.hairline),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CompetitionSectionHeader(
            group: group,
            followed: followed,
            onToggleFollow: () => ref
                .read(favouritesProvider.notifier)
                .toggleLeague(
                  FavouriteLeague(
                    id: group.league.id,
                    name: group.league.name,
                    country: group.league.country,
                  ),
                ),
          ),
          for (int i = 0; i < group.fixtures.length; i++) ...<Widget>[
            if (i > 0)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
                child: Divider(height: 1, thickness: 1, color: colors.outline),
              ),
            MatchRow(
              key: ValueKey<String>(group.fixtures[i].id),
              fixtureId: group.fixtures[i].id,
              fallback: group.fixtures[i],
              showFollowAffordance: showFollowAffordance,
              rewardedOnOpen: rewardedOnOpen,
            ),
          ],
        ],
      ),
    );
  }
}

/// Emoji country flag · competition name · country · round · follow star.
class CompetitionSectionHeader extends StatelessWidget {
  const CompetitionSectionHeader({
    required this.group,
    required this.followed,
    required this.onToggleFollow,
    super.key,
  });

  final CompetitionGroup group;
  final bool followed;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String country = localisedCountryName(
      group.league.country,
      context.languageCode,
    );
    final String? round = group.league.round;

    return Container(
      // A MINIMUM, not a fixed height. At 44 the 48 dp follow star was clipped
      // to 43.7 pt, failing both the iOS 44 pt and the Android/§13 48 dp tap
      // target guidelines; a fixed height also cannot grow with Dynamic Type.
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg, end: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: Border(
          bottom: BorderSide(color: colors.outline, width: context.hairline),
        ),
      ),
      child: Row(
        children: <Widget>[
          LeagueCrest(leagueId: group.league.id, country: group.league.country, size: 24),
          const SizedBox(width: AppSpacing.sm + 2),
          // The competition NAME gets first claim on the free space: one loose
          // `Flexible` beside fixed-width siblings, so a short name hugs its
          // content and a long one ellipsises last. (A `Spacer` here would
          // split the row three ways and truncate every name to a third.)
          Expanded(
            child: Row(
              children: <Widget>[
                // The name outranks the country, so it gets the larger flex.
                // With two equal `Flexible`s the row split the free space in
                // half regardless of need, and "AFC Champions League" was
                // ellipsised to "AFC Ch…" next to a five-letter "World".
                Flexible(
                  flex: 5,
                  child: Text(
                    bidiIsolate(group.league.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.sectionHeader.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (country.isNotEmpty) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs + 2),
                  Text(
                    '·',
                    style: context.type.label.copyWith(color: colors.textTertiary),
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  // `Flexible` as well as the cap: without it the country is
                  // laid out at its natural width beside a `Flexible` name, and
                  // a narrow header (long round label, wide flag glyph) makes
                  // the row overflow instead of ellipsising.
                  Flexible(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.label.copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (round != null && round.isNotEmpty) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            // `Flexible` as well as the cap, for the same reason the country
            // above needs one: at 320 pt with 1.6x Arabic text the cap alone
            // still lays the round out at its natural width and overflows the
            // row by a fraction of a pixel instead of ellipsising.
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width / 3.6,
                ),
                child: Text(
                  bidiIsolate(round),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.label.copyWith(color: colors.textTertiary),
                ),
              ),
            ),
          ],
          FollowStar(
            followed: followed,
            onPressed: onToggleFollow,
            label: context.l10n.semanticsFollowToggle(group.league.name),
          ),
        ],
      ),
    );
  }
}
