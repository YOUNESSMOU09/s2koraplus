import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/refs.dart';
import 'package:marma/domain/services/search_index.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/follow_star.dart';
import 'package:marma/presentation/widgets/league_crest.dart';
import 'package:marma/presentation/widgets/match_row.dart';
import 'package:marma/presentation/widgets/team_badge.dart';

/// Full-screen search over the union of the three cached buckets. Purely
/// client-side: the backend ignores query parameters entirely.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).set(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String query = ref.watch(searchQueryProvider);
    final SearchResults results = ref.watch(searchResultsProvider);
    // Opening search is the one moment the full competition catalog is worth
    // its ~11 requests; it is disk-cached for a week after that.
    ref.watch(leagueCatalogProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        // Default title spacing: with `0` the field sits flush against the
        // screen edge when the route is opened without a back button.
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.l10n.searchHint,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: context.type.bodyLarge.copyWith(color: colors.textPrimary),
          onChanged: _onChanged,
        ),
        actions: <Widget>[
          if (query.isNotEmpty)
            IconButton(
              tooltip: context.l10n.actionClear,
              icon: const Icon(MarmaIcons.close, size: 18),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).clear();
              },
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ContentWidth(child: _body(context, query, results)),
    );
  }

  Widget _body(BuildContext context, String query, SearchResults results) {
    if (query.trim().length < 2) {
      return MarmaStateView(
        title: context.l10n.emptySearchTitle,
        body: context.l10n.emptySearchBody,
      );
    }
    if (results.isEmpty) {
      return MarmaStateView(
        title: context.l10n.noResultsTitle(query),
        body: context.l10n.noResultsBody,
        actionLabel: context.l10n.actionClear,
        onAction: () {
          _controller.clear();
          ref.read(searchQueryProvider.notifier).clear();
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.giant),
      children: <Widget>[
        if (results.competitions.isNotEmpty) ...<Widget>[
          _Header(text: context.l10n.labelCompetitions),
          for (final LeagueRef league in results.competitions)
            _CompetitionResult(league: league),
        ],
        if (results.teams.isNotEmpty) ...<Widget>[
          _Header(text: context.l10n.labelTeams),
          for (final TeamHit hit in results.teams) _TeamResult(hit: hit),
        ],
        if (results.fixtures.isNotEmpty) ...<Widget>[
          _Header(text: context.l10n.labelMatches),
          for (final Fixture fixture in results.fixtures)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.blockInset),
              child: MatchRow(
                key: ValueKey<String>(fixture.id),
                fixtureId: fixture.id,
                fallback: fixture,
                showFollowAffordance: true,
              ),
            ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
        child: Text(
          text,
          style: context.type.sectionHeader.copyWith(color: context.colors.textSecondary),
        ),
      );
}

class _CompetitionResult extends ConsumerWidget {
  const _CompetitionResult({required this.league});

  final LeagueRef league;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool followed = ref.watch(
        favouritesProvider.select((Favourites f) => f.followsLeague(league.id)));
    return ListTile(
      leading: LeagueCrest(
        leagueId: league.id,
        country: league.country,
        size: 28,
      ),
      title: Text(league.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(localisedCountryName(league.country, context.languageCode)),
      trailing: FollowStar(
        followed: followed,
        label: context.l10n.semanticsFollowToggle(league.name),
        onPressed: () => ref.read(favouritesProvider.notifier).toggleLeague(
              FavouriteLeague(
                id: league.id,
                name: league.name,
                country: league.country,
              ),
            ),
      ),
    );
  }
}

class _TeamResult extends ConsumerWidget {
  const _TeamResult({required this.hit});

  final TeamHit hit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool followed = ref.watch(
        favouritesProvider.select((Favourites f) => f.followsTeam(hit.team.id)));
    return ListTile(
      leading: TeamBadge(
        teamId: hit.team.id,
        teamName: hit.team.name,
        size: TeamBadgeSize.lg,
      ),
      title: Text(hit.team.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${hit.leagueName} · ${localisedCountryName(hit.country, context.languageCode)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: FollowStar(
        followed: followed,
        label: context.l10n.semanticsFollowToggle(hit.team.name),
        onPressed: () => ref
            .read(favouritesProvider.notifier)
            .toggleTeam(FavouriteTeam(id: hit.team.id, name: hit.team.name)),
      ),
    );
  }
}
