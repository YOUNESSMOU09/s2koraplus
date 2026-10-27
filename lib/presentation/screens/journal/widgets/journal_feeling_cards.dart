import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/services/mood_meter.dart';
import 'package:marma/domain/services/reaction_meter.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/journal_l10n.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_chrome.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_icons.dart';
import 'package:marma/presentation/screens/journal/widgets/verdict_style.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// §3 — match reaction, as a verdict meter.
///
/// Reactions split into the good and the bad, text only. Each carries a score,
/// and a red-to-green meter shows where the picks add up, with a one-word
/// verdict. The stored data is the same `Set<ReactionKind>` as ever.
class ReactionsCard extends StatelessWidget {
  const ReactionsCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    Widget row(String title, Color tint, bool positive) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: context.type.label.copyWith(color: tint, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Wrap(
              spacing: AppSpacing.xs + 2,
              runSpacing: AppSpacing.xs + 2,
              children: <Widget>[
                for (final ReactionKind r in ReactionKind.values)
                  if (r.isPositive == positive)
                    _TintPill(
                      label: r.label(context.l10n),
                      tint: tint,
                      selected: note.reactions.contains(r),
                      onTap: () => controller.toggleReaction(r),
                    ),
              ],
            ),
          ],
        );

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.reactions,
            title: context.l10n.journalSectionReactions,
            subtitle: context.l10n.journalReactionsHint,
          ),
          const SizedBox(height: AppSpacing.md),
          _VerdictMeter(reactions: note.reactions),
          const SizedBox(height: AppSpacing.lg),
          row(context.l10n.journalReactionGood, colors.success, true),
          const SizedBox(height: AppSpacing.md),
          row(context.l10n.journalReactionBad, colors.danger, false),
        ],
      ),
    );
  }
}

/// A red → amber → green bar with a marker at the reactions' average. Bad sits
/// at the start edge, so the meter reads in the layout's direction.
class _VerdictMeter extends StatelessWidget {
  const _VerdictMeter({required this.reactions});

  final Set<ReactionKind> reactions;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final double? t = reactionTemperature(reactions);
    final MatchVerdict? verdict = verdictFor(reactions);
    final Color ink = t == null
        ? colors.textTertiary
        : Color.lerp(
            t < 0.5 ? colors.danger : colors.warning,
            t < 0.5 ? colors.warning : colors.success,
            t < 0.5 ? t * 2 : (t - 0.5) * 2,
          )!;
    final Duration motion = AppMotion.enabled(context) ? AppMotion.slow : Duration.zero;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceHighest.withValues(alpha: 0.6),
        borderRadius: AppRadius.ctaRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (verdict != null) ...<Widget>[
            Text(
              context.l10n.journalVerdict(verdictName(context, verdict)),
              style: context.type.label.copyWith(color: ink, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          SizedBox(
            height: 16,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.chipRadius,
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: <Color>[
                        colors.danger.withValues(alpha: t == null ? 0.25 : 1),
                        colors.warning.withValues(alpha: t == null ? 0.25 : 1),
                        colors.success.withValues(alpha: t == null ? 0.25 : 1),
                      ],
                    ),
                  ),
                ),
                if (t != null)
                  AnimatedAlign(
                    duration: motion,
                    curve: AppMotion.emphasis,
                    alignment: AlignmentDirectional(t * 2 - 1, 0),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: ink, width: 4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Text(
                context.l10n.journalVerdictForgettable,
                style: context.type.label.copyWith(color: colors.textTertiary, fontSize: 11),
              ),
              const Spacer(),
              Text(
                context.l10n.journalVerdictClassic,
                style: context.type.label.copyWith(color: colors.textTertiary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// §11 — the watcher's own mood, as a mood meter.
///
/// Moods sit on a 2×2 grid of energy × feeling instead of a flat list, and
/// the card names the overall "vibe" from the quadrant picked most. Text
/// pills only; the stored data is the same `Set<MoodKind>` as ever.
class MoodCard extends StatelessWidget {
  const MoodCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MoodQuadrant? vibe = dominantQuadrant(note.moods);
    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.mood,
            title: context.l10n.journalSectionMood,
            subtitle: context.l10n.journalMoodHint,
          ),
          const SizedBox(height: AppSpacing.md),
          _VibeLine(vibe: vibe),
          const SizedBox(height: AppSpacing.md),
          for (final List<MoodQuadrant> row in const <List<MoodQuadrant>>[
            <MoodQuadrant>[MoodQuadrant.electric, MoodQuadrant.tense],
            <MoodQuadrant>[MoodQuadrant.content, MoodQuadrant.flat],
          ]) ...<Widget>[
            if (row.first == MoodQuadrant.content) const SizedBox(height: AppSpacing.sm),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: _Quadrant(quadrant: row[0], note: note, controller: controller)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _Quadrant(quadrant: row[1], note: note, controller: controller)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Color _quadrantColour(MarmaColors colors, MoodQuadrant q) => switch (q) {
      MoodQuadrant.electric => colors.warning,
      MoodQuadrant.tense => colors.danger,
      MoodQuadrant.content => colors.success,
      MoodQuadrant.flat => colors.accent,
    };

String _quadrantName(BuildContext context, MoodQuadrant q) => switch (q) {
      MoodQuadrant.electric => context.l10n.journalMoodElectric,
      MoodQuadrant.tense => context.l10n.journalMoodTense,
      MoodQuadrant.content => context.l10n.journalMoodContent,
      MoodQuadrant.flat => context.l10n.journalMoodFlat,
    };

String _quadrantHint(BuildContext context, MoodQuadrant q) => switch (q) {
      MoodQuadrant.electric => context.l10n.journalMoodElectricHint,
      MoodQuadrant.tense => context.l10n.journalMoodTenseHint,
      MoodQuadrant.content => context.l10n.journalMoodContentHint,
      MoodQuadrant.flat => context.l10n.journalMoodFlatHint,
    };

/// "Your vibe: Electric" once anything is picked; hidden until then.
class _VibeLine extends StatelessWidget {
  const _VibeLine({required this.vibe});

  final MoodQuadrant? vibe;

  @override
  Widget build(BuildContext context) {
    final MoodQuadrant? q = vibe;
    if (q == null) return const SizedBox.shrink();
    final MarmaColors colors = context.colors;
    final Color tint = _quadrantColour(colors, q);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: colors.isDark ? 0.16 : 0.1),
        borderRadius: AppRadius.ctaRadius,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.journalMoodVibe(_quadrantName(context, q)),
              style: context.type.label.copyWith(color: tint, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Quadrant extends StatelessWidget {
  const _Quadrant({required this.quadrant, required this.note, required this.controller});

  final MoodQuadrant quadrant;
  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color tint = _quadrantColour(colors, quadrant);
    final bool active = quadrant.moods.any(note.moods.contains);
    return AnimatedContainer(
      duration: AppMotion.quick,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: colors.isDark ? 0.10 : 0.06),
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: active ? tint : tint.withValues(alpha: 0.18),
          width: active ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _quadrantName(context, quadrant),
            style: context.type.titleMedium.copyWith(color: tint, fontSize: 15),
          ),
          Text(
            _quadrantHint(context, quadrant),
            style: context.type.label.copyWith(color: colors.textTertiary, fontSize: 11),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs + 2,
            children: <Widget>[
              for (final MoodKind mood in quadrant.moods)
                _TintPill(
                  label: mood.label(context.l10n),
                  tint: tint,
                  selected: note.moods.contains(mood),
                  onTap: () => controller.toggleMood(mood),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TintPill extends StatelessWidget {
  const _TintPill({
    required this.label,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.journalSemanticsReaction(
        label,
        selected ? context.l10n.journalStateSelected : context.l10n.journalStateNotSelected,
      ),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.selectionClick());
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.emphasis,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
          decoration: BoxDecoration(
            color: selected ? tint : colors.surfaceHigh,
            borderRadius: AppRadius.chipRadius,
            border: Border.all(color: selected ? tint : colors.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selected) ...<Widget>[
                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  style: context.type.label.copyWith(
                    color: selected ? Colors.white : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// §13 — preset tags plus the user's own.
class TagsCard extends StatelessWidget {
  const TagsCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    // Anything stored that is not a `#preset` token is a tag the user typed.
    final List<String> custom = note.tags
        .where((String t) => PresetTag.fromToken(t) == null)
        .toList(growable: false);

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.tags,
            title: context.l10n.journalSectionTags,
            trailing: JournalTextAction(
              label: context.l10n.journalTagAdd,
              icon: MarmaIcons.add,
              onPressed: () => _addCustomTag(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final PresetTag tag in PresetTag.values)
                _TagChip(
                  label: tag.label(context.l10n),
                  selected: note.tags.contains(tag.token),
                  onTap: () => controller.toggleTag(tag.token),
                ),
              for (final String tag in custom)
                _TagChip(
                  label: tag,
                  selected: true,
                  custom: true,
                  onTap: () => controller.toggleTag(tag),
                ),
            ],
          ),
          if (note.tags.isEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.journalTagsEmpty,
              style: context.type.bodyMedium.copyWith(color: colors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addCustomTag(BuildContext context) async {
    final TextEditingController field = TextEditingController();
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final MarmaColors colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.surfaceHigh,
          title: Text(context.l10n.journalTagAdd,
              style: context.type.titleMedium.copyWith(color: colors.textPrimary)),
          content: TextField(
            controller: field,
            autofocus: true,
            maxLength: 24,
            textInputAction: TextInputAction.done,
            onSubmitted: (String v) => Navigator.of(context).pop(v),
            style: context.type.bodyLarge.copyWith(color: colors.textPrimary),
            cursorColor: colors.accent,
            decoration: const InputDecoration(counterText: ''),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.actionCancel,
                  style: context.type.label.copyWith(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(field.text),
              child: Text(context.l10n.journalSave,
                  style: context.type.label.copyWith(color: colors.accent)),
            ),
          ],
        );
      },
    );
    field.dispose();
    final String trimmed = (value ?? '').trim();
    // A custom tag may never start with `#`, or it could impersonate a preset.
    if (trimmed.isEmpty || trimmed.startsWith('#')) return;
    if (note.tags.contains(trimmed)) return;
    controller.toggleTag(trimmed);
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.custom = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? colors.accentFill.withValues(alpha: colors.isDark ? 0.16 : 0.26)
                : Colors.transparent,
            borderRadius: AppRadius.chipRadius,
            border: Border.all(
              color: selected ? colors.accent : colors.outline,
              width: selected ? 1.5 : context.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: context.type.label.copyWith(
                  color: selected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
              if (custom) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Icon(MarmaIcons.close, size: 14, color: colors.textTertiary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
