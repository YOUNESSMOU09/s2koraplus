import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/domain/services/journal_insights.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/journal_l10n.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_chrome.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_icons.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_moment_cards.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_sheet.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// §9 — tactical notes: four prose lines and six rated aspects.
class TacticalCard extends StatelessWidget {
  const TacticalCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final TacticalAnalysis t = note.tactical;
    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.tactical,
            title: context.l10n.journalSectionTactical,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: JournalAutoField(
                  initialValue: t.formation ?? '',
                  label: context.l10n.journalTacticalFormation,
                  hint: context.l10n.journalTacticalFormationHint,
                  maxLength: 16,
                  onChanged: (String v) => controller.setTactical(t.copyWith(formation: v)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: JournalAutoField(
                  initialValue: t.bestPlayer ?? '',
                  label: context.l10n.journalTacticalBestPlayer,
                  maxLength: 60,
                  onChanged: (String v) => controller.setTactical(t.copyWith(bestPlayer: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: t.bestTactic ?? '',
            label: context.l10n.journalTacticalBestTactic,
            hint: context.l10n.journalTacticalBestTacticHint,
            maxLength: 80,
            onChanged: (String v) => controller.setTactical(t.copyWith(bestTactic: v)),
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: t.keyWeakness ?? '',
            label: context.l10n.journalTacticalWeakness,
            hint: context.l10n.journalTacticalWeaknessHint,
            maxLength: 80,
            onChanged: (String v) => controller.setTactical(t.copyWith(keyWeakness: v)),
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: t.comment ?? '',
            label: context.l10n.journalTacticalComment,
            maxLines: 4,
            maxLength: 600,
            onChanged: (String v) => controller.setTactical(t.copyWith(comment: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.l10n.journalTacticalAspects,
            style: context.type.label.copyWith(color: context.colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final TacticalAspect aspect in TacticalAspect.values)
            _AspectRow(
              label: aspect.label(context.l10n),
              value: t.aspects[aspect],
              onChanged: (int v) {
                final Map<TacticalAspect, int> next =
                    Map<TacticalAspect, int>.of(t.aspects)..[aspect] = v;
                controller.setTactical(t.copyWith(aspects: next));
              },
            ),
        ],
      ),
    );
  }
}

class _AspectRow extends StatelessWidget {
  const _AspectRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 108,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.type.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(child: RatingBar(value: value, label: label, onChanged: onChanged)),
          SizedBox(
            width: 24,
            child: Text(
              value == null ? '–' : '$value',
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              style: context.type.mono.copyWith(
                color: value == null ? colors.textTertiary : colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// §10 — the call you made before kickoff, graded against the final score.
///
/// Deliberately NOT called a "prediction" in the UI: this app's entire promise
/// is that it never speaks the language of markets (§14.9), and a user's own
/// private guess is the one place that promise could be misread. The feature is
/// unchanged; only the vocabulary is the app's own.
class PredictionCard extends StatelessWidget {
  const PredictionCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final MatchPrediction p = note.prediction;
    final PredictionResult result = gradePrediction(p, note.header);

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.prediction,
            title: context.l10n.journalSectionPrediction,
            subtitle: context.l10n.journalPredictionHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _ScoreStepper(
                  label: context.l10n.journalPredictionHomeScore,
                  value: p.homeScore,
                  onChanged: (int v) => controller.setPrediction(p.copyWith(homeScore: v)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ScoreStepper(
                  label: context.l10n.journalPredictionAwayScore,
                  value: p.awayScore,
                  onChanged: (int v) => controller.setPrediction(p.copyWith(awayScore: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(context.l10n.journalPredictionWinner,
              style: context.type.label.copyWith(color: colors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              for (final MatchOutcome outcome in MatchOutcome.values) ...<Widget>[
                Expanded(
                  child: _OutcomeButton(
                    label: outcome.label(context.l10n),
                    selected: p.winner == outcome,
                    onTap: () => controller.setPrediction(
                      p.winner == outcome
                          ? p.copyWith(clearWinner: true)
                          : p.copyWith(winner: outcome),
                    ),
                  ),
                ),
                if (outcome != MatchOutcome.away) const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: p.firstScorer ?? '',
            label: context.l10n.journalPredictionFirstScorer,
            maxLength: 60,
            onChanged: (String v) => controller.setPrediction(p.copyWith(firstScorer: v)),
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: p.manOfTheMatch ?? '',
            label: context.l10n.journalPredictionMotm,
            maxLength: 60,
            onChanged: (String v) => controller.setPrediction(p.copyWith(manOfTheMatch: v)),
          ),
          if (!p.isEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            _PredictionResultBlock(result: result),
          ],
        ],
      ),
    );
  }
}

class _PredictionResultBlock extends StatelessWidget {
  const _PredictionResultBlock({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;

    String scoreOf(int? home, int? away) => '${home ?? '–'}–${away ?? '–'}';
    final String called = scoreOf(result.predictedHome, result.predictedAway);
    final String actual = scoreOf(result.actualHome, result.actualAway);

    final String headline = switch (result.verdict) {
      PredictionVerdict.exact => context.l10n.journalPredictionExact,
      PredictionVerdict.rightWinner =>
        context.l10n.journalPredictionRightWinner(called, actual),
      PredictionVerdict.missed =>
        context.l10n.journalPredictionMissed(called, actual),
      PredictionVerdict.pending => context.l10n.journalPredictionPending,
    };

    final Color tint = switch (result.verdict) {
      PredictionVerdict.exact => colors.success,
      PredictionVerdict.rightWinner => colors.accent,
      PredictionVerdict.missed => colors.textSecondary,
      PredictionVerdict.pending => colors.textTertiary,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: colors.isDark ? 0.10 : 0.14),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: tint.withValues(alpha: 0.4), width: context.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                result.verdict == PredictionVerdict.exact
                    ? JournalIcons.motm
                    : JournalIcons.prediction,
                size: 18,
                color: tint,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.journalPredictionResult,
                  style: context.type.label.copyWith(color: colors.textSecondary),
                ),
              ),
              if (result.verdict != PredictionVerdict.pending)
                Text(
                  context.l10n.journalPredictionAccuracy('${result.accuracy}/100'),
                  style: context.type.mono.copyWith(color: tint),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            bidiIsolate(headline),
            style: context.type.bodyLarge.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// A 0–9 score picker. A stepper rather than a keyboard: two taps beat opening
/// a numeric keypad for a number that is almost always 0, 1 or 2.
class _ScoreStepper extends StatelessWidget {
  const _ScoreStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: context.type.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: colors.bg.withValues(alpha: colors.isDark ? 0.5 : 0.6),
            borderRadius: AppRadius.inputRadius,
            border: Border.all(color: colors.outline, width: context.hairline),
          ),
          child: Row(
            children: <Widget>[
              _StepButton(
                icon: Icons.remove_rounded,
                semanticsLabel: label,
                onTap: () => onChanged(((value ?? 0) - 1).clamp(0, 9)),
              ),
              Expanded(
                child: Text(
                  value == null ? '–' : '$value',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  style: context.type.scoreLarge.copyWith(color: colors.textPrimary),
                ),
              ),
              _StepButton(
                icon: Icons.add_rounded,
                semanticsLabel: label,
                onTap: () => onChanged(((value ?? -1) + 1).clamp(0, 9)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semanticsLabel,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 20, color: context.colors.textSecondary),
          ),
        ),
      );
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colors.accentFill.withValues(alpha: colors.isDark ? 0.18 : 0.28)
                : Colors.transparent,
            borderRadius: AppRadius.ctaRadius,
            border: Border.all(
              color: selected ? colors.accent : colors.outline,
              width: selected ? 1.5 : context.hairline,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.label.copyWith(
              color: selected ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// §16 — statistics the user noted by hand.
class StatsCard extends StatelessWidget {
  const StatsCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) => JournalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            JournalSectionHeader(
              icon: JournalIcons.stats,
              title: context.l10n.journalSectionStats,
              trailing: JournalTextAction(
                label: context.l10n.journalStatAdd,
                icon: MarmaIcons.add,
                onPressed: () => _edit(context, null),
              ),
            ),
            if (note.statistics.isEmpty)
              JournalCardEmpty(message: context.l10n.journalStatsEmpty)
            else ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              for (final CustomStat stat in note.statistics)
                _StatRow(stat: stat, onTap: () => _edit(context, stat)),
            ],
          ],
        ),
      );

  Future<void> _edit(BuildContext context, CustomStat? existing) async {
    final CustomStat? result = await showJournalFormSheet<CustomStat>(
      context: context,
      title: existing == null
          ? context.l10n.journalStatAdd
          : context.l10n.journalStatEdit,
      deleteLabel: existing == null ? null : context.l10n.journalRemove,
      onDelete: existing == null ? null : () => controller.removeStat(existing.id),
      builder: (BuildContext context, void Function(CustomStat) submit) =>
          _StatForm(existing: existing, submit: submit),
    );
    if (result != null) controller.upsertStat(result);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.stat, required this.onTap});

  final CustomStat stat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              stat.label,
              style: context.type.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              textDirection: TextDirection.ltr,
              children: <Widget>[
                Text(stat.homeValue,
                    style: context.type.mono.copyWith(color: colors.textPrimary)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Container(height: context.hairline, color: colors.outline),
                  ),
                ),
                Text(stat.awayValue,
                    style: context.type.mono.copyWith(color: colors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatForm extends StatefulWidget {
  const _StatForm({required this.existing, required this.submit});

  final CustomStat? existing;
  final void Function(CustomStat) submit;

  @override
  State<_StatForm> createState() => _StatFormState();
}

class _StatFormState extends State<_StatForm> {
  late final TextEditingController _label =
      TextEditingController(text: widget.existing?.label ?? '');
  late final TextEditingController _home =
      TextEditingController(text: widget.existing?.homeValue ?? '');
  late final TextEditingController _away =
      TextEditingController(text: widget.existing?.awayValue ?? '');

  @override
  void dispose() {
    _label.dispose();
    _home.dispose();
    _away.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final List<String> presets = <String>[
      context.l10n.journalStatPossession,
      context.l10n.journalStatShots,
      context.l10n.journalStatShotsOnTarget,
      context.l10n.journalStatCorners,
      context.l10n.journalStatBigChances,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final String preset in presets)
              ActionChip(
                label: Text(preset,
                    style: context.type.label.copyWith(color: colors.textSecondary)),
                backgroundColor: colors.surfaceHigh,
                side: BorderSide(color: colors.outline, width: context.hairline),
                onPressed: () => setState(() => _label.text = preset),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        JournalField(
          controller: _label,
          label: context.l10n.journalStatLabel,
          maxLength: 40,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: JournalField(
                controller: _home,
                label: context.l10n.journalStatHome,
                maxLength: 12,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: JournalField(
                controller: _away,
                label: context.l10n.journalStatAway,
                maxLength: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.ctaFill,
            foregroundColor: colors.onCta,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () {
            final String label = _label.text.trim();
            if (label.isEmpty) return;
            widget.submit(
              CustomStat(
                id: widget.existing?.id ?? journalId('s'),
                label: label,
                homeValue: _home.text.trim(),
                awayValue: _away.text.trim(),
              ),
            );
          },
          child: Text(context.l10n.journalSave, style: context.type.label),
        ),
      ],
    );
  }
}
