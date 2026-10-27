import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/presentation/providers/app_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/service/app_open_ad_gate.dart';
import 'package:marma/service/interstitial_gate.dart';

/// The `StatefulShellRoute` scaffold: five destinations plus a floating pill
/// tab bar. Re-tapping the active tab pops that branch to its root.
///
/// Five is the iOS tab-bar maximum, so this bar is now full: a sixth
/// destination would have to displace one of these, not join them.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    // First content. The shell does not exist until the splash gate has
    // lifted, so this is exactly "after the splash".
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AppOpenAdGate.showOnce(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final StatefulNavigationShell navigationShell = widget.navigationShell;
    final MarmaColors colors = context.colors;
    final int liveCount = ref.watch(liveCountProvider);

    // Keep the poller's branch awareness in sync without rebuilding it here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ShellBranchNotifier notifier = ref.read(
        shellBranchProvider.notifier,
      );
      if (ref.read(shellBranchProvider) != navigationShell.currentIndex) {
        notifier.set(navigationShell.currentIndex);
      }
    });

    return Scaffold(
      backgroundColor: colors.bg,
      body: navigationShell,
      // A floating pill over the page colour: the selected tab expands into a
      // solid capsule with its label, the rest are icon-only.
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                height: 64,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.chipRadius,
                  border: colors.isDark
                      ? Border.all(color: colors.outline)
                      : null,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(
                        0xFF0B1424,
                      ).withValues(alpha: colors.isDark ? 0.4 : 0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    _NavItem(
                      index: ShellBranch.matches,
                      current: navigationShell.currentIndex,
                      label: context.l10n.navMatches,
                      icon: MarmaIcons.navMatches,
                      onTap: () => _go(ShellBranch.matches),
                    ),
                    _NavItem(
                      index: ShellBranch.live,
                      current: navigationShell.currentIndex,
                      label: context.l10n.navLive,
                      icon: MarmaIcons.navLive,
                      badgeCount: liveCount,
                      onTap: () => _go(ShellBranch.live),
                    ),
                    _NavItem(
                      index: ShellBranch.following,
                      current: navigationShell.currentIndex,
                      label: context.l10n.navFollowing,
                      icon: MarmaIcons.navFollowing,
                      onTap: () => _go(ShellBranch.following),
                    ),
                    _NavItem(
                      index: ShellBranch.journal,
                      current: navigationShell.currentIndex,
                      label: context.l10n.navJournal,
                      icon: MarmaIcons.navJournal,
                      onTap: () => _go(ShellBranch.journal),
                    ),
                    _NavItem(
                      index: ShellBranch.settings,
                      current: navigationShell.currentIndex,
                      label: context.l10n.navSettings,
                      icon: MarmaIcons.navSettings,
                      onTap: () => _go(ShellBranch.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _go(int index) {
    // A re-tap of the live tab is a refresh gesture, not a destination change;
    // interrupting that with an ad would make the app feel broken.
    if (index != widget.navigationShell.currentIndex) {
      InterstitialGate.onAction('tab_switch');
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.current,
    required this.label,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final int index;
  final int current;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final bool selected = index == current;
    final Duration motion = AppMotion.enabled(context)
        ? AppMotion.base
        : Duration.zero;
    final Color ink = selected ? colors.onAccent : colors.textSecondary;

    final Widget glyph = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Icon(icon, size: 22, color: ink, fill: selected ? 1 : 0),
        if (badgeCount > 0)
          PositionedDirectional(
            top: -6,
            end: -10,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 4,
                vertical: 1,
              ),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: colors.live,
                borderRadius: AppRadius.chipRadius,
                border: Border.all(
                  color: selected ? colors.accentFill : colors.surface,
                  width: 1.5,
                ),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                textAlign: TextAlign.center,
                textScaler: TextScaler.noScaling,
                style: context.type.monoSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );

    return Expanded(
      // The selected tab takes more room so its label fits beside the icon.
      flex: selected ? 7 : 3,
      child: Semantics(
        button: true,
        selected: selected,
        label: badgeCount > 0
            ? '$label, ${context.l10n.semanticsLiveTabBadge(badgeCount)}'
            : label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!selected) unawaited(HapticFeedback.selectionClick());
            onTap();
          },
          child: AnimatedContainer(
            duration: motion,
            curve: AppMotion.emphasis,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: selected ? colors.accentFill : Colors.transparent,
              borderRadius: AppRadius.chipRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                glyph,
                // Label only on the selected tab; it fades and grows in.
                Flexible(
                  child: AnimatedSize(
                    duration: motion,
                    curve: AppMotion.emphasis,
                    child: selected
                        ? Padding(
                            padding: EdgeInsetsDirectional.only(
                              // Clears the badge that hangs off the icon.
                              start: badgeCount > 0
                                  ? AppSpacing.lg
                                  : AppSpacing.sm,
                            ),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              textScaler: TextScaler.noScaling,
                              style: context.type.label.copyWith(
                                color: colors.onAccent,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
