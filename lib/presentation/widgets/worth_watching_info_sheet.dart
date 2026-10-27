import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/marma_button.dart';

/// The plain-language explanation of the ordering.
///
/// This is the artifact App Review is pointed at. It is reachable from the
/// module header AND from Settings -> About, so the path cited in the review
/// notes is stable: Settings -> About -> "How 'Worth watching' is ordered".
///
/// A modal sheet, not a screen — the same pattern as `showMatchActionsSheet`,
/// which also has no route. The "every screen has a route" rule is intact.
Future<void> showWorthWatchingInfoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: context.colors.surface,
    barrierColor: context.colors.scrim,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) => const _WorthWatchingInfoSheet(),
  );
}

class _WorthWatchingInfoSheet extends StatelessWidget {
  const _WorthWatchingInfoSheet();

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    context.l10n.worthHowTitle,
                    style: context.type.titleMedium
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _Body(text: context.l10n.worthHowBody1),
                _Body(text: context.l10n.worthHowBody2),
                _Body(text: context.l10n.worthHowBody3, emphasis: true),
                const SizedBox(height: AppSpacing.sm),
                MarmaButton.secondary(
                  label: context.l10n.actionClose,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.text, this.emphasis = false});

  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: context.type.bodyMedium.copyWith(
          color: emphasis ? colors.textPrimary : colors.textSecondary,
        ),
      ),
    );
  }
}
