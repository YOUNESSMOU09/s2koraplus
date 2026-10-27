import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/journal_l10n.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_chrome.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_icons.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_sheet.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// A short id for a user-created row. Time-based, so it is unique per device
/// without pulling in a uuid dependency for something never seen off-device.
String journalId(String prefix) =>
    '$prefix${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

/// §6 — favourite moments, drawn as a vertical match timeline.
class MomentsCard extends StatelessWidget {
  const MomentsCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final List<FavouriteMoment> moments = note.sortedMoments;
    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.moments,
            title: context.l10n.journalSectionMoments,
            trailing: JournalTextAction(
              label: context.l10n.journalMomentAdd,
              icon: MarmaIcons.add,
              onPressed: () => _edit(context, null),
            ),
          ),
          if (moments.isEmpty)
            JournalCardEmpty(message: context.l10n.journalMomentsEmpty)
          else ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < moments.length; i++)
              _MomentRow(
                moment: moments[i],
                isLast: i == moments.length - 1,
                onTap: () => _edit(context, moments[i]),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, FavouriteMoment? existing) async {
    final FavouriteMoment? result = await showJournalFormSheet<FavouriteMoment>(
      context: context,
      title: existing == null
          ? context.l10n.journalMomentAdd
          : context.l10n.journalMomentEdit,
      deleteLabel: existing == null ? null : context.l10n.journalRemove,
      onDelete: existing == null ? null : () => controller.removeMoment(existing.id),
      builder: (BuildContext context, void Function(FavouriteMoment) submit) =>
          _MomentForm(existing: existing, submit: submit),
    );
    if (result != null) controller.upsertMoment(result);
  }
}

class _MomentRow extends StatelessWidget {
  const _MomentRow({required this.moment, required this.isLast, required this.onTap});

  final FavouriteMoment moment;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // The rail: a dot per moment, joined by a hairline.
            Column(
              children: <Widget>[
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accentFill.withValues(alpha: colors.isDark ? 0.16 : 0.26),
                    border: Border.all(color: colors.accent, width: context.hairline),
                  ),
                  child: Icon(JournalIcons.moment(moment.glyph),
                      size: 16, color: colors.accent),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: context.hairline, color: colors.outline),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (moment.clockLabel.isNotEmpty) ...<Widget>[
                          Text(
                            bidiIsolate(moment.clockLabel),
                            textDirection: TextDirection.ltr,
                            style: context.type.mono.copyWith(color: colors.accent),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            moment.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.titleMedium
                                .copyWith(color: colors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    if ((moment.description ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Text(
                          moment.description!,
                          style: context.type.bodyMedium
                              .copyWith(color: colors.textSecondary),
                        ),
                      ),
                    if ((moment.player ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxs),
                        child: Text(
                          bidiIsolate(moment.player),
                          style: context.type.monoSmall
                              .copyWith(color: colors.textTertiary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MomentForm extends StatefulWidget {
  const _MomentForm({required this.existing, required this.submit});

  final FavouriteMoment? existing;
  final void Function(FavouriteMoment) submit;

  @override
  State<_MomentForm> createState() => _MomentFormState();
}

class _MomentFormState extends State<_MomentForm> {
  static final List<String> _glyphs = JournalIcons.momentKeys.keys.toList(growable: false);

  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _player =
      TextEditingController(text: widget.existing?.player ?? '');
  late final TextEditingController _minute =
      TextEditingController(text: widget.existing?.minute?.toString() ?? '');
  late final TextEditingController _second =
      TextEditingController(text: widget.existing?.second?.toString() ?? '');

  late String _glyph = JournalIcons.momentKey(widget.existing?.glyph);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _player.dispose();
    _minute.dispose();
    _second.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final String glyph in _glyphs)
              _GlyphButton(
                glyph: glyph,
                selected: glyph == _glyph,
                onTap: () => setState(() => _glyph = glyph),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        JournalField(
          controller: _title,
          label: context.l10n.journalMomentTitle,
          hint: context.l10n.journalMomentTitleHint,
          autofocus: widget.existing == null,
          maxLength: 80,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: JournalField(
                controller: _minute,
                label: context.l10n.journalMomentMinute,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: JournalField(
                controller: _second,
                label: context.l10n.journalMomentSecond,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        JournalField(
          controller: _description,
          label: context.l10n.journalMomentDescription,
          hint: context.l10n.journalMomentDescriptionHint,
          maxLines: 4,
          maxLength: 400,
        ),
        const SizedBox(height: AppSpacing.md),
        JournalField(
          controller: _player,
          label: context.l10n.journalMomentPlayer,
          maxLength: 60,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.ctaFill,
            foregroundColor: colors.onCta,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () {
            final String title = _title.text.trim();
            if (title.isEmpty) return;
            widget.submit(
              FavouriteMoment(
                id: widget.existing?.id ?? journalId('m'),
                title: title,
                minute: int.tryParse(_minute.text.trim())?.clamp(0, 130),
                second: int.tryParse(_second.text.trim())?.clamp(0, 59),
                description:
                    _description.text.trim().isEmpty ? null : _description.text.trim(),
                player: _player.text.trim().isEmpty ? null : _player.text.trim(),
                glyph: _glyph,
              ),
            );
          },
          child: Text(context.l10n.journalSave, style: context.type.label),
        ),
      ],
    );
  }
}

class _GlyphButton extends StatelessWidget {
  const _GlyphButton({
    required this.glyph,
    required this.selected,
    required this.onTap,
  });

  final String glyph;
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
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colors.accentFill.withValues(alpha: colors.isDark ? 0.18 : 0.28)
                : colors.surfaceHigh,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: selected ? colors.accent : colors.outline,
              width: selected ? 1.5 : context.hairline,
            ),
          ),
          child: Icon(JournalIcons.moment(glyph),
              size: 22, color: selected ? colors.accent : colors.textSecondary),
        ),
      ),
    );
  }
}

/// §7 — the goal timeline: a 0–90 axis with the user's own markers on it.
class MatchTimelineCard extends StatelessWidget {
  const MatchTimelineCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final List<JournalMatchEvent> events = note.sortedEvents;
    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.timeline,
            title: context.l10n.journalSectionEvents,
            trailing: JournalTextAction(
              label: context.l10n.journalEventAdd,
              icon: MarmaIcons.add,
              onPressed: () => _edit(context, null),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _Axis(events: events),
          if (events.isEmpty)
            JournalCardEmpty(message: context.l10n.journalEventsEmpty)
          else
            for (final JournalMatchEvent event in events)
              _EventRow(event: event, onTap: () => _edit(context, event)),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, JournalMatchEvent? existing) async {
    final JournalMatchEvent? result = await showJournalFormSheet<JournalMatchEvent>(
      context: context,
      title: existing == null
          ? context.l10n.journalEventAdd
          : context.l10n.journalEventEdit,
      deleteLabel: existing == null ? null : context.l10n.journalRemove,
      onDelete: existing == null ? null : () => controller.removeEvent(existing.id),
      builder: (BuildContext context, void Function(JournalMatchEvent) submit) =>
          _EventForm(existing: existing, submit: submit),
    );
    if (result != null) controller.upsertEvent(result);
  }
}

/// `0' ───── 45' ───── 90'` with a marker per event.
class _Axis extends StatelessWidget {
  const _Axis({required this.events});

  final List<JournalMatchEvent> events;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 34,
            // Forced LTR: a match clock runs 0 → 90 in every locale, and the
            // markers are positioned by minute, not by reading order.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      // `start` inside the forced-LTR subtree above IS left,
                      // and it keeps the RTL guard (§ rtl_test) honest: the
                      // codebase has exactly one positioning idiom.
                      PositionedDirectional(
                        start: 0,
                        end: 0,
                        top: 24,
                        child: Container(height: 2, color: colors.outline),
                      ),
                      for (final int mark in <int>[0, 45, 90])
                        PositionedDirectional(
                          start: (width - 24) * (mark / 90),
                          top: 24,
                          child: Container(width: 2, height: 8, color: colors.outlineStrong),
                        ),
                      for (final JournalMatchEvent event in events)
                        PositionedDirectional(
                          start: (width - 24) * (event.minute.clamp(0, 90) / 90),
                          top: 0,
                          child: Icon(JournalIcons.eventKind(event.kind),
                              size: 18, color: JournalIcons.eventTint(event.kind, colors)),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (final String label in <String>['0', '45', '90'])
                  Text(label,
                      style: context.type.monoSmall.copyWith(color: colors.textTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.onTap});

  final JournalMatchEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 44,
              child: Text(
                bidiIsolate(event.minuteLabel),
                textDirection: TextDirection.ltr,
                style: context.type.mono.copyWith(color: colors.accent),
              ),
            ),
            Icon(JournalIcons.eventKind(event.kind),
                size: 18, color: JournalIcons.eventTint(event.kind, colors)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                bidiIsolate(
                    (event.label ?? '').isEmpty ? event.kind.label(context.l10n) : event.label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.type.bodyLarge.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventForm extends StatefulWidget {
  const _EventForm({required this.existing, required this.submit});

  final JournalMatchEvent? existing;
  final void Function(JournalMatchEvent) submit;

  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  late final TextEditingController _minute =
      TextEditingController(text: widget.existing?.minute.toString() ?? '');
  late final TextEditingController _extra =
      TextEditingController(text: widget.existing?.extra?.toString() ?? '');
  late final TextEditingController _label =
      TextEditingController(text: widget.existing?.label ?? '');

  late JournalEventKind _kind = widget.existing?.kind ?? JournalEventKind.goal;

  @override
  void dispose() {
    _minute.dispose();
    _extra.dispose();
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(context.l10n.journalEventKind,
            style: context.type.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final JournalEventKind kind in JournalEventKind.values)
              GlyphChip(
                icon: JournalIcons.eventKind(kind),
                iconColor: kind == JournalEventKind.yellowCard || kind == JournalEventKind.redCard
                    ? JournalIcons.eventTint(kind, colors)
                    : null,
                label: kind.label(context.l10n),
                selected: kind == _kind,
                onTap: () => setState(() => _kind = kind),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: JournalField(
                controller: _minute,
                label: context.l10n.journalEventMinute,
                keyboardType: TextInputType.number,
                autofocus: widget.existing == null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: JournalField(
                controller: _extra,
                label: context.l10n.journalEventExtra,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        JournalField(
          controller: _label,
          label: context.l10n.journalEventLabel,
          maxLength: 60,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.ctaFill,
            foregroundColor: colors.onCta,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () => widget.submit(
            JournalMatchEvent(
              id: widget.existing?.id ?? journalId('e'),
              kind: _kind,
              minute: (int.tryParse(_minute.text.trim()) ?? 0).clamp(0, 130),
              extra: int.tryParse(_extra.text.trim())?.clamp(0, 30),
              label: _label.text.trim().isEmpty ? null : _label.text.trim(),
              forHome: widget.existing?.forHome ?? true,
            ),
          ),
          child: Text(context.l10n.journalSave, style: context.type.label),
        ),
      ],
    );
  }
}

/// §8 — the favourite goal, as a cinematic card.
class FavouriteGoalCard extends StatelessWidget {
  const FavouriteGoalCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final FavouriteGoal? goal = note.favouriteGoal;

    return JournalCard(
      accent: goal == null ? null : colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.goal,
            title: context.l10n.journalSectionFavouriteGoal,
            trailing: JournalTextAction(
              label: goal == null
                  ? context.l10n.journalFavouriteGoalSet
                  : context.l10n.journalFavouriteGoalEdit,
              icon: goal == null ? MarmaIcons.add : null,
              onPressed: () => _edit(context, goal),
            ),
          ),
          if (goal == null)
            JournalCardEmpty(message: context.l10n.journalFavouriteGoalEmpty)
          else ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: colors.isDark ? 0.18 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(JournalIcons.goalKind(goal.kind), size: 26, color: colors.accent),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bidiIsolate(goal.player),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.titleLarge
                            .copyWith(color: colors.textPrimary, fontSize: 22),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        <String>[
                          goal.kind.label(context.l10n),
                          if (goal.minute != null) "${goal.minute}'",
                        ].join(' · '),
                        style: context.type.label.copyWith(color: colors.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((goal.description ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                goal.description!,
                style: context.type.bodyLarge.copyWith(
                  color: colors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, FavouriteGoal? existing) async {
    final FavouriteGoal? result = await showJournalFormSheet<FavouriteGoal>(
      context: context,
      title: context.l10n.journalSectionFavouriteGoal,
      deleteLabel: existing == null ? null : context.l10n.journalRemove,
      onDelete: existing == null ? null : () => controller.setFavouriteGoal(null),
      builder: (BuildContext context, void Function(FavouriteGoal) submit) =>
          _GoalForm(existing: existing, submit: submit),
    );
    if (result != null) controller.setFavouriteGoal(result);
  }
}

class _GoalForm extends StatefulWidget {
  const _GoalForm({required this.existing, required this.submit});

  final FavouriteGoal? existing;
  final void Function(FavouriteGoal) submit;

  @override
  State<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<_GoalForm> {
  late final TextEditingController _player =
      TextEditingController(text: widget.existing?.player ?? '');
  late final TextEditingController _minute =
      TextEditingController(text: widget.existing?.minute?.toString() ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');

  late GoalKind _kind = widget.existing?.kind ?? GoalKind.teamGoal;

  @override
  void dispose() {
    _player.dispose();
    _minute.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        JournalField(
          controller: _player,
          label: context.l10n.journalFavouriteGoalPlayer,
          autofocus: widget.existing == null,
          maxLength: 60,
        ),
        const SizedBox(height: AppSpacing.md),
        JournalField(
          controller: _minute,
          label: context.l10n.journalFavouriteGoalMinute,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(context.l10n.journalFavouriteGoalKind,
            style: context.type.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            for (final GoalKind kind in GoalKind.values)
              GlyphChip(
                icon: JournalIcons.goalKind(kind),
                label: kind.label(context.l10n),
                selected: kind == _kind,
                onTap: () => setState(() => _kind = kind),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        JournalField(
          controller: _description,
          label: context.l10n.journalFavouriteGoalDescription,
          maxLines: 4,
          maxLength: 400,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.ctaFill,
            foregroundColor: colors.onCta,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () {
            final String player = _player.text.trim();
            if (player.isEmpty) return;
            widget.submit(
              FavouriteGoal(
                player: player,
                kind: _kind,
                minute: int.tryParse(_minute.text.trim())?.clamp(0, 130),
                description:
                    _description.text.trim().isEmpty ? null : _description.text.trim(),
              ),
            );
          },
          child: Text(context.l10n.journalSave, style: context.type.label),
        ),
      ],
    );
  }
}
