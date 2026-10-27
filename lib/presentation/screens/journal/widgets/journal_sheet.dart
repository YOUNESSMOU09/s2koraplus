import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/marma_button.dart';
import 'package:marma/service/interstitial_gate.dart';

/// Every "add / edit a thing" form in the journal is this one sheet: a title,
/// a scrolling body, and a single primary action pinned above the keyboard.
///
/// Returns the value the form built, or null when dismissed — so a caller never
/// has to distinguish "cancelled" from "saved nothing".
Future<T?> showJournalFormSheet<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext context, void Function(T value) submit) builder,
  String? deleteLabel,
  VoidCallback? onDelete,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => _JournalFormSheet<T>(
      title: title,
      builder: builder,
      deleteLabel: deleteLabel,
      onDelete: onDelete,
    ),
  );
}

class _JournalFormSheet<T> extends StatelessWidget {
  const _JournalFormSheet({
    required this.title,
    required this.builder,
    this.deleteLabel,
    this.onDelete,
  });

  final String title;
  final Widget Function(BuildContext context, void Function(T value) submit) builder;
  final String? deleteLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      // The keyboard inset, so the primary action is never under the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
                child: Text(
                  title,
                  style: context.type.titleMedium.copyWith(color: colors.textPrimary),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: builder(context, (T value) {
                    InterstitialGate.onAction('journal_form_save');
                    Navigator.of(context).pop(value);
                  }),
                ),
              ),
              if (onDelete != null && deleteLabel != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
                  child: MarmaButton(
                    label: deleteLabel!,
                    kind: MarmaButtonKind.destructive,
                    onPressed: () {
                      onDelete!();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one confirmation in the journal (§23): destructive, irreversible, local.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final MarmaColors colors = context.colors;
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: colors.surfaceHigh,
      title: Text(title,
          style: context.type.titleMedium.copyWith(color: colors.textPrimary)),
      content: Text(body,
          style: context.type.bodyMedium.copyWith(color: colors.textSecondary)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.actionCancel,
              style: context.type.label.copyWith(color: colors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel,
              style: context.type.label.copyWith(color: colors.danger)),
        ),
      ],
    ),
  );
  return result ?? false;
}
