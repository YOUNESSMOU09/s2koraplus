import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/core/extensions/status_l10n.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/domain/entities/refs.dart';
import 'package:marma/l10n/country_names.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/live_minute_badge.dart';
import 'package:marma/presentation/widgets/match_actions_sheet.dart';
import 'package:marma/presentation/widgets/score_column.dart';
import 'package:marma/presentation/widgets/team_badge.dart';
import 'package:marma/presentation/widgets/match_open_action.dart';

/// The atom of the whole app.
///
/// Watches `resolvedFixtureProvider` so a `/live` poll that changes one score
/// rebuilds exactly one row, never the 1204-row list.
class MatchRow extends ConsumerWidget {
  const MatchRow({
    required this.fixtureId,
    this.fallback,
    this.showFollowAffordance = false,
    this.rewardedOnOpen = false,
    super.key,
  });

  final String fixtureId;

  /// Used before the buckets resolve (search results, following feed).
  final Fixture? fallback;
  final bool showFollowAffordance;

  /// Matches and Live cards open behind a REWARDED ad; every other surface
  /// (search, following, the journal index) keeps the interstitial.
  final bool rewardedOnOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Fixture? fixture = ref.watch(resolvedFixtureProvider(fixtureId)) ?? fallback;
    if (fixture == null) return const SizedBox.shrink();
    return _MatchRowBody(
      fixture: fixture,
      ref: ref,
      rewardedOnOpen: rewardedOnOpen,
      showFollowAffordance: showFollowAffordance,
    );
  }
}

class _MatchRowBody extends StatelessWidget {
  const _MatchRowBody({
    required this.fixture,
    required this.ref,
    required this.rewardedOnOpen,
    required this.showFollowAffordance,
  });

  final Fixture fixture;
  final WidgetRef ref;
  final bool rewardedOnOpen;
  final bool showFollowAffordance;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final ResolvedScoreline score = fixture.scoreline;
    final String? winnerId = fixture.winningTeamId;

    return Semantics(
      button: true,
      label: _semanticsLabel(context),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => openMatchFromCard(
            context,
            ref,
            fixture,
            rewarded: rewardedOnOpen,
          ),
          onLongPress: () => showMatchActionsSheet(context, fixture),
          highlightColor: colors.surfaceHigh,
          splashFactory: NoSplash.splashFactory,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              // Home · score · away, mirrored as a whole in RTL so each crest
              // always sits beside its own score digit.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: _TeamSide(
                      team: fixture.home,
                      towardsCentre: true,
                      won: winnerId != null && winnerId == fixture.home.id,
                      dimmed: winnerId != null && winnerId != fixture.home.id,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // A minimum, not a fixed width: `90+4'` at 1.6x Dynamic
                  // Type must be able to grow instead of overflowing.
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 64, maxWidth: 96),
                    child: _CentreCell(fixture: fixture, score: score),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _TeamSide(
                      team: fixture.away,
                      towardsCentre: false,
                      won: winnerId != null && winnerId == fixture.away.id,
                      dimmed: winnerId != null && winnerId != fixture.away.id,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// VoiceOver must say "67th minute", not the prime-mark form `67'`, which
  /// screen readers either skip or read as a unit of length (§13).
  String _spokenMinute(BuildContext context, MatchStatus status) {
    final int? elapsed = status.elapsed;
    if (elapsed == null) return localisedStatusLong(context.l10n, status);
    if (status.phase == MatchPhase.halftime) {
      return localisedStatusLong(context.l10n, status);
    }
    final int? extra = status.extra;
    if (extra != null && extra > 0) {
      return context.l10n.semanticsMinuteAdded('$elapsed', '$extra');
    }
    return context.l10n.semanticsMinute('$elapsed');
  }

  String _semanticsLabel(BuildContext context) {
    final String country = localisedCountryName(fixture.league.country, context.languageCode);
    final ResolvedScoreline s = fixture.scoreline;
    if (s.kind == ScorelineKind.scheduled) {
      return context.l10n.semanticsMatchScheduled(
        fixture.home.name,
        fixture.away.name,
        AppFormat.kickoffTime(fixture.kickoffLocal),
        fixture.league.name,
        country,
      );
    }
    if (fixture.phase.isLiveish) {
      return context.l10n.semanticsMatchLive(
        fixture.home.name,
        AppFormat.goals(s.home),
        fixture.away.name,
        AppFormat.goals(s.away),
        _spokenMinute(context, fixture.status),
        fixture.league.name,
        country,
      );
    }
    return context.l10n.semanticsMatchFinished(
      fixture.home.name,
      AppFormat.goals(s.home),
      fixture.away.name,
      AppFormat.goals(s.away),
      fixture.league.name,
      country,
    );
  }
}

/// The middle of the row: kickoff time, or the scoreline with its status
/// (live minute, FT, postponed…) underneath.
class _CentreCell extends StatelessWidget {
  const _CentreCell({required this.fixture, required this.score});

  final Fixture fixture;
  final ResolvedScoreline score;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final bool scheduled = score.kind == ScorelineKind.scheduled;

    final Widget top = scheduled
        ? Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs + 1,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceHighest,
              borderRadius: AppRadius.badgeRadius,
            ),
            child: Text(
              AppFormat.kickoffTime(fixture.kickoffLocal),
              textDirection: TextDirection.ltr,
              maxLines: 1,
              style: context.type.mono.copyWith(
                color: colors.textPrimary,
                fontSize: 14,
              ),
            ),
          )
        : RowScoreline(
            home: score.home,
            away: score.away,
            live: fixture.phase.isLiveish,
          );

    final Widget? status = _StatusLabel.forFixture(fixture);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Scales down rather than overflowing at large Dynamic Type.
        FittedBox(fit: BoxFit.scaleDown, child: top),
        if (status != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs + 1),
          status,
        ],
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.fixture});

  final Fixture fixture;

  /// Scheduled matches carry their kickoff time in the centre already.
  static Widget? forFixture(Fixture fixture) =>
      fixture.status.phase == MatchPhase.scheduled ? null : _StatusLabel(fixture: fixture);

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final MatchStatus status = fixture.status;

    switch (status.phase) {
      case MatchPhase.live:
      case MatchPhase.halftime:
        return LiveMinuteBadge(status: status);
      case MatchPhase.scheduled:
        return const SizedBox.shrink();
      case MatchPhase.finished:
        return Text(
          localisedStatusAbbr(context.l10n, status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.type.monoSmall.copyWith(color: colors.textTertiary),
        );
      case MatchPhase.postponed:
      case MatchPhase.abandoned:
        return Text(
          localisedStatusAbbr(context.l10n, status),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.type.monoSmall.copyWith(color: colors.danger),
        );
      case MatchPhase.unknown:
        return Text(
          status.longText.isEmpty ? '—' : status.longText,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: context.type.monoSmall.copyWith(color: colors.textTertiary),
        );
    }
  }
}

/// Crest beside the name. [towardsCentre] puts the crest on the END edge (the
/// home side), so both crests hug the score in either text direction.
class _TeamSide extends StatelessWidget {
  const _TeamSide({
    required this.team,
    required this.towardsCentre,
    required this.won,
    required this.dimmed,
  });

  final TeamRef team;
  final bool towardsCentre;
  final bool won;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Widget badge = TeamBadge(teamId: team.id, teamName: team.name, size: TeamBadgeSize.md);
    final Widget name = Expanded(
      child: Text(
        bidiIsolate(team.name),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: towardsCentre ? TextAlign.end : TextAlign.start,
        style: context.type.teamName.copyWith(
          fontSize: 14,
          height: 1.25,
          fontWeight: won ? FontWeight.w700 : FontWeight.w500,
          color: dimmed ? colors.textSecondary : colors.textPrimary,
        ),
      ),
    );
    return Row(
      children: towardsCentre
          ? <Widget>[name, const SizedBox(width: AppSpacing.sm), badge]
          : <Widget>[badge, const SizedBox(width: AppSpacing.sm), name],
    );
  }
}
