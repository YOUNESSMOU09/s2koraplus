import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/services/live_atlas.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/providers/live_atlas_providers.dart';
import 'package:marma/presentation/providers/worth_watching_providers.dart';
import 'package:marma/presentation/screens/common/skeletons.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/presentation/widgets/atlas_summary_header.dart';
import 'package:marma/presentation/widgets/competition_block.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/country_block.dart';
import 'package:marma/presentation/widgets/freshness_chip.dart';
import 'package:marma/presentation/widgets/worth_watching_block.dart';
import 'package:marma/service/interstitial_gate.dart';

/// Which arrangement of the live snapshot the tab is showing.
///
/// Carried in the URL as `?view=`, exactly like `/matches?day=`, so the
/// selection survives state restoration without a remembered-view provider.
enum LiveView {
  competition,
  country;

  /// Null-tolerant, same contract as `DayKey.fromName`: anything unknown
  /// resolves to the default rather than throwing on a hand-typed deep link.
  static LiveView fromName(String? name) => LiveView.values.firstWhere(
        (LiveView v) => v.name == name,
        orElse: () => LiveView.competition,
      );
}

/// Live tab. Mounting it starts the 30 s foreground poll; leaving the branch or
/// backgrounding the app stops it (see `LivePoller`).
///
/// Both segments are fed by that ONE poll. Neither "Worth watching" nor the
/// country atlas adds an endpoint, a request or a second timer.
class LiveScreen extends ConsumerWidget {
  const LiveScreen({this.view = LiveView.competition, super.key});

  final LiveView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;

    // Instantiating the poller here binds its lifetime to the provider
    // container, not to this widget — but reading it guarantees it exists.
    ref.watch(livePollerProvider);

    final AsyncValue<LiveSnapshot> snapshot = ref.watch(liveFeedProvider);
    final Freshness freshness = ref.watch(liveFreshnessProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.screenLive),
            const SizedBox(height: 2),
            FreshnessChip(
              freshness: freshness,
              onTap: () => ref.read(liveFeedProvider.notifier).refresh(),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.semanticsSearch,
            icon: const Icon(MarmaIcons.search),
            onPressed: () {
              InterstitialGate.onAction('search_open');
              context.push('/search');
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ContentWidth(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
              // ALWAYS visible, including in the empty and error states, so a
              // user who lands on an empty segment can switch back without
              // reaching for the back gesture.
              child: _LiveViewControl(
                selected: view,
                onChanged: (LiveView next) => context.go(
                  next == LiveView.competition ? '/live' : '/live?view=${next.name}',
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: colors.accent,
        backgroundColor: colors.surface,
        onRefresh: () => ref.read(liveFeedProvider.notifier).refresh(),
        child: ContentWidth(child: _body(context, ref, snapshot, freshness)),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<LiveSnapshot> snapshot,
    Freshness freshness,
  ) {
    final List<CompetitionGroup> groups = ref.watch(liveGroupsProvider);

    if (groups.isEmpty) {
      if (snapshot.isLoading && !snapshot.hasValue) {
        return const SkeletonList(blocks: 2, rowsPerBlock: 3);
      }
      if (snapshot.hasError && !snapshot.hasValue) {
        return _scrollable(FailureView(
          failure: snapshot.error!,
          minutesAgo: freshness.minutesAgo,
          hasCachedData: false,
          onRetry: () => ref.read(liveFeedProvider.notifier).refresh(),
        ));
      }
      // Both segments share this one state view, so they agree with each other
      // at quiet hours. No new empty state is introduced.
      return _scrollable(MarmaStateView(
        title: context.l10n.emptyLiveTitle,
        body: context.l10n.emptyLiveBody,
        actionLabel: context.l10n.actionSeeTodaysFixtures,
        onAction: () => context.go('/matches?day=today'),
      ));
    }

    return switch (view) {
      LiveView.competition => _CompetitionView(groups: groups),
      LiveView.country => _CountryView(freshness: freshness),
    };
  }

  Widget _scrollable(Widget child) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) =>
            SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );
}

/// Segment 0: the ranked module, a separator, then the existing competition
/// blocks — unchanged below the module.
class _CompetitionView extends ConsumerWidget {
  const _CompetitionView({required this.groups});

  final List<CompetitionGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool moduleVisible = ref.watch(worthWatchingProvider
        .select((WorthWatchingState s) => s.mode != WorthWatchingMode.hidden));

    return NotificationListener<ScrollNotification>(
      // A scroll is the other signal that a thumb is on the screen; the module
      // must not reorder under it. This is a TIMESTAMP, not a timer.
      onNotification: (ScrollNotification n) {
        if (n is ScrollUpdateNotification || n is ScrollStartNotification) {
          ref.read(worthWatchingProvider.notifier).touch();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: WorthWatchingBlock()),
          if (moduleVisible) const SliverToBoxAdapter(child: AllLiveHeader()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.blockInset,
              moduleVisible ? 0 : AppSpacing.md,
              AppSpacing.blockInset,
              AppSpacing.xxl,
            ),
            sliver: SliverList.builder(
              itemCount: groups.length,
              addAutomaticKeepAlives: false,
              itemBuilder: (BuildContext context, int index) => CompetitionBlock(
                // Live cards open behind a rewarded ad.
                rewardedOnOpen: true,
                key: ValueKey<String>(groups[index].league.id),
                group: groups[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Segment 1: the same fixtures, grouped by country.
class _CountryView extends ConsumerWidget {
  const _CountryView({required this.freshness});

  final Freshness freshness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CountryLiveGroup> atlas =
        ref.watch(liveAtlasProvider(context.languageCode));
    final int matches = ref.watch(liveCountProvider);

    // Fires after the build that produced this snapshot, never during it.
    ref.listen<List<CountryLiveGroup>>(liveAtlasProvider(context.languageCode),
        (List<CountryLiveGroup>? _, List<CountryLiveGroup> next) {
      ref.read(atlasExpansionProvider.notifier).pruneTo(
            <String>{for (final CountryLiveGroup g in next) g.rawCountry},
          );
    });

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: AtlasSummaryHeader(
            atlas: atlas,
            matchCount: matches,
            freshness: freshness,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.blockInset, 0, AppSpacing.blockInset, AppSpacing.xxl),
          sliver: SliverList.builder(
            itemCount: atlas.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (BuildContext context, int index) => CountryBlock(
              // Live atlas cards, same as the competition list above.
              rewardedOnOpen: true,
              key: ValueKey<String>(atlas[index].rawCountry),
              group: atlas[index],
              forceExpanded: atlas.length == 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// The Matches day-control treatment, minus the date sub-label — the app has
/// one segmented-control design, not two.
class _LiveViewControl extends StatelessWidget {
  const _LiveViewControl({required this.selected, required this.onChanged});

  final LiveView selected;
  final ValueChanged<LiveView> onChanged;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceHighest,
        borderRadius: AppRadius.chipRadius,
      ),
      child: Row(
        children: <Widget>[
          for (final LiveView v in LiveView.values)
            Expanded(
              child: _Segment(
                label: switch (v) {
                  LiveView.competition => context.l10n.liveViewCompetition,
                  LiveView.country => context.l10n.liveViewCountry,
                },
                selected: v == selected,
                onTap: () => onChanged(v),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          // A 48 dp target, above both the iOS 44 pt and the app's own 48 dp
          // minimum, in natural RTL order.
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.surface : Colors.transparent,
            borderRadius: AppRadius.chipRadius,
            border: selected ? Border.all(color: colors.outlineStrong) : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textScaler: TextScaler.noScaling,
            style: context.type.label.copyWith(
              color: selected ? colors.textPrimary : colors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
