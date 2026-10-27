import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_chrome.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_icons.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_markdown.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// §2 — the main editor.
///
/// The controller is owned by the screen, not by this widget, so a rebuild
/// (autosave landing, header refreshing, a rating changing) can never reset the
/// cursor or drop a keystroke. This widget only reports text upward.
class JournalNoteCard extends StatefulWidget {
  const JournalNoteCard({
    required this.controller,
    required this.focusNode,
    required this.note,
    required this.save,
    required this.savedAt,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FootballNote note;
  final SaveState save;
  final DateTime? savedAt;
  final ValueChanged<String> onChanged;

  @override
  State<JournalNoteCard> createState() => _JournalNoteCardState();
}

class _JournalNoteCardState extends State<JournalNoteCard> {
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final FootballNote note = widget.note;

    final String hint = switch (note.targetType) {
      JournalTargetType.match => context.l10n.journalNoteHintMatch,
      JournalTargetType.team => context.l10n.journalNoteHintTeam,
      JournalTargetType.player => context.l10n.journalNoteHintPlayer,
    };

    return JournalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          JournalSectionHeader(
            icon: JournalIcons.note,
            title: context.l10n.journalSectionNote,
            subtitle: context.l10n.journalNoteFormattingHint,
            trailing: note.note.trim().isEmpty
                ? null
                : IconButton(
                    icon: Icon(_preview ? MarmaIcons.journal : MarmaIcons.preview,
                        size: 20, color: colors.textSecondary),
                    tooltip: _preview
                        ? context.l10n.journalPreviewOff
                        : context.l10n.journalPreviewOn,
                    onPressed: () => setState(() => _preview = !_preview),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_preview)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.bg.withValues(alpha: colors.isDark ? 0.45 : 0.55),
                borderRadius: AppRadius.inputRadius,
                border: Border.all(color: colors.outline, width: context.hairline),
              ),
              child: JournalMarkdown(source: note.note),
            )
          else
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            maxLines: null,
            minLines: 6,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: context.type.bodyLarge.copyWith(
              color: colors.textPrimary,
              height: 1.55,
            ),
            cursorColor: colors.accent,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.type.bodyLarge.copyWith(color: colors.textTertiary),
              filled: true,
              fillColor: colors.bg.withValues(alpha: colors.isDark ? 0.45 : 0.55),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputRadius,
                borderSide: BorderSide(color: colors.outline, width: context.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.inputRadius,
                borderSide: BorderSide(color: colors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatusLine(note: note, save: widget.save, savedAt: widget.savedAt),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.note, required this.save, required this.savedAt});

  final FootballNote note;
  final SaveState save;
  final DateTime? savedAt;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;

    final String status = switch (save) {
      SaveState.pending => context.l10n.journalSaving,
      SaveState.saved => journalSavedLabel(context, savedAt),
      SaveState.idle => context.l10n.journalUnsaved,
    };

    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: save == SaveState.saved ? colors.success : colors.textTertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.monoSmall.copyWith(color: colors.textTertiary),
          ),
        ),
        Text(
          '${context.l10n.journalWordCount(note.wordCount)} · '
          '${context.l10n.journalCharacterCount(note.characterCount)}',
          style: context.type.monoSmall.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

/// "Saved just now" / "Saved at 21:40" — shared by the editor and the hero.
String journalSavedLabel(BuildContext context, DateTime? at) {
  if (at == null || DateTime.now().difference(at).inMinutes < 1) {
    return context.l10n.journalSavedJustNow;
  }
  return context.l10n.journalSavedAt(AppFormat.kickoffTime(at));
}
