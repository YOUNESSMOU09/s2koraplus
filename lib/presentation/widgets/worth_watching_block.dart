import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/providers/worth_watching_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/presentation/widgets/motion_size.dart';
import 'package:marma/presentation/widgets/worth_watching_info_sheet.dart';
import 'package:marma/presentation/widgets/worth_watching_row.dart';

/// Surface A's container: an amber floodlight rule on the START edge, then the
/// header and at most three ranked rows.
///
/// THERE IS NO TENSION INDICATOR. Magnitude is not encoded anywhere — no
/// meter, no gauge, no bar, no dial, no ring, no percentage, no rank numeral,
/// no intensity tint. Ordering is the only ranking signal, and ordering is not
/// a number. The user gets position in the list plus a sentence saying exactly
/// what happened, which is more information than any glyph and unmistakable
/// for a market.
class WorthWatchingBlock extends ConsumerWidget {
  const WorthWatchingBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final WorthWatchingState state = ref.watch(worthWatchingProvider);

    if (state.mode == WorthWatchingMode.hidden) return const SizedBox.shrink();

    final bool motionOn = AppMotion.enabled(context) &&
        // During a crossfade both subtrees are in the tree, producing
        // duplicate semantics nodes and stealing VoiceOver focus.
        !MediaQuery.of(context).accessibleNavigation;

    return Listener(
      // Pointer-down is the earliest signal that a thumb is over the module.
      onPointerDown: (_) => ref.read(worthWatchingProvider.notifier).touch(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.blockInset, AppSpacing.md, AppSpacing.blockInset, AppSpacing.md),
        child: ClipRRect(
          // A thick start side plus a `borderRadius` on one `BorderDirectional`
          // trips Flutter's "a borderRadius can only be given for a uniform
          // Border" assertion. Clipping a `Stack` is the supported form.
          //
          // A `Row` + `IntrinsicHeight` also works on paper and is WRONG here:
          // `IntrinsicHeight` runs a dry layout, and the `AnimatedSize` below
          // then restarts its controller inside its own `performLayout`, which
          // throws "a RenderAnimatedSize was mutated in its own performLayout".
          // It compiles, analyses clean, and blows up on the first commit
          // animation. A positioned rule has no intrinsic pass at all.
          borderRadius: AppRadius.blockRadius,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceHigh,
                    border: BorderDirectional(
                      top: BorderSide(color: colors.outline, width: context.hairline),
                      end: BorderSide(color: colors.outline, width: context.hairline),
                      bottom: BorderSide(color: colors.outline, width: context.hairline),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _Header(rowCount: state.rows.length),
                      MotionSize(
                        enabled: motionOn,
                        child: AnimatedSwitcher(
                          duration: motionOn ? AppMotion.quick : Duration.zero,
                          switchInCurve: AppMotion.gentle,
                          switchOutCurve: AppMotion.gentle,
                          layoutBuilder: AnimatedSwitcher.defaultLayoutBuilder,
                          child: KeyedSubtree(
                            key: ValueKey<int>(state.commitVersion),
                            child: _Body(state: state),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // The amber floodlight rule: the section's only chrome flourish,
              // on the START edge, so in Arabic it appears on the right.
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                width: 2,
                child: ExcludeSemantics(child: ColoredBox(color: colors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final WorthWatchingState state;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    switch (state.mode) {
      case WorthWatchingMode.rows:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < state.rows.length; i++) ...<Widget>[
              if (i > 0)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: AppSpacing.lg),
                  child: Divider(height: 1, thickness: 1, color: colors.outline),
                ),
              WorthWatchingRow(
                // This module renders on Live only.
                rewardedOnOpen: true,
                key: ValueKey<String>(state.rows[i].fixtureId),
                entry: state.rows[i],
              ),
            ],
          ],
        );
      case WorthWatchingMode.noneTight:
        return _Note(text: context.l10n.worthNoneTight);
      case WorthWatchingMode.paused:
        return _Note(text: context.l10n.worthPaused);
      case WorthWatchingMode.hidden:
        return const SizedBox.shrink();
    }
  }
}

/// A single line beneath the header. No CTA and no illustration — the screen
/// below is already full of content.
class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          text,
          textAlign: TextAlign.start,
          style: context.type.bodyMedium
              .copyWith(color: context.colors.textSecondary),
        ),
      );
}

/// Geometry mirrors `CompetitionSectionHeader` so the blocks read as a family.
/// No flag and no follow star — this is not a competition.
class _Header extends StatelessWidget {
  const _Header({required this.rowCount});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.only(
          start: AppSpacing.lg, end: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceHigh,
        border: Border(
            bottom: BorderSide(color: colors.outline, width: context.hairline)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              label: context.l10n
                  .semanticsWorthHeader(context.l10n.atlasMatches(rowCount)),
              excludeSemantics: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.worthTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.sectionHeader
                        .copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.worthSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.label.copyWith(
                      // Light-mode textTertiary on surfaceHigh is only 3.5:1 —
                      // below AA for 12 pt — so light mode steps up a level.
                      color: colors.isDark
                          ? colors.textTertiary
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: context.l10n.worthHowAction,
              icon: const Icon(MarmaIcons.info, size: 18),
              color: colors.textTertiary,
              onPressed: () => showWorthWatchingInfoSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// The 32 dp label that separates the ranked module from the full list.
///
/// Its only job is to make clear that the rows above are a LENS on the list
/// below, not a duplicate-render bug.
class AllLiveHeader extends StatelessWidget {
  const AllLiveHeader({super.key});

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.lg, end: AppSpacing.lg, bottom: AppSpacing.xs),
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          context.l10n.worthAllLive,
          style: context.type.label.copyWith(color: context.colors.textTertiary),
        ),
      );
}
