import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/domain/services/journal_progress.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_note_card.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/presentation/widgets/team_badge.dart';

/// §1 — the journal hero: the same blue gradient card as match detail, with
/// the journal's own progress ring and save state along the bottom.
///
/// [progress] is null on the unstarted journal, where there is nothing to
/// measure yet and the footer is left out.
class JournalHero extends StatelessWidget {
  const JournalHero({
    required this.note,
    this.progress,
    this.save,
    this.savedAt,
    super.key,
  });

  final FootballNote note;
  final JournalProgress? progress;
  final SaveState? save;
  final DateTime? savedAt;

  @override
  Widget build(BuildContext context) {
    // A deep link to a target with no fixture, no snapshot and no title has
    // nothing to say; an empty hero would read as data that failed to load.
    if (note.header.title.isEmpty && note.header.homeTeamName == null) {
      return const SizedBox.shrink();
    }
    final MarmaColors colors = context.colors;
    final JournalProgress? p = progress;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
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
          switch (note.targetType) {
            JournalTargetType.match => _MatchBody(header: note.header),
            JournalTargetType.team => _PortraitBody(
                id: note.header.homeTeamId ?? note.targetId,
                name: note.header.title,
                eyebrow: context.l10n.journalHeaderTeam,
                lines: <String>[
                  if (note.header.country != null) note.header.country!,
                  if (note.header.competition != null) note.header.competition!,
                ],
              ),
            JournalTargetType.player => _PortraitBody(
                id: note.header.homeTeamId ?? note.targetId,
                name: note.header.title,
                eyebrow: context.l10n.journalHeaderPlayer,
                lines: <String>[
                  if (note.header.position != null) note.header.position!,
                  if (note.header.subtitle != null) note.header.subtitle!,
                  if (note.header.nationality != null) note.header.nationality!,
                ],
              ),
          },
          if (p != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Divider(height: 1, color: colors.onHero.withValues(alpha: 0.16)),
            const SizedBox(height: AppSpacing.md),
            _ProgressFooter(progress: p, save: save, savedAt: savedAt),
          ],
        ],
      ),
    );
  }
}

class _MatchBody extends StatelessWidget {
  const _MatchBody({required this.header});

  final JournalHeader header;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final DateTime? kickoff = header.kickoffLocal;
    final String eyebrow = <String>[
      if (header.competition != null) header.competition!,
      if (header.statusLabel != null) header.statusLabel!,
    ].join(' · ');
    final String meta = <String>[
      if (kickoff != null) AppFormat.shortDate(kickoff, context.languageCode),
      if (header.venue != null) header.venue!,
    ].join(' · ');

    return Column(
      children: <Widget>[
        if (eyebrow.isNotEmpty) _HeroChip(text: eyebrow),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _Side(id: header.homeTeamId, name: header.homeTeamName ?? header.title),
            ),
            _Score(header: header),
            Expanded(
              child: _Side(
                id: header.awayTeamId,
                name: header.awayTeamName ?? header.subtitle ?? '',
              ),
            ),
          ],
        ),
        if (meta.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(MarmaIcons.kickoff, size: 14, color: colors.onHero.withValues(alpha: 0.75)),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  bidiIsolate(meta),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.label.copyWith(
                    color: colors.onHero.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.id, required this.name});

  final String? id;
  final String name;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          _CrestDisc(id: id ?? name, name: name),
          const SizedBox(height: AppSpacing.sm),
          Text(
            bidiIsolate(name),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.type.titleMedium.copyWith(color: context.colors.onHero),
          ),
        ],
      );
}

/// Crests sit on a white disc so dark line-art marks stay legible on blue.
class _CrestDisc extends StatelessWidget {
  const _CrestDisc({required this.id, required this.name});

  final String id;
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TeamBadge(teamId: id, teamName: name, size: TeamBadgeSize.lg),
      );
}

class _Score extends StatelessWidget {
  const _Score({required this.header});

  final JournalHeader header;

  @override
  Widget build(BuildContext context) {
    final Color ink = context.colors.onHero;
    if (!header.hasScore) {
      final DateTime? kickoff = header.kickoffLocal;
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: AppSpacing.lg, start: AppSpacing.sm, end: AppSpacing.sm),
        child: Text(
          kickoff == null ? '–' : AppFormat.kickoffTime(kickoff),
          textDirection: TextDirection.ltr,
          style: context.type.scoreLarge.copyWith(color: ink),
        ),
      );
    }
    // Three widgets in the ambient direction, never the string "2 - 1", so
    // each digit sits under its own crest in RTL as well.
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.md, start: AppSpacing.sm, end: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(AppFormat.goals(header.homeGoals),
              style: context.type.displayScore.copyWith(color: ink)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text('–',
                style: context.type.displayScore.copyWith(color: ink.withValues(alpha: 0.6))),
          ),
          Text(AppFormat.goals(header.awayGoals),
              style: context.type.displayScore.copyWith(color: ink)),
        ],
      ),
    );
  }
}

class _PortraitBody extends StatelessWidget {
  const _PortraitBody({
    required this.id,
    required this.name,
    required this.eyebrow,
    required this.lines,
  });

  final String id;
  final String name;
  final String eyebrow;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      children: <Widget>[
        _HeroChip(text: eyebrow),
        const SizedBox(height: AppSpacing.lg),
        _CrestDisc(id: id, name: name),
        const SizedBox(height: AppSpacing.md),
        Text(
          bidiIsolate(name),
          textAlign: TextAlign.center,
          style: context.type.titleLarge.copyWith(color: colors.onHero),
        ),
        if (lines.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            bidiIsolate(lines.join(' · ')),
            textAlign: TextAlign.center,
            style: context.type.bodyMedium.copyWith(color: colors.onHero.withValues(alpha: 0.8)),
          ),
        ],
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.onHero.withValues(alpha: 0.16),
        borderRadius: AppRadius.chipRadius,
      ),
      child: Text(
        bidiIsolate(text),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.type.label.copyWith(color: colors.onHero, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Progress ring + "7 of 15 sections" on one side, save state on the other.
class _ProgressFooter extends StatelessWidget {
  const _ProgressFooter({required this.progress, required this.save, required this.savedAt});

  final JournalProgress progress;
  final SaveState? save;
  final DateTime? savedAt;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String saveText = switch (save) {
      SaveState.pending => context.l10n.journalSaving,
      SaveState.saved => journalSavedLabel(context, savedAt),
      SaveState.idle || null => context.l10n.journalUnsaved,
    };
    return Row(
      children: <Widget>[
        ProgressRing(
          value: progress.fraction,
          size: 34,
          stroke: 4,
          color: colors.onHero,
          track: colors.onHero.withValues(alpha: 0.2),
          child: progress.isComplete
              ? Icon(Icons.check_rounded, size: 16, color: colors.onHero)
              : null,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            context.l10n.journalProgress(progress.done, progress.total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.label.copyWith(
              color: colors.onHero,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(
          save == SaveState.pending ? Icons.sync_rounded : Icons.cloud_done_outlined,
          size: 15,
          color: colors.onHero.withValues(alpha: 0.8),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            saveText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.label.copyWith(color: colors.onHero.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }
}

/// An animated circular progress ring. Animates between values; jumps under
/// Reduce Motion and in tests.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.value,
    required this.color,
    required this.track,
    this.size = 28,
    this.stroke = 3,
    this.child,
    super.key,
  });

  final double value;
  final Color color;
  final Color track;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget ring(double v) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(value: v, color: color, track: track, stroke: stroke),
          child: SizedBox.square(dimension: size, child: Center(child: child)),
        );
    if (!AppMotion.enabled(context)) return ring(value);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: AppMotion.slow * 2,
      curve: AppMotion.emphasis,
      builder: (BuildContext context, double v, _) => ring(v),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.stroke,
  });

  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = (Offset.zero & size).deflate(stroke / 2);
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (value <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value.clamp(0, 1),
      false,
      base
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track;
}
