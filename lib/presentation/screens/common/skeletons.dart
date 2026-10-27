import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';

/// Loading skeletons that mirror the real layout exactly — three competition
/// blocks of four rows, at the geometry of the badge / name / score.
///
/// Shown ONLY on a true cold start with no cache; otherwise cached content is
/// painted and only the freshness chip indicates activity.
class SkeletonList extends StatelessWidget {
  const SkeletonList({this.blocks = 3, this.rowsPerBlock = 4, super.key});

  final int blocks;
  final int rowsPerBlock;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.loadingMatches,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.blockInset,
          vertical: AppSpacing.md,
        ),
        itemCount: blocks,
        itemBuilder: (BuildContext context, int index) =>
            _SkeletonBlock(rows: rowsPerBlock),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.rows});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Widget block = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: colors.card(hairline: context.hairline),
      child: Column(
        children: <Widget>[
          Container(
            height: 44,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
            alignment: AlignmentDirectional.centerStart,
            child: const _Bar(width: 140, height: 12),
          ),
          for (int i = 0; i < rows; i++)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: <Widget>[
                  const _Bar(width: 34, height: 12),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.surfaceHighest,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  const Expanded(child: _Bar(width: double.infinity, height: 12)),
                  const SizedBox(width: AppSpacing.lg),
                  const _Bar(width: 16, height: 14),
                ],
              ),
            ),
        ],
      ),
    );

    // The shimmer repeats forever — it must never start under a headless test
    // or with Reduce Motion on.
    if (!AppMotion.enabled(context)) return block;
    return block
        .animate(onPlay: (AnimationController c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1200),
          color: colors.surfaceHighest.withValues(alpha: 0.35),
        );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.surfaceHighest,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
}
