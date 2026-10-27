import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/screens/common/skeletons.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/ad_slot.dart';
import 'package:marma/presentation/widgets/competition_block.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/day_segmented_control.dart';
import 'package:marma/presentation/widgets/freshness_chip.dart';
import 'package:marma/service/interstitial_gate.dart';

/// The three-day scoreboard. Lazy slivers over isolate-parsed, pre-grouped
/// data — 1204 fixtures never become 1204 eagerly built widgets.
class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({required this.day, super.key});

  final DayKey day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final AsyncValue<DayBucket> bucket = ref.watch(dayBucketProvider(day));
    final List<CompetitionGroup> groups = ref.watch(orderedGroupsProvider(day));
    final Freshness freshness = ref.watch(freshnessProvider(day));

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.screenMatches),
            const SizedBox(height: 2),
            FreshnessChip(
              freshness: freshness,
              onTap: () => ref.read(dayBucketProvider(day).notifier).refresh(),
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
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.md),
            child: ContentWidth(
              child: DaySegmentedControl(
              selected: day,
              serverDates: <DayKey, String>{
                for (final DayKey d in DayKey.values)
                  d: _dateLabel(context, ref, d),
              },
              onChanged: (DayKey next) {
                InterstitialGate.onAction('day_switch');
                context.go('/matches?day=${next.name}');
              },
            )),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: colors.accent,
        backgroundColor: colors.surface,
        onRefresh: () => ref.read(dayBucketProvider(day).notifier).refresh(),
        child: ContentWidth(child: _body(context, ref, bucket, groups, freshness)),
      ),
    );
  }

  String _dateLabel(BuildContext context, WidgetRef ref, DayKey key) {
    final DayBucket? bucket = ref.watch(dayBucketProvider(key)).valueOrNull;
    final DateTime? parsed =
        bucket == null ? null : AppFormat.parseServerDate(bucket.serverDate);
    final DateTime fallback = DateTime.now().add(Duration(
      days: switch (key) {
        DayKey.yesterday => -1,
        DayKey.today => 0,
        DayKey.tomorrow => 1,
      },
    ));
    return AppFormat.shortDate(parsed ?? fallback, context.languageCode);
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<DayBucket> bucket,
    List<CompetitionGroup> groups,
    Freshness freshness,
  ) {
    // Cached content always wins: a spinner is never the terminal state.
    if (groups.isEmpty) {
      if (bucket.isLoading && !bucket.hasValue) return const SkeletonList();
      if (bucket.hasError) {
        return _scrollable(FailureView(
          failure: bucket.error!,
          minutesAgo: freshness.minutesAgo,
          hasCachedData: bucket.hasValue,
          onRetry: () => ref.read(dayBucketProvider(day).notifier).refresh(),
        ));
      }
      return _scrollable(MarmaStateView(
        title: context.l10n.emptyDayTitle,
        body: context.l10n.emptyDayBody,
      ));
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.blockInset, AppSpacing.md, AppSpacing.blockInset, 0),
          sliver: SliverList.builder(
            itemCount: groups.length,
            addAutomaticKeepAlives: false,
            itemBuilder: (BuildContext context, int index) => CompetitionBlock(
              // Matches cards open behind a rewarded ad.
              rewardedOnOpen: true,
              key: ValueKey<String>(groups[index].league.id),
              group: groups[index],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: AdSlot()),
        const SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
      ],
    );
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
