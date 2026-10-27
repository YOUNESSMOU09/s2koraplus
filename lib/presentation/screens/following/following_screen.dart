import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/services/following_feed.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/fixture_providers.dart';
import 'package:marma/presentation/providers/settings_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/match_row.dart';
import 'package:marma/service/interstitial_gate.dart';

/// Client-side filter of the three cached buckets + the live snapshot.
///
/// Two distinct empty states, deliberately: "you follow nothing yet" and
/// "you follow things, but none of them play in this three-day window" — the
/// latter is normal (a league can simply be out of season), not an error.
class FollowingScreen extends ConsumerWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MarmaColors colors = context.colors;
    final Favourites favourites = ref.watch(favouritesProvider);
    final FollowingFeed feed = ref.watch(followingFeedProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(context.l10n.screenFollowing),
        actions: <Widget>[
          IconButton(
            tooltip: context.l10n.screenManageFavourites,
            icon: const Icon(MarmaIcons.manage),
            onPressed: () {
              InterstitialGate.onAction('favourites_manage');
              context.push('/following/manage');
            },
          ),
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
      ),
      body: RefreshIndicator(
        color: colors.accent,
        backgroundColor: colors.surface,
        onRefresh: () async {
          await ref.read(liveFeedProvider.notifier).refresh();
        },
        child: ContentWidth(child: _body(context, favourites, feed)),
      ),
    );
  }

  Widget _body(BuildContext context, Favourites favourites, FollowingFeed feed) {
    if (favourites.isEmpty) {
      return _scrollable(MarmaStateView(
        title: context.l10n.emptyFollowingTitle,
        body: context.l10n.emptyFollowingBody,
        actionLabel: context.l10n.actionAddFavourites,
        onAction: () => context.push('/search'),
      ));
    }
    if (feed.isEmpty) {
      return _scrollable(MarmaStateView(
        title: context.l10n.emptyFollowingNoFixturesTitle,
        body: context.l10n.emptyFollowingNoFixturesBody,
        actionLabel: context.l10n.actionSeeTodaysFixtures,
        onAction: () => context.go('/matches?day=today'),
      ));
    }

    return CustomScrollView(
      slivers: <Widget>[
        for (final MapEntry<FollowingSection, List<Fixture>> section in feed.sections) ...<Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(section: section.key, count: section.value.length),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.blockInset),
            sliver: SliverList.builder(
              itemCount: section.value.length,
              addAutomaticKeepAlives: false,
              itemBuilder: (BuildContext context, int index) => _FollowingCard(
                key: ValueKey<String>(section.value[index].id),
                fixture: section.value[index],
              ),
            ),
          ),
        ],
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section, required this.count});

  final FollowingSection section;
  final int count;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final String label = switch (section) {
      FollowingSection.live => context.l10n.sectionLive,
      FollowingSection.laterToday => context.l10n.sectionLaterToday,
      FollowingSection.tomorrow => context.l10n.sectionTomorrow,
      FollowingSection.finished => context.l10n.sectionFinished,
    };
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: <Widget>[
          if (section == FollowingSection.live)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: colors.live, shape: BoxShape.circle),
              ),
            ),
          Text(
            label,
            style: context.type.sectionHeader.copyWith(
              color: section == FollowingSection.live ? colors.live : colors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('$count', style: context.type.monoSmall.copyWith(color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _FollowingCard extends StatelessWidget {
  const _FollowingCard({required this.fixture, super.key});

  final Fixture fixture;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: colors.card(borderRadius: AppRadius.cardRadius, hairline: context.hairline),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg, AppSpacing.sm + 2, AppSpacing.lg, 0),
            child: Text(
              bidiIsolate(fixture.league.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.label.copyWith(color: colors.textTertiary),
            ),
          ),
          MatchRow(
            fixtureId: fixture.id,
            fallback: fixture,
            showFollowAffordance: true,
          ),
        ],
      ),
    );
  }
}
