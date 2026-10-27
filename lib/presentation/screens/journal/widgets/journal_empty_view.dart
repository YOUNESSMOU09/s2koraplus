import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/marma_button.dart';

/// §22 — the empty state.
///
/// The illustration is DRAWN, not shipped: no asset, no download, identical
/// offline, and it scales to any screen without a 3× export.
class JournalEmptyView extends StatelessWidget {
  const JournalEmptyView({required this.onStart, super.key});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final bool motion = AppMotion.enabled(context);

    Widget art = const _BallAndPen(size: 120);
    if (motion) {
      art = art
          .animate()
          .fadeIn(duration: AppMotion.bloom)
          .scaleXY(begin: 0.9, end: 1, curve: Curves.easeOutBack, duration: AppMotion.bloom);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl, vertical: AppSpacing.giant),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          art,
          const SizedBox(height: AppSpacing.xxl),
          Text(
            context.l10n.journalEmptyTitle,
            textAlign: TextAlign.center,
            style: context.type.titleLarge.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.journalEmptyBody,
            textAlign: TextAlign.center,
            style: context.type.bodyLarge.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          MarmaButton(
            label: context.l10n.journalEmptyAction,
            expand: false,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _BallAndPen extends StatelessWidget {
  const _BallAndPen({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BallPainter(
          ink: colors.textPrimary,
          accent: colors.accent,
          surface: colors.surfaceHighest,
        ),
      ),
    );
  }
}

class _BallPainter extends CustomPainter {
  const _BallPainter({required this.ink, required this.accent, required this.surface});

  final Color ink;
  final Color accent;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.34;

    // Floodlight halo.
    canvas.drawCircle(
      centre,
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[accent.withValues(alpha: 0.22), accent.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: centre, radius: size.width * 0.5)),
    );

    canvas.drawCircle(centre, radius, Paint()..color = surface);
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // The ball's centre pentagon and the seams radiating from it.
    final Path pentagon = Path();
    for (int i = 0; i < 5; i++) {
      final double angle = -1.5708 + i * 1.25664;
      final Offset point = centre +
          Offset(radius * 0.36 * math.cos(angle), radius * 0.36 * math.sin(angle));
      if (i == 0) {
        pentagon.moveTo(point.dx, point.dy);
      } else {
        pentagon.lineTo(point.dx, point.dy);
      }
    }
    pentagon.close();
    canvas.drawPath(pentagon, Paint()..color = ink.withValues(alpha: 0.85));

    final Paint seam = Paint()
      ..color = ink.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    for (int i = 0; i < 5; i++) {
      final double angle = -1.5708 + i * 1.25664 + 0.62832;
      canvas.drawLine(
        centre + Offset(radius * 0.42 * math.cos(angle), radius * 0.42 * math.sin(angle)),
        centre + Offset(radius * math.cos(angle), radius * math.sin(angle)),
        seam,
      );
    }
  }

  @override
  bool shouldRepaint(_BallPainter old) =>
      old.ink != ink || old.accent != accent || old.surface != surface;
}
