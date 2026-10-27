part of 'match_detail_screen.dart';

/// Goal / card / substitution feed.
///
/// Events exist ONLY on `/live` (API_CONTRACT Constraint 2), so a finished or
/// scheduled match shows a designed explanation rather than an empty box.
/// `player.name` and `assist.name` are frequently null — a nameless goal falls
/// back to the team name and the assist line is omitted entirely.
class _MatchTimeline extends StatelessWidget {
  const _MatchTimeline({required this.fixture});

  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final List<MatchEvent> events = fixture.events;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.blockInset, AppSpacing.lg, AppSpacing.blockInset, 0),
      decoration: colors.card(hairline: context.hairline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
            child: Text(
              context.l10n.labelTimeline,
              style: context.type.sectionHeader.copyWith(color: colors.textSecondary),
            ),
          ),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Text(
                fixture.phase.isLiveish
                    ? context.l10n.matchDetailNoTimeline
                    : context.l10n.matchDetailTimelineLiveOnly,
                style: context.type.bodyMedium.copyWith(color: colors.textTertiary),
              ),
            )
          else
            for (int i = 0; i < events.length; i++)
              _EventRow(event: events[i], fixture: fixture, isLast: i == events.length - 1),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.fixture, required this.isLast});

  final MatchEvent event;
  final Fixture fixture;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;

    final String teamName = event.teamName ??
        (event.teamId == fixture.home.id ? fixture.home.name : fixture.away.name);
    // A nameless goal is common in this feed; fall back to the team.
    final String primary = event.playerName ?? teamName;

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, isLast ? AppSpacing.lg : AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 38,
            child: Text(
              event.minuteLabel,
              textDirection: TextDirection.ltr,
              style: context.type.mono.copyWith(color: colors.textTertiary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _EventGlyph(event: event),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  bidiIsolate(primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.teamName.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 1),
                Text(
                  '${localisedEventDetail(context.l10n, event)} · ${bidiIsolate(teamName)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.label.copyWith(color: colors.textTertiary),
                ),
                if (event.assistName != null)
                  Text(
                    context.l10n.labelAssist(event.assistName!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.label.copyWith(color: colors.textTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cards are DRAWN shapes, not icons — colour plus shape, never colour alone.
class _EventGlyph extends StatelessWidget {
  const _EventGlyph({required this.event});

  final MatchEvent event;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    if (event.type == EventType.card) {
      final Color fill = event.isRedCard ? colors.danger : const Color(0xFFF5C542);
      return Semantics(
        label: localisedEventDetail(context.l10n, event),
        child: Container(
          width: 9,
          height: 12,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(2)),
        ),
      );
    }
    final IconData icon = switch (event.type) {
      EventType.goal => MarmaIcons.matches,
      EventType.subst => MarmaIcons.substitution,
      _ => MarmaIcons.info,
    };
    return Icon(
      icon,
      size: 15,
      fill: event.type == EventType.goal ? 1 : 0,
      color: event.type == EventType.goal ? colors.textPrimary : colors.textTertiary,
    );
  }
}
