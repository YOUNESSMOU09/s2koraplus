import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/league_crest.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/team_badge.dart';

/// Reorder and remove. "Add" pushes `/search`.
class ManageFavouritesScreen extends ConsumerWidget {
  const ManageFavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final Favourites favourites = ref.watch(favouritesProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(context.l10n.screenManageFavourites),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.actionAddFavourites,
            icon: const Icon(MarmaIcons.add),
            onPressed: () => context.push('/search'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ContentWidth(
          child: favourites.isEmpty
          ? MarmaStateView(
              title: context.l10n.manageEmptyTitle,
              body: context.l10n.manageEmptyBody,
              actionLabel: context.l10n.actionAddFavourites,
              onAction: () => context.push('/search'),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: <Widget>[
                if (favourites.leagues.isNotEmpty) ...<Widget>[
                  _Header(text: context.l10n.manageCompetitionsHeader),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: true,
                    itemCount: favourites.leagues.length,
                    onReorderItem: (int oldIndex, int newIndex) => ref
                        .read(favouritesProvider.notifier)
                        .reorderLeagues(oldIndex, newIndex),
                    itemBuilder: (BuildContext context, int index) {
                      final FavouriteLeague league = favourites.leagues[index];
                      return _Tile(
                        key: ValueKey<String>('league-${league.id}'),
                        leading: LeagueCrest(
                          leagueId: league.id,
                          country: league.country,
                          size: 26,
                        ),
                        title: league.name,
                        subtitle: localisedCountryName(
                          league.country,
                          context.languageCode,
                        ),
                        onRemove: () => ref
                            .read(favouritesProvider.notifier)
                            .removeLeague(league.id),
                      );
                    },
                  ),
                ],
                if (favourites.teams.isNotEmpty) ...<Widget>[
                  _Header(text: context.l10n.manageTeamsHeader),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favourites.teams.length,
                    onReorderItem: (int oldIndex, int newIndex) => ref
                        .read(favouritesProvider.notifier)
                        .reorderTeams(oldIndex, newIndex),
                    itemBuilder: (BuildContext context, int index) {
                      final FavouriteTeam team = favourites.teams[index];
                      return _Tile(
                        key: ValueKey<String>('team-${team.id}'),
                        leading: TeamBadge(
                          teamId: team.id,
                          teamName: team.name,
                          size: TeamBadgeSize.lg,
                        ),
                        title: team.name,
                        subtitle: '',
                        onRemove: () => ref
                            .read(favouritesProvider.notifier)
                            .removeTeam(team.id),
                      );
                    },
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            )),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(
      AppSpacing.xl,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.sm,
    ),
    child: Text(
      text,
      style: context.type.sectionHeader.copyWith(
        color: context.colors.textSecondary,
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onRemove,
    super.key,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.blockInset,
        vertical: AppSpacing.xs,
      ),
      decoration: colors.card(borderRadius: AppRadius.cardRadius, hairline: context.hairline),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: colors.surfaceHigh,
        child: ListTile(
          leading: leading,
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.teamName.copyWith(color: colors.textPrimary),
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
                  subtitle,
                  style: context.type.label.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
          trailing: IconButton(
            tooltip: context.l10n.actionRemove,
            icon: Icon(
              MarmaIcons.close,
              size: 18,
              color: colors.textTertiary,
            ),
            onPressed: onRemove,
          ),
        ),
      ),
    );
  }
}
