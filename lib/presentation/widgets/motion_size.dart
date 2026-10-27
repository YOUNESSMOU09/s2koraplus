import 'package:flutter/material.dart';
import 'package:marma/presentation/theme/app_motion.dart';

/// `AnimatedSize`, but only when motion is actually on.
///
/// `AnimatedSize(duration: Duration.zero)` is a TRAP. With a zero duration its
/// controller completes synchronously inside `RenderAnimatedSize.performLayout`,
/// notifies its listener, and the listener calls `markNeedsLayout` on the very
/// render object being laid out:
///
///     A RenderAnimatedSize was mutated in its own performLayout implementation.
///
/// That is exactly the configuration Reduce Motion and every headless widget
/// test produce, so the naive "pass `Duration.zero` when motion is off" guard
/// analyses clean, compiles, and then throws on the first size change. Omitting
/// the widget entirely is the only correct way to switch it off.
class MotionSize extends StatelessWidget {
  const MotionSize({
    required this.enabled,
    required this.child,
    this.duration = AppMotion.base,
    this.curve = AppMotion.emphasis,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final bool enabled;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}
