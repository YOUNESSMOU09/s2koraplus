import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// Long-press any row anywhere: follow either side or follow the competition.
Future<void> showMatchActionsSheet(BuildContext context, Fixture fixture) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => _MatchActionsSheet(fixture: fixture),
  );
}

class _MatchActionsSheet extends ConsumerWidget {
  const _MatchActionsSheet({required this.fixture});

  final Fixture fixture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Favourites favourites = ref.watch(favouritesProvider);
    final MarmaColors colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
              child: Text(
                '${fixture.home.name} · ${fixture.away.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.titleMedium.copyWith(color: colors.textPrimary),
              ),
            ),
            _SheetTile(
              icon: favourites.followsTeam(fixture.home.id)
                  ? MarmaIcons.following
                  : MarmaIcons.following,
              highlighted: favourites.followsTeam(fixture.home.id),
              label: favourites.followsTeam(fixture.home.id)
                  ? context.l10n.sheetUnfollow(fixture.home.name)
                  : context.l10n.sheetFollowHome(fixture.home.name),
              onTap: () {
                ref.read(favouritesProvider.notifier).toggleTeam(
                    FavouriteTeam(id: fixture.home.id, name: fixture.home.name));
                Navigator.of(context).pop();
              },
            ),
            _SheetTile(
              icon: favourites.followsTeam(fixture.away.id)
                  ? MarmaIcons.following
                  : MarmaIcons.following,
              highlighted: favourites.followsTeam(fixture.away.id),
              label: favourites.followsTeam(fixture.away.id)
                  ? context.l10n.sheetUnfollow(fixture.away.name)
                  : context.l10n.sheetFollowHome(fixture.away.name),
              onTap: () {
                ref.read(favouritesProvider.notifier).toggleTeam(
                    FavouriteTeam(id: fixture.away.id, name: fixture.away.name));
                Navigator.of(context).pop();
              },
            ),
            _SheetTile(
              icon: favourites.followsLeague(fixture.league.id)
                  ? MarmaIcons.competition
                  : MarmaIcons.competition,
              highlighted: favourites.followsLeague(fixture.league.id),
              label: favourites.followsLeague(fixture.league.id)
                  ? context.l10n.sheetUnfollow(fixture.league.name)
                  : context.l10n.sheetFollowCompetition(fixture.league.name),
              subtitle: localisedCountryName(fixture.league.country, context.languageCode),
              onTap: () {
                ref.read(favouritesProvider.notifier).toggleLeague(FavouriteLeague(
                      id: fixture.league.id,
                      name: fixture.league.name,
                      country: fixture.league.country,
                    ));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.highlighted,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return ListTile(
      leading: Icon(icon, color: highlighted ? colors.accent : colors.textSecondary),
      title: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: context.type.bodyLarge.copyWith(color: colors.textPrimary),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: context.type.label.copyWith(color: colors.textTertiary)),
      onTap: onTap,
    );
  }
}
