import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/screens/journal/journal_l10n.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/services/journal_insights.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/marma_button.dart';

/// §17 — "Summarise my match".
///
/// Everything shown is quoted back from what the user already wrote; nothing is
/// generated, inferred or sent anywhere. The original note is NEVER replaced —
/// the only write this sheet offers is an explicit append, under a rule.
Future<void> showJournalSummary(
  BuildContext context, {
  required FootballNote note,
  required void Function(String appended) onAppend,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) =>
        _SummarySheet(note: note, onAppend: onAppend),
  );
}

class _SummarySheet extends StatelessWidget {
  const _SummarySheet({required this.note, required this.onAppend});

  final FootballNote note;
  final void Function(String appended) onAppend;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final JournalSummary summary = summariseJournal(note);

    final List<_Line> lines = <_Line>[
      if (summary.opinion != null)
        _Line(context.l10n.journalSummaryOpinion, summary.opinion!),
      if (summary.bestPlayer != null)
        _Line(
          context.l10n.journalSummaryBestPlayer,
          summary.bestPlayerRating == null
              ? summary.bestPlayer!
              : '${summary.bestPlayer!} · '
                  '${context.l10n.journalRatingOutOf(summary.bestPlayerRating!.toStringAsFixed(1))}',
        ),
      if (summary.favouriteMoment != null)
        _Line(
          context.l10n.journalSummaryFavouriteMoment,
          (summary.favouriteMomentClock ?? '').isEmpty
              ? summary.favouriteMoment!
              : '${summary.favouriteMomentClock} · ${summary.favouriteMoment}',
        ),
      if (summary.tacticalObservation != null)
        _Line(context.l10n.journalSummaryTactical, summary.tacticalObservation!),
      if (summary.disappointment != null)
        _Line(context.l10n.journalSummaryDisappointment, summary.disappointment!),
      if (summary.finalRating != null)
        _Line(
          context.l10n.journalSummaryFinalRating,
          context.l10n.journalRatingOutOf(summary.finalRating!.toStringAsFixed(1)),
        ),
    ];

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.82),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.sm),
              child: Text(
                context.l10n.journalSummaryTitle,
                style: context.type.titleLarge.copyWith(color: colors.textPrimary),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (lines.isEmpty && summary.reactions.isEmpty && summary.moods.isEmpty)
                      Text(
                        context.l10n.journalSummaryEmpty,
                        style: context.type.bodyLarge
                            .copyWith(color: colors.textSecondary),
                      )
                    else ...<Widget>[
                      if (summary.reactions.isNotEmpty || summary.moods.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(
                            <String>[
                              ...summary.reactions.map((ReactionKind r) => r.label(context.l10n)),
                              ...summary.moods.map((MoodKind m) => m.label(context.l10n)),
                            ].join(' · '),
                            style: context.type.titleMedium.copyWith(color: colors.accent),
                          ),
                        ),
                      for (final _Line line in lines)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                line.label,
                                style: context.type.label
                                    .copyWith(color: colors.textTertiary),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                line.value,
                                style: context.type.bodyLarge
                                    .copyWith(color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.journalSummaryNote,
                      style: context.type.bodyMedium.copyWith(
                        color: colors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            if (lines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: MarmaButton.secondary(
                  label: context.l10n.journalSummaryAppend,
                  onPressed: () {
                    onAppend(_asText(context, lines));
                    Navigator.of(context).pop();
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _asText(BuildContext context, List<_Line> lines) {
    final StringBuffer buffer = StringBuffer()
      ..writeln()
      ..writeln('— ${context.l10n.journalSummaryTitle} —');
    for (final _Line line in lines) {
      buffer.writeln('${line.label}: ${line.value}');
    }
    return buffer.toString();
  }
}

class _Line {
  const _Line(this.label, this.value);

  final String label;
  final String value;
}
