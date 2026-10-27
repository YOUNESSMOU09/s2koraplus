import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

enum MarmaButtonKind { primary, secondary, destructive }

/// The one button in the app. Height 52, radius 14, `label` at 15/600.
class MarmaButton extends StatefulWidget {
  const MarmaButton({
    required this.label,
    required this.onPressed,
    this.kind = MarmaButtonKind.primary,
    this.expand = true,
    this.icon,
    super.key,
  });

  const MarmaButton.secondary({
    required this.label,
    required this.onPressed,
    this.expand = true,
    this.icon,
    super.key,
  }) : kind = MarmaButtonKind.secondary;

  final String label;
  final VoidCallback? onPressed;
  final MarmaButtonKind kind;
  final bool expand;
  final Widget? icon;

  @override
  State<MarmaButton> createState() => _MarmaButtonState();
}

class _MarmaButtonState extends State<MarmaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final bool enabled = widget.onPressed != null;

    final Color fill = switch (widget.kind) {
      MarmaButtonKind.primary => colors.ctaFill,
      MarmaButtonKind.secondary => Colors.transparent,
      MarmaButtonKind.destructive => Colors.transparent,
    };
    final Color labelColour = switch (widget.kind) {
      MarmaButtonKind.primary => colors.onCta,
      MarmaButtonKind.secondary => colors.textPrimary,
      MarmaButtonKind.destructive => colors.danger,
    };

    final Widget content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.icon != null) ...<Widget>[
          IconTheme(
            data: IconThemeData(color: labelColour, size: 18),
            child: widget.icon!,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.type.label.copyWith(
              color: labelColour,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _pressed && AppMotion.enabled(context) ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: Container(
              height: 52,
              width: widget.expand ? double.infinity : null,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xl),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _pressed
                    ? Color.alphaBlend(colors.textPrimary.withValues(alpha: 0.08), fill)
                    : fill,
                borderRadius: AppRadius.ctaRadius,
                border: widget.kind == MarmaButtonKind.primary
                    ? null
                    : Border.all(color: colors.outlineStrong),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
