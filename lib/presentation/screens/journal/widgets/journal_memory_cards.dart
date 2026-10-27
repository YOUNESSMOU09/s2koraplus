import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/journal_l10n.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_chrome.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_icons.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_sheet.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/presentation/widgets/team_badge.dart';

/// §12 — "My football memory": where you were, and who with.
class MemoryCard extends StatelessWidget {
  const MemoryCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MatchMemory m = note.memory;
    final DateTime? watched = m.watchedAtLocal;

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.memory,
            title: context.l10n.journalSectionMemory,
            subtitle: context.l10n.journalMemoryQuestion,
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: m.story ?? '',
            label: context.l10n.journalSectionMemory,
            hint: context.l10n.journalMemoryStoryHint,
            maxLines: 4,
            maxLength: 600,
            onChanged: (String v) => controller.setMemory(m.copyWith(story: v)),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: JournalAutoField(
                  initialValue: m.location ?? '',
                  label: context.l10n.journalMemoryLocation,
                  maxLength: 60,
                  onChanged: (String v) => controller.setMemory(m.copyWith(location: v)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: JournalAutoField(
                  initialValue: m.people ?? '',
                  label: context.l10n.journalMemoryPeople,
                  maxLength: 80,
                  onChanged: (String v) => controller.setMemory(m.copyWith(people: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          JournalAutoField(
            initialValue: m.occasion ?? '',
            label: context.l10n.journalMemoryOccasion,
            maxLength: 80,
            onChanged: (String v) => controller.setMemory(m.copyWith(occasion: v)),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: JournalKeyValue(
                  label: context.l10n.journalMemoryDate,
                  value: watched == null
                      ? '–'
                      : AppFormat.longDate(watched, context.languageCode),
                ),
              ),
              JournalTextAction(
                label: context.l10n.journalMemoryPickDate,
                icon: MarmaIcons.season,
                onPressed: () => _pickDate(context, m),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, MatchMemory memory) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: memory.watchedAtLocal ?? now,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
    );
    if (picked == null) return;
    controller.setMemory(
      memory.copyWith(watchedAtMillis: picked.toUtc().millisecondsSinceEpoch),
    );
  }
}

/// §14 — man of the match, as a cinematic card.
class ManOfTheMatchCard extends StatelessWidget {
  const ManOfTheMatchCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final ManOfTheMatch? motm = note.manOfTheMatch;

    return JournalCard(
      accent: motm == null ? null : colors.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.motm,
            title: context.l10n.journalSectionMotm,
            trailing: JournalTextAction(
              label: motm == null
                  ? context.l10n.journalMotmSet
                  : context.l10n.journalMotmEdit,
              icon: motm == null ? MarmaIcons.add : null,
              onPressed: () => _edit(context, motm),
            ),
          ),
          if (motm == null)
            JournalCardEmpty(message: context.l10n.journalMotmEmpty)
          else ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                // No player photography exists anywhere in this app, so the
                // same deterministic monogram that stands in for a crest stands
                // in for a portrait.
                TeamBadge(
                  teamId: motm.player,
                  teamName: motm.player,
                  size: TeamBadgeSize.lg,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bidiIsolate(motm.player),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.titleLarge
                            .copyWith(color: colors.textPrimary, fontSize: 20),
                      ),
                      if (motm.ratingOutOfTen != null)
                        Text(
                          context.l10n.journalRatingOutOf(
                              motm.ratingOutOfTen!.toStringAsFixed(1)),
                          textDirection: TextDirection.ltr,
                          style: context.type.mono.copyWith(color: colors.accent),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if ((motm.reason ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                motm.reason!,
                style: context.type.bodyLarge.copyWith(color: colors.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, ManOfTheMatch? existing) async {
    final ManOfTheMatch? result = await showJournalFormSheet<ManOfTheMatch>(
      context: context,
      title: context.l10n.journalSectionMotm,
      deleteLabel: existing == null ? null : context.l10n.journalRemove,
      onDelete: existing == null ? null : () => controller.setManOfTheMatch(null),
      builder: (BuildContext context, void Function(ManOfTheMatch) submit) =>
          _MotmForm(existing: existing, submit: submit),
    );
    if (result != null) controller.setManOfTheMatch(result);
  }
}

class _MotmForm extends StatefulWidget {
  const _MotmForm({required this.existing, required this.submit});

  final ManOfTheMatch? existing;
  final void Function(ManOfTheMatch) submit;

  @override
  State<_MotmForm> createState() => _MotmFormState();
}

class _MotmFormState extends State<_MotmForm> {
  late final TextEditingController _player =
      TextEditingController(text: widget.existing?.player ?? '');
  late final TextEditingController _reason =
      TextEditingController(text: widget.existing?.reason ?? '');
  late int _rating = widget.existing?.rating ?? 90;

  @override
  void dispose() {
    _player.dispose();
    _reason.dispose();
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
          label: context.l10n.journalMotmPlayer,
          autofocus: widget.existing == null,
          maxLength: 60,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Text(context.l10n.journalMotmRating,
                style: context.type.label.copyWith(color: colors.textTertiary)),
            const Spacer(),
            Text(
              context.l10n.journalRatingOutOf((_rating / 10).toStringAsFixed(1)),
              textDirection: TextDirection.ltr,
              style: context.type.mono.copyWith(color: colors.accent),
            ),
          ],
        ),
        Slider(
          value: _rating.toDouble(),
          min: 10,
          max: 100,
          divisions: 18,
          activeColor: colors.accent,
          label: (_rating / 10).toStringAsFixed(1),
          onChanged: (double v) => setState(() => _rating = v.round()),
        ),
        const SizedBox(height: AppSpacing.sm),
        JournalField(
          controller: _reason,
          label: context.l10n.journalMotmReason,
          hint: context.l10n.journalMotmReasonHint,
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
              ManOfTheMatch(
                player: player,
                rating: _rating,
                reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
              ),
            );
          },
          child: Text(context.l10n.journalSave, style: context.type.label),
        ),
      ],
    );
  }
}

/// §18 — the rewatch counter.
class RewatchCard extends StatelessWidget {
  const RewatchCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final DateTime? first = note.firstWatchedLocal;
    final DateTime? last = note.lastWatchedLocal;

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.rewatch,
            title: context.l10n.journalSectionRewatch,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.journalWatchedTimes(note.watchedCount),
            style: context.type.titleLarge.copyWith(color: colors.textPrimary, fontSize: 22),
          ),
          if (first != null || last != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                if (first != null)
                  Expanded(
                    child: JournalKeyValue(
                      label: context.l10n.journalFirstWatched,
                      value: AppFormat.shortDate(first, context.languageCode),
                    ),
                  ),
                if (last != null)
                  Expanded(
                    child: JournalKeyValue(
                      label: context.l10n.journalLastWatched,
                      value: AppFormat.shortDate(last, context.languageCode),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: JournalTextAction(
              label: context.l10n.journalWatchAgain,
              icon: MarmaIcons.add,
              onPressed: controller.watchedAgain,
            ),
          ),
        ],
      ),
    );
  }
}

/// §15 — everything the user did, newest first.
class ActivityCard extends StatelessWidget {
  const ActivityCard({required this.note, super.key});

  final FootballNote note;

  /// Enough to show the shape of the session without turning the page into a
  /// log file; the model keeps more than this on disk.
  static const int visible = 12;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final List<JournalActivity> entries =
        note.activity.take(visible).toList(growable: false);
    if (entries.isEmpty) return const SizedBox.shrink();

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.activity,
            title: context.l10n.journalSectionActivity,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final JournalActivity entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(JournalIcons.activityKind(entry.kind),
                      size: 16, color: colors.textTertiary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      bidiIsolate(entry.kind.label(context.l10n, entry.detail)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.bodyMedium.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    AppFormat.kickoffTime(entry.atLocal),
                    style: context.type.monoSmall.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
