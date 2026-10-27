import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_chrome.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_icons.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_sheet.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// §4 — your match rating: five dials and the experience score derived from
/// whichever of them you actually set.
class MatchRatingCard extends StatelessWidget {
  const MatchRatingCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final MatchRatings r = note.ratings;
    final double? experience = r.experience;

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.rating,
            title: context.l10n.journalSectionRating,
            trailing: r.isEmpty
                ? null
                : JournalTextAction(
                    label: context.l10n.journalRatingClear,
                    onPressed: () => controller.setRatings(MatchRatings.empty),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                r.overall == null ? '–' : '${r.overall}',
                style: context.type.displayScore.copyWith(color: colors.textPrimary),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.sm, start: AppSpacing.xs),
                child: Text(
                  '/10',
                  style: context.type.mono.copyWith(color: colors.textTertiary),
                ),
              ),
              const Spacer(),
              StarStrip(value: r.overall ?? 0, size: 16),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          RatingBar(
            value: r.overall,
            label: context.l10n.journalRatingOverall,
            onChanged: (int v) => controller.setRatings(
              r.copyWith(overall: v),
              detail: '$v/10',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _Dial(
            label: context.l10n.journalRatingHome,
            value: r.home,
            onChanged: (int v) => controller.setRatings(r.copyWith(home: v)),
          ),
          _Dial(
            label: context.l10n.journalRatingAway,
            value: r.away,
            onChanged: (int v) => controller.setRatings(r.copyWith(away: v)),
          ),
          _Dial(
            label: context.l10n.journalRatingReferee,
            value: r.referee,
            onChanged: (int v) => controller.setRatings(r.copyWith(referee: v)),
          ),
          _Dial(
            label: context.l10n.journalRatingAtmosphere,
            value: r.atmosphere,
            onChanged: (int v) => controller.setRatings(r.copyWith(atmosphere: v)),
          ),
          if (experience != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.accentFill.withValues(alpha: colors.isDark ? 0.12 : 0.22),
                borderRadius: AppRadius.cardRadius,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.l10n.journalRatingExperience,
                      style: context.type.label.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  Text(
                    context.l10n.journalRatingOutOf(experience.toStringAsFixed(1)),
                    textDirection: TextDirection.ltr,
                    style: context.type.mono.copyWith(color: colors.textPrimary),
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

class _Dial extends StatelessWidget {
  const _Dial({required this.label, required this.value, required this.onChanged});

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.type.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: RatingBar(value: value, label: label, onChanged: onChanged),
          ),
          SizedBox(
            width: 28,
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

/// §5 — player performance, sortable by rating.
class PlayerRatingsCard extends StatefulWidget {
  const PlayerRatingsCard({required this.note, required this.controller, super.key});

  final FootballNote note;
  final JournalController controller;

  @override
  State<PlayerRatingsCard> createState() => _PlayerRatingsCardState();
}

class _PlayerRatingsCardState extends State<PlayerRatingsCard> {
  bool _byRating = true;

  @override
  Widget build(BuildContext context) {
    final List<PlayerRating> players =
        _byRating ? widget.note.playersByRating : widget.note.playerRatings;

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.players,
            title: context.l10n.journalSectionPlayers,
            trailing: JournalTextAction(
              label: context.l10n.journalPlayerAdd,
              icon: MarmaIcons.add,
              onPressed: () => _edit(context, null),
            ),
          ),
          if (players.isEmpty)
            JournalCardEmpty(message: context.l10n.journalPlayersEmpty)
          else ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: JournalTextAction(
                label: _byRating
                    ? context.l10n.journalPlayerSortRating
                    : context.l10n.journalPlayerSortAdded,
                icon: MarmaIcons.manage,
                onPressed: () => setState(() => _byRating = !_byRating),
              ),
            ),
            for (final PlayerRating player in players)
              _PlayerRow(player: player, onTap: () => _edit(context, player)),
          ],
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, PlayerRating? existing) async {
    final PlayerRating? result = await showPlayerRatingSheet(
      context: context,
      existing: existing,
      onDelete: existing == null
          ? null
          : () => widget.controller.removePlayerRating(existing.id),
    );
    if (result != null) widget.controller.upsertPlayerRating(result);
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player, required this.onTap});

  final PlayerRating player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final List<(IconData, String)> stats = <(IconData, String)>[
      if (player.goals > 0) (JournalIcons.goal, '${player.goals}'),
      if (player.assists > 0) (JournalIcons.assists, '${player.assists}'),
      if (player.keyPasses > 0) (JournalIcons.keyPasses, '${player.keyPasses}'),
      if (player.defending != null) (JournalIcons.defending, '${player.defending}'),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.cardRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    bidiIsolate(player.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.titleMedium.copyWith(color: colors.textPrimary),
                  ),
                ),
                Icon(JournalIcons.star, size: 15, color: colors.accent),
                const SizedBox(width: 2),
                Text(
                  context.l10n.journalRatingOutOf(
                      player.ratingOutOfTen.toStringAsFixed(1)),
                  textDirection: TextDirection.ltr,
                  style: context.type.mono.copyWith(color: colors.accent),
                ),
              ],
            ),
            if (stats.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Wrap(
                  spacing: AppSpacing.md,
                  children: <Widget>[
                    for (final (IconData icon, String value) in stats)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(icon, size: 14, color: colors.textTertiary),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            value,
                            textDirection: TextDirection.ltr,
                            style: context.type.monoSmall.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            if ((player.comment ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxs),
                child: Text(
                  player.comment!,
                  style: context.type.bodyMedium.copyWith(color: colors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The add/edit player form.
Future<PlayerRating?> showPlayerRatingSheet({
  required BuildContext context,
  PlayerRating? existing,
  VoidCallback? onDelete,
}) {
  return showJournalFormSheet<PlayerRating>(
    context: context,
    title: existing == null
        ? context.l10n.journalPlayerAdd
        : context.l10n.journalPlayerEdit,
    deleteLabel: onDelete == null ? null : context.l10n.journalRemove,
    onDelete: onDelete,
    builder: (BuildContext context, void Function(PlayerRating) submit) =>
        _PlayerForm(existing: existing, submit: submit),
  );
}

class _PlayerForm extends StatefulWidget {
  const _PlayerForm({required this.existing, required this.submit});

  final PlayerRating? existing;
  final void Function(PlayerRating) submit;

  @override
  State<_PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<_PlayerForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _comment =
      TextEditingController(text: widget.existing?.comment ?? '');
  late final TextEditingController _goals =
      TextEditingController(text: '${widget.existing?.goals ?? 0}');
  late final TextEditingController _assists =
      TextEditingController(text: '${widget.existing?.assists ?? 0}');
  late final TextEditingController _keyPasses =
      TextEditingController(text: '${widget.existing?.keyPasses ?? 0}');

  late int _rating = widget.existing?.rating ?? 70;
  late int? _defending = widget.existing?.defending;

  @override
  void dispose() {
    _name.dispose();
    _comment.dispose();
    _goals.dispose();
    _assists.dispose();
    _keyPasses.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        JournalField(
          controller: _name,
          label: context.l10n.journalPlayerName,
          autofocus: widget.existing == null,
          textInputAction: TextInputAction.next,
          maxLength: 60,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: <Widget>[
            Text(
              context.l10n.journalPlayerRating,
              style: context.type.label.copyWith(color: colors.textTertiary),
            ),
            const Spacer(),
            Text(
              context.l10n.journalRatingOutOf((_rating / 10).toStringAsFixed(1)),
              textDirection: TextDirection.ltr,
              style: context.type.mono.copyWith(color: colors.accent),
            ),
          ],
        ),
        // Half-point resolution, because 8.5 is how football is actually rated.
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
        Row(
          children: <Widget>[
            Expanded(
              child: JournalField(
                controller: _goals,
                label: context.l10n.journalPlayerGoals,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: JournalField(
                controller: _assists,
                label: context.l10n.journalPlayerAssists,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: JournalField(
                controller: _keyPasses,
                label: context.l10n.journalPlayerKeyPasses,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.journalPlayerDefending,
          style: context.type.label.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xs),
        RatingBar(
          value: _defending,
          label: context.l10n.journalPlayerDefending,
          onChanged: (int v) => setState(() => _defending = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        JournalField(
          controller: _comment,
          label: context.l10n.journalPlayerComment,
          hint: context.l10n.journalPlayerCommentHint,
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
          onPressed: _submit,
          child: Text(context.l10n.journalSave, style: context.type.label),
        ),
      ],
    );
  }

  void _submit() {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      // An unnamed rating would be unreadable in the list; the field is the
      // only requirement in the whole journal.
      FocusScope.of(context).requestFocus(FocusNode());
      HapticFeedback.selectionClick();
      return;
    }
    widget.submit(
      PlayerRating(
        id: widget.existing?.id ??
            'p${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
        name: name,
        rating: _rating,
        goals: int.tryParse(_goals.text.trim()) ?? 0,
        assists: int.tryParse(_assists.text.trim()) ?? 0,
        keyPasses: int.tryParse(_keyPasses.text.trim()) ?? 0,
        defending: _defending,
        comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
      ),
    );
  }
}
