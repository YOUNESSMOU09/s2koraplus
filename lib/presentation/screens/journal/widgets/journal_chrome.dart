import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';

/// The journal's own design atoms.
///
/// The journal is the one surface in the app that is a WORKSPACE rather than a
/// scoreboard, so it carries its own card, its own field and its own controls —
/// built from the same tokens as everything else (`MarmaColors`, `AppSpacing`,
/// `AppTypography`), never from raw hex or magic numbers.

/// The journal's card: the app-wide card surface with an optional accent
/// edge for the "cinematic" cards (favourite goal, man of the match).
class JournalCard extends StatelessWidget {
  const JournalCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.accent,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Tints the card's edge and a soft wash along its top.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color? tint = accent;
    BoxDecoration decoration = colors.card(hairline: context.hairline);
    if (tint != null) {
      decoration = decoration.copyWith(
        border: Border.all(color: tint.withValues(alpha: colors.isDark ? 0.45 : 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.alphaBlend(tint.withValues(alpha: 0.08), colors.surfaceHigh),
            colors.surfaceHigh,
          ],
        ),
      );
    }
    return DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Section heading: a glyph, a title, and an optional trailing action.
class JournalSectionHeader extends StatelessWidget {
  const JournalSectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: colors.isDark ? 0.16 : 0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 20, color: colors.accent),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: context.type.titleMedium.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: context.type.bodyMedium
                      .copyWith(color: colors.textTertiary, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A small text action used inside cards ("Add player", "Edit").
class JournalTextAction extends StatelessWidget {
  const JournalTextAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color tint = destructive ? colors.danger : colors.accent;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.chipRadius,
        child: Padding(
          // Keeps the tappable box at the 44 pt minimum even though the label
          // itself is only ~20 pt tall.
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: tint),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: context.type.label.copyWith(color: tint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled text field in the journal's voice.
class JournalField extends StatelessWidget {
  const JournalField({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.autofocus = false,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: context.type.label.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: 1,
          autofocus: autofocus,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          style: context.type.bodyLarge.copyWith(color: colors.textPrimary),
          cursorColor: colors.accent,
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: context.type.bodyLarge.copyWith(color: colors.textTertiary),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            filled: true,
            fillColor: colors.bg.withValues(alpha: colors.isDark ? 0.5 : 0.6),
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
      ],
    );
  }
}

/// A selectable chip carrying an emoji and a label. The pop on selection is
/// what makes the reaction row feel alive (§3).
class GlyphChip extends StatelessWidget {
  const GlyphChip({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.selected,
    required this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;

    Widget chip = AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.emphasis,
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: selected
            ? colors.accentFill.withValues(alpha: colors.isDark ? 0.18 : 0.28)
            : colors.surfaceHigh.withValues(alpha: colors.isDark ? 0.7 : 1),
        borderRadius: AppRadius.chipRadius,
        border: Border.all(
          color: selected ? colors.accent : colors.outline,
          width: selected ? 1.5 : context.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: iconColor ?? (selected ? colors.accent : colors.textSecondary)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: context.type.label.copyWith(
              color: selected ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (selected && AppMotion.enabled(context)) {
      // Keyed on selection so the pop replays each time it is turned on, and
      // never runs on a rebuild that did not change it.
      chip = chip
          .animate(key: ValueKey<String>('$label-on'))
          .scaleXY(begin: 0.88, end: 1, duration: AppMotion.base, curve: Curves.easeOutBack);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }
}

/// The 1–10 dial. A single 44 pt-tall bar of ten segments: tap or drag, and it
/// reads out as a slider to VoiceOver rather than as ten unlabelled buttons.
class RatingBar extends StatelessWidget {
  const RatingBar({
    required this.value,
    required this.onChanged,
    required this.label,
    this.tint,
    super.key,
  });

  /// 1–10, or null when the dial has never been set.
  final int? value;
  final ValueChanged<int> onChanged;
  final String label;
  final Color? tint;

  static const int steps = 10;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color fill = tint ?? colors.accent;

    return Semantics(
      slider: true,
      label: label,
      value: value == null ? context.l10n.journalRatingUnset : '$value',
      increasedValue: '${math.min((value ?? 0) + 1, steps)}',
      decreasedValue: '${math.max((value ?? 1) - 1, 1)}',
      onIncrease: () => onChanged(math.min((value ?? 0) + 1, steps)),
      onDecrease: () => onChanged(math.max((value ?? 1) - 1, 1)),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          void pick(Offset local) {
            final double width = constraints.maxWidth;
            if (width <= 0) return;
            final double x = context.isRtl ? width - local.dx : local.dx;
            final int step = (x / width * steps).ceil().clamp(1, steps);
            if (step != value) onChanged(step);
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails d) => pick(d.localPosition),
            onHorizontalDragUpdate: (DragUpdateDetails d) => pick(d.localPosition),
            child: SizedBox(
              height: 44,
              child: Row(
                children: <Widget>[
                  for (int i = 1; i <= steps; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.5),
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          height: value != null && i <= value! ? 26 : 14,
                          decoration: BoxDecoration(
                            color: value != null && i <= value!
                                ? Color.lerp(fill.withValues(alpha: 0.55), fill,
                                    i / steps)
                                : colors.surfaceHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The star strip that renders a 1–10 value (§4).
class StarStrip extends StatelessWidget {
  const StarStrip({required this.value, this.size = 14, super.key});

  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 1; i <= RatingBar.steps; i++)
          Icon(
            MarmaIcons.following,
            size: size,
            fill: i <= value ? 1 : 0,
            color: i <= value ? colors.accent : colors.outlineStrong,
          ),
      ],
    );
  }
}

/// One labelled row of the journal: a caption over a value.
class JournalKeyValue extends StatelessWidget {
  const JournalKeyValue({
    required this.label,
    required this.value,
    this.emphasis = false,
    super.key,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: context.type.label.copyWith(color: colors.textTertiary)),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: emphasis
              ? context.type.titleMedium.copyWith(color: colors.textPrimary)
              : context.type.bodyLarge.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }
}

/// Empty-state line inside a card — never a bare "nothing here".
class JournalCardEmpty extends StatelessWidget {
  const JournalCardEmpty({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          message,
          style: context.type.bodyMedium.copyWith(color: context.colors.textTertiary),
        ),
      );
}

/// A text field that owns its controller and reports every keystroke upward.
///
/// Inline journal fields (tactical, memory) are rebuilt by the very autosave
/// they trigger. Seeding the controller ONCE, in `initState`, is what keeps the
/// caret from jumping to position 0 mid-word — a `TextEditingController`
/// rebuilt from the model on every frame is the classic version of that bug.
class JournalAutoField extends StatefulWidget {
  const JournalAutoField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    super.key,
  });

  final String initialValue;
  final String label;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;

  @override
  State<JournalAutoField> createState() => _JournalAutoFieldState();
}

class _JournalAutoFieldState extends State<JournalAutoField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => JournalField(
        controller: _controller,
        label: widget.label,
        hint: widget.hint,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
      );
}
