import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/core/extensions/status_l10n.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_event.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/entities/refs.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/screens/journal/journal_screen.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/follow_star.dart';
import 'package:marma/presentation/widgets/league_crest.dart';
import 'package:marma/presentation/widgets/live_minute_badge.dart';
import 'package:marma/presentation/widgets/team_badge.dart';

part 'match_timeline.dart';

/// Full-screen (outside the shell) so there is exactly ONE definition of match
/// detail reachable from every surface, with an immersive header.
///
/// `extra` is null on a cold start or deep link; resolution then falls back to
/// live -> today -> tomorrow -> yesterday, and finally to a designed
/// "not in the three-day window" state. Never a blank screen, never a raw
/// exception (§7.3).
class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({required this.fixtureId, this.initial, super.key});

  final String fixtureId;
  final Fixture? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final Fixture? fixture = ref.watch(resolvedFixtureProvider(fixtureId)) ?? initial;

    if (fixture == null) {
      return Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(),
        body: ContentWidth(
            child: MarmaStateView(
          title: context.l10n.notFoundTitle,
          body: context.l10n.notFoundBody,
          actionLabel: context.l10n.actionGoToToday,
          onAction: () => context.go('/matches?day=today'),
        )),
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            LeagueCrest(
              leagueId: fixture.league.id,
              country: fixture.league.country,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                bidiIsolate(fixture.league.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.titleMedium.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(MarmaIcons.journal),
            tooltip: context.l10n.journalActionOpen,
            onPressed: () => openMatchJournal(context, fixture.id),
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, _) {
              final bool followed = ref.watch(favouritesProvider
                  .select((Favourites f) => f.followsLeague(fixture.league.id)));
              return FollowStar(
                followed: followed,
                label: context.l10n.semanticsFollowToggle(fixture.league.name),
                onPressed: () =>
                    ref.read(favouritesProvider.notifier).toggleLeague(FavouriteLeague(
                          id: fixture.league.id,
                          name: fixture.league.name,
                          country: fixture.league.country,
                        )),
              );
            },
          ),
        ],
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.giant),
          children: <Widget>[
            _Header(fixture: fixture),
            _MetaBlock(fixture: fixture),
            _MatchTimeline(fixture: fixture),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
              child: Text(
                context.l10n.matchDetailAttribution,
                style: context.type.bodyMedium.copyWith(
                  color: colors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.fixture});

  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final ResolvedScoreline score = fixture.scoreline;
    final String? winnerId = fixture.winningTeamId;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.blockInset, AppSpacing.sm, AppSpacing.blockInset, 0),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[colors.heroStart, colors.heroEnd],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sheet)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.heroStart.withValues(alpha: colors.isDark ? 0 : 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _StatusLine(fixture: fixture),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _TeamColumn(
                  team: fixture.home,
                  dimmed: winnerId != null && winnerId != fixture.home.id,
                ),
              ),
              _ScoreBlock(fixture: fixture, score: score),
              Expanded(
                child: _TeamColumn(
                  team: fixture.away,
                  dimmed: winnerId != null && winnerId != fixture.away.id,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.fixture});

  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    if (fixture.phase.isLiveish) {
      return LiveMinuteBadge(status: fixture.status);
    }
    final bool troubled =
        fixture.phase == MatchPhase.abandoned || fixture.phase == MatchPhase.postponed;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: troubled ? colors.liveSurface : colors.onHero.withValues(alpha: 0.16),
        borderRadius: AppRadius.chipRadius,
      ),
      child: Text(
        localisedStatusLong(context.l10n, fixture.status),
        textAlign: TextAlign.center,
        style: context.type.label.copyWith(
          color: troubled ? colors.danger : colors.onHero,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  const _TeamColumn({required this.team, required this.dimmed});

  final TeamRef team;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      children: <Widget>[
        // Crests sit on a white disc so dark line-art marks stay legible on
        // the blue header.
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TeamBadge(teamId: team.id, teamName: team.name, size: TeamBadgeSize.lg),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          bidiIsolate(team.name),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.type.titleMedium.copyWith(
            color: dimmed ? colors.onHero.withValues(alpha: 0.7) : colors.onHero,
          ),
        ),
      ],
    );
  }
}

/// The scoreline. RTL-safe: three separate widgets in a logical row, never the
/// single string `"2 - 1"` (bidi would reorder it next to Arabic text).
class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.fixture, required this.score});

  final Fixture fixture;
  final ResolvedScoreline score;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;

    if (score.kind == ScorelineKind.scheduled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Column(
          children: <Widget>[
            Text(
              AppFormat.kickoffTime(fixture.kickoffLocal),
              textDirection: TextDirection.ltr,
              style: context.type.scoreLarge.copyWith(color: colors.onHero),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppFormat.shortDate(fixture.kickoffLocal, context.languageCode),
              style: context.type.monoSmall.copyWith(color: colors.onHero.withValues(alpha: 0.7)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: <Widget>[
          // Ambient direction, like the team columns around it, so each digit
          // sits under its own crest in RTL too.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(AppFormat.goals(score.home),
                  style: context.type.displayScore.copyWith(color: colors.onHero)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text('–',
                    style: context.type.displayScore.copyWith(color: colors.onHero.withValues(alpha: 0.7))),
              ),
              Text(AppFormat.goals(score.away),
                  style: context.type.displayScore.copyWith(color: colors.onHero)),
            ],
          ),
          if (score.kind == ScorelineKind.afterExtraTime) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _Chip(label: context.l10n.abbrAfterExtraTime),
            if (score.hasSecondary)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  context.l10n.labelFullTimeScore(
                      '${score.secondaryHome}', '${score.secondaryAway}'),
                  style: context.type.monoSmall.copyWith(color: colors.onHero.withValues(alpha: 0.7)),
                ),
              ),
          ],
          if (score.kind == ScorelineKind.afterPenalties) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            _Chip(label: context.l10n.abbrPenalties),
            if (score.hasSecondary)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  context.l10n.labelPenaltiesScore(
                      '${score.secondaryHome}', '${score.secondaryAway}'),
                  style: context.type.monoSmall.copyWith(color: colors.onHero.withValues(alpha: 0.7)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: colors.onHero.withValues(alpha: 0.16),
        borderRadius: AppRadius.chipRadius,
      ),
      child: Text(label,
          style: context.type.monoSmall.copyWith(color: colors.onHero)),
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.fixture});

  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final List<({IconData icon, String label, String value, Widget? leading})> rows =
        <({IconData icon, String label, String value, Widget? leading})>[
      (
        leading: LeagueCrest(
          leagueId: fixture.league.id,
          country: fixture.league.country,
          size: 22,
        ),
        icon: MarmaIcons.competition,
        label: context.l10n.labelCompetition,
        value:
            '${fixture.league.name} · ${localisedCountryName(fixture.league.country, context.languageCode)}',
      ),
      if (fixture.league.round != null && fixture.league.round!.isNotEmpty)
        (
          leading: null,
          icon: MarmaIcons.round,
          label: context.l10n.labelRound,
          value: fixture.league.round!
        ),
      (
        leading: null,
        icon: MarmaIcons.kickoff,
        label: context.l10n.labelKickoff,
        value:
            '${AppFormat.kickoffTime(fixture.kickoffLocal)} · ${AppFormat.longDate(fixture.kickoffLocal, context.languageCode)}'
      ),
      if (fixture.venue != null)
        (
          leading: null,
          icon: MarmaIcons.venue,
          label: context.l10n.labelVenue,
          value: fixture.venue!.label
        ),
      if (fixture.referee != null)
        (
          leading: null,
          icon: MarmaIcons.referee,
          label: context.l10n.labelReferee,
          value: fixture.referee!
        ),
      if (fixture.league.season > 0)
        (
          leading: null,
          icon: MarmaIcons.season,
          label: context.l10n.labelSeason,
          value: '${fixture.league.season}'
        ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.blockInset, AppSpacing.lg, AppSpacing.blockInset, 0),
      decoration: colors.card(hairline: context.hairline),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: AppSpacing.giant),
                child: Divider(height: 1, thickness: 1, color: colors.outline),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    child: Center(
                      child: rows[i].leading ??
                          Icon(rows[i].icon, size: 18, color: colors.textTertiary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(rows[i].label,
                            style: context.type.label
                                .copyWith(color: colors.textTertiary)),
                        const SizedBox(height: 2),
                        Text(bidiIsolate(rows[i].value),
                            style: context.type.bodyMedium
                                .copyWith(color: colors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
