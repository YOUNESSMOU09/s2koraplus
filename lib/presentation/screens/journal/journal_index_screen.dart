import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/domain/services/journal_library.dart';
import 'package:marma/domain/services/journal_progress.dart';
import 'package:marma/domain/services/reaction_meter.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/screens/journal/widgets/verdict_style.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/presentation/widgets/team_badge.dart';
import 'package:marma/service/interstitial_gate.dart';

/// The Journal tab: your library of written-up matches.
///
/// Headline stats, search, filters and sort sit over a month-grouped list.
/// Everything is read from disk, so it works with the phone in flight mode.
/// Swipe a journal away to delete it; Undo puts it back exactly as it was.
class JournalIndexScreen extends ConsumerStatefulWidget {
  const JournalIndexScreen({super.key});

  @override
  ConsumerState<JournalIndexScreen> createState() => _JournalIndexScreenState();
}

class _JournalIndexScreenState extends ConsumerState<JournalIndexScreen> {
  late final TextEditingController _search;

  /// Journals swiped away whose deletion has not reloaded from disk yet. A
  /// dismissed row must leave the tree in the same frame, or Flutter throws.
  final Set<String> _hidden = <String>{};

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(journalQueryProvider).search,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final AsyncValue<JournalLibraryView> library = ref.watch(
      journalLibraryProvider,
    );

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: library.when(
            // The list is a local file read: it lands in the same frame on any
            // real device, so a skeleton here would be a flash, not a state.
            loading: () => const SizedBox.shrink(),
            error: (Object error, StackTrace _) => FailureView(
              failure: error,
              onRetry: () => ref.invalidate(allJournalsProvider),
            ),
            data: (JournalLibraryView view) =>
                view.all.isEmpty ? const _Empty() : _content(view),
          ),
        ),
      ),
    );
  }

  Widget _content(JournalLibraryView view) {
    final JournalQuery query = ref.watch(journalQueryProvider);
    final List<JournalMonthGroup> groups =
        <JournalMonthGroup>[
              for (final JournalMonthGroup g in view.groups)
                JournalMonthGroup(
                  year: g.year,
                  month: g.month,
                  notes: g.notes
                      .where(
                        (FootballNote n) => !_hidden.contains(n.storageKey),
                      )
                      .toList(growable: false),
                ),
            ]
            .where((JournalMonthGroup g) => g.notes.isNotEmpty)
            .toList(growable: false);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _Header(
            count: view.all.length - _hidden.length,
            sort: query.sort,
            onSort: ref.read(journalQueryProvider.notifier).setSort,
          ),
        ),
        SliverToBoxAdapter(child: _StatsStrip(stats: view.stats)),
        SliverToBoxAdapter(child: _searchField(query)),
        SliverToBoxAdapter(
          child: _FilterChips(
            selected: query.filter,
            onSelect: (JournalFilter f) {
              unawaited(HapticFeedback.selectionClick());
              ref.read(journalQueryProvider.notifier).setFilter(f);
            },
          ),
        ),
        if (groups.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.huge),
              child: MarmaStateView(
                title: context.l10n.journalNoResultsTitle,
                body: context.l10n.journalNoResultsBody,
                actionLabel: context.l10n.journalClearFilters,
                onAction: () {
                  _search.clear();
                  ref.read(journalQueryProvider.notifier).reset();
                },
              ),
            ),
          )
        else
          for (final JournalMonthGroup g in groups) ...<Widget>[
            SliverToBoxAdapter(child: _MonthHeader(group: g)),
            SliverList.builder(
              itemCount: g.notes.length,
              itemBuilder: (BuildContext context, int i) =>
                  _dismissible(g.notes[i]),
            ),
          ],
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.giant)),
      ],
    );
  }

  Widget _searchField(JournalQuery query) {
    final MarmaColors colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.blockInset,
        AppSpacing.md,
        AppSpacing.blockInset,
        0,
      ),
      child: TextField(
        controller: _search,
        onChanged: ref.read(journalQueryProvider.notifier).setSearch,
        textInputAction: TextInputAction.search,
        style: context.type.bodyMedium.copyWith(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: context.l10n.journalSearchHint,
          prefixIcon: Icon(
            MarmaIcons.search,
            size: 20,
            color: colors.textTertiary,
          ),
          suffixIcon: query.search.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                  onPressed: () {
                    _search.clear();
                    ref.read(journalQueryProvider.notifier).setSearch('');
                  },
                ),
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.chipRadius,
            borderSide: BorderSide(color: colors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.chipRadius,
            borderSide: BorderSide(color: colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.chipRadius,
            borderSide: BorderSide(color: colors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _dismissible(FootballNote note) {
    final MarmaColors colors = context.colors;
    return Dismissible(
      key: ValueKey<String>(note.storageKey),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.blockInset,
          vertical: AppSpacing.xs + 2,
        ),
        padding: const EdgeInsetsDirectional.only(end: AppSpacing.xl),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: colors.danger,
          borderRadius: AppRadius.blockRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(MarmaIcons.clearCache, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              context.l10n.journalSwipeDelete,
              style: context.type.label.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _delete(note),
      child: _JournalCard(note: note),
    );
  }

  Future<void> _delete(FootballNote note) async {
    unawaited(HapticFeedback.mediumImpact());
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String deleted = context.l10n.journalDeleted;
    final String undo = context.l10n.journalUndo;
    setState(() => _hidden.add(note.storageKey));
    await deleteJournalNote(ref, note);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(deleted),
          action: SnackBarAction(
            label: undo,
            onPressed: () async {
              await restoreJournalNote(ref, note);
              if (mounted) setState(() => _hidden.remove(note.storageKey));
            },
          ),
        ),
      );
    // Once disk has caught up, the row is gone for real and needs no mask.
    await ref.read(allJournalsProvider.future);
    if (mounted) setState(() => _hidden.remove(note.storageKey));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, this.sort, this.onSort});

  final int count;
  final JournalSort? sort;
  final ValueChanged<JournalSort>? onSort;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final JournalSort? current = sort;
    final ValueChanged<JournalSort>? select = onSort;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.journalIndexTitle,
                  style: context.type.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.journalIndexSubtitle(count),
                  style: context.type.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (current != null && select != null)
            PopupMenuButton<JournalSort>(
              tooltip: context.l10n.journalSortTooltip,
              initialValue: current,
              onSelected: select,
              icon: Icon(Icons.swap_vert_rounded, color: colors.textPrimary),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.cardRadius,
              ),
              color: colors.surface,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<JournalSort>>[
                    for (final JournalSort s in JournalSort.values)
                      PopupMenuItem<JournalSort>(
                        value: s,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 24,
                              child: s == current
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 18,
                                      color: colors.accent,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _sortLabel(context, s),
                              style: context.type.bodyMedium.copyWith(
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
            ),
        ],
      ),
    );
  }
}

String _sortLabel(BuildContext context, JournalSort s) => switch (s) {
  JournalSort.recent => context.l10n.journalSortRecent,
  JournalSort.matchDate => context.l10n.journalSortMatchDate,
  JournalSort.rating => context.l10n.journalSortRating,
};

String _filterLabel(BuildContext context, JournalFilter f) => switch (f) {
  JournalFilter.all => context.l10n.journalFilterAll,
  JournalFilter.rated => context.l10n.journalFilterRated,
  JournalFilter.withNotes => context.l10n.journalFilterNotes,
  JournalFilter.predictions => context.l10n.journalFilterPredictions,
  JournalFilter.topRated => context.l10n.journalFilterTopRated,
};

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.stats});

  final JournalLibraryStats stats;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final double? avg = stats.averageRating;
    final List<({String value, String label, bool word})> tiles =
        <({String value, String label, bool word})>[
          (
            value: AppFormat.integer(stats.count),
            label: context.l10n.journalStatJournals,
            word: false,
          ),
          (
            value: avg == null ? '–' : avg.toStringAsFixed(1),
            label: context.l10n.journalStatAverage,
            word: false,
          ),
          (
            value: AppFormat.integer(stats.totalWords),
            label: context.l10n.journalStatWords,
            word: false,
          ),
          if (stats.verdict != null)
            (
              value: verdictName(context, stats.verdict!),
              label: context.l10n.journalStatVerdict,
              word: true,
            ),
        ];
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.blockInset,
        AppSpacing.sm,
        AppSpacing.blockInset,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[colors.heroStart, colors.heroEnd],
        ),
        borderRadius: AppRadius.blockRadius,
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < tiles.length; i++) ...<Widget>[
            if (i > 0)
              Container(
                width: 1,
                height: 32,
                color: colors.onHero.withValues(alpha: 0.18),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  children: <Widget>[
                    // Numbers use the scoreboard face; a verdict word uses the
                    // display face and shrinks rather than wrapping.
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tiles[i].value,
                          maxLines: 1,
                          style: tiles[i].word
                              ? context.type.titleMedium.copyWith(
                                  color: colors.onHero,
                                  fontWeight: FontWeight.w700,
                                )
                              : context.type.scoreLarge.copyWith(
                                  color: colors.onHero,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      tiles[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: context.type.label.copyWith(
                        color: colors.onHero.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelect});

  final JournalFilter selected;
  final ValueChanged<JournalFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.blockInset,
          vertical: AppSpacing.sm,
        ),
        itemCount: JournalFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int i) {
          final JournalFilter f = JournalFilter.values[i];
          final bool on = f == selected;
          return Semantics(
            button: true,
            selected: on,
            child: GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: AppMotion.quick,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? colors.accentFill : colors.surface,
                  borderRadius: AppRadius.chipRadius,
                  border: Border.all(
                    color: on ? colors.accentFill : colors.outline,
                  ),
                ),
                child: Text(
                  _filterLabel(context, f),
                  textScaler: TextScaler.noScaling,
                  style: context.type.label.copyWith(
                    color: on ? colors.onAccent : colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.group});

  final JournalMonthGroup group;

  @override
  Widget build(BuildContext context) {
    // year 0 marks the ungrouped rating-sorted run.
    final String label = group.year == 0
        ? context.l10n.journalByRating
        : DateFormat.yMMMM(
            context.languageCode,
          ).format(DateTime(group.year, group.month));
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: context.type.label.copyWith(
          color: context.colors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      const _Header(count: 0),
      const SizedBox(height: AppSpacing.giant),
      MarmaStateView(
        title: context.l10n.journalIndexEmptyTitle,
        body: context.l10n.journalIndexEmptyBody,
        actionLabel: context.l10n.journalIndexEmptyAction,
        actionIcon: MarmaIcons.matches,
        onAction: () => GoRouter.of(context).go('/matches?day=today'),
      ),
    ],
  );
}

class _JournalCard extends StatelessWidget {
  const _JournalCard({required this.note});

  final FootballNote note;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final JournalHeader h = note.header;
    final bool isMatch = h.homeTeamName != null && h.awayTeamName != null;
    final JournalProgress progress = JournalProgress(note);
    final DateTime? kickoff = h.kickoffLocal;

    final String? snippet = noteSnippet(note.note);
    final String eyebrow = <String>[
      if (h.competition != null) h.competition!,
      if (kickoff != null) AppFormat.shortDate(kickoff, context.languageCode),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.blockInset,
        vertical: AppSpacing.xs + 2,
      ),
      child: DecoratedBox(
        decoration: colors.card(hairline: context.hairline),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.blockRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              InterstitialGate.onAction('journal_open');
              GoRouter.of(
                context,
              ).push('/journal/${note.targetType.id}/${note.targetId}');
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (eyebrow.isNotEmpty) ...<Widget>[
                    Text(
                      bidiIsolate(eyebrow),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.label.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  if (isMatch)
                    _Matchup(header: h)
                  else
                    Text(
                      bidiIsolate(
                        h.title.isEmpty
                            ? context.l10n.journalIndexUnknownMatch
                            : h.title,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.titleMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  if (snippet != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _Footer(note: note, progress: progress),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Home crest + name · score · name + away crest, mirrored in RTL.
class _Matchup extends StatelessWidget {
  const _Matchup({required this.header});

  final JournalHeader header;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final TextStyle name = context.type.teamName.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    // One forced-LTR string, ordered so the home digit always lands beside
    // the home crest — on the right in RTL, on the left in LTR.
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final DateTime? kickoff = header.kickoffLocal;
    // Not played yet: the kickoff time, as on the Matches screen.
    final String score = header.hasScore
        ? (rtl
              ? '${header.awayGoals}–${header.homeGoals}'
              : '${header.homeGoals}–${header.awayGoals}')
        : (kickoff == null ? '–' : AppFormat.kickoffTime(kickoff));

    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  bidiIsolate(header.homeTeamName!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: name,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TeamBadge(
                teamId: header.homeTeamId ?? header.homeTeamName!,
                teamName: header.homeTeamName!,
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceHighest,
            borderRadius: AppRadius.badgeRadius,
          ),
          child: Text(
            score,
            textDirection: TextDirection.ltr,
            style: context.type.rowScore.copyWith(color: colors.textPrimary),
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              TeamBadge(
                teamId: header.awayTeamId ?? header.awayTeamName!,
                teamName: header.awayTeamName!,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  bidiIsolate(header.awayTeamName!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: name,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rating pill · reactions · completeness bar · last edited.
class _Footer extends StatelessWidget {
  const _Footer({required this.note, required this.progress});

  final FootballNote note;
  final JournalProgress progress;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final int? rating = note.ratings.overall;
    final MatchVerdict? verdict = verdictFor(note.reactions);
    return Row(
      children: <Widget>[
        if (rating != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: colors.accent.withValues(
                alpha: colors.isDark ? 0.18 : 0.1,
              ),
              borderRadius: AppRadius.chipRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.star_rounded, size: 14, color: colors.accent),
                const SizedBox(width: 2),
                Text(
                  '$rating',
                  textDirection: TextDirection.ltr,
                  style: context.type.mono.copyWith(color: colors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        if (verdict != null) ...<Widget>[
          VerdictPill(verdict: verdict),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Text(
            context.l10n.journalIndexUpdated(
              AppFormat.shortDate(note.updatedAtLocal, context.languageCode),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.monoSmall.copyWith(color: colors.textTertiary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Tooltip(
          message: context.l10n.journalProgress(progress.done, progress.total),
          child: SizedBox(
            width: 44,
            child: ClipRRect(
              borderRadius: AppRadius.chipRadius,
              child: LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 5,
                color: progress.isComplete ? colors.success : colors.accent,
                backgroundColor: colors.surfaceHighest,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
