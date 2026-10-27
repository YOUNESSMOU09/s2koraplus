import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marma/app/app_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/extensions/status_l10n.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/journal/football_note.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/domain/entities/journal/journal_parts.dart';
import 'package:marma/core/utils/country_flag.dart';
import 'package:marma/domain/services/journal_progress.dart';
import 'package:marma/presentation/providers/derived_providers.dart';
import 'package:marma/presentation/providers/journal_providers.dart';
import 'package:marma/presentation/screens/common/state_views.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_analysis_cards.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_empty_view.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_feeling_cards.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_header_card.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_memory_cards.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_moment_cards.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_note_card.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_rating_cards.dart';
import 'package:marma/presentation/screens/journal/widgets/journal_summary_sheet.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_motion.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/theme/marma_icons.dart';
import 'package:marma/presentation/widgets/content_width.dart';
import 'package:marma/service/interstitial_gate.dart';

/// The Football Journal (§1–§24).
///
/// A gradient hero with the journal's progress, a pinned four-tab switcher
/// (Write · Rate · Moments · Analysis) and an "Up next" prompt that walks the
/// user to the next empty section. Every card writes straight through the
/// autosaving controller; nothing here ever leaves the device.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({
    required this.targetType,
    required this.targetId,
    this.fallbackTitle,
    super.key,
  });

  final JournalTargetType targetType;
  final String targetId;

  /// Used when there is no fixture behind the id and no journal on disk yet —
  /// a deep link to a match that has aged out of the three-day window.
  final String? fallbackTitle;

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with WidgetsBindingObserver {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  /// One key per section, so "Up next" can scroll straight to it.
  final Map<JournalSection, GlobalKey> _sectionKeys = <JournalSection, GlobalKey>{
    for (final JournalSection s in JournalSection.values) s: GlobalKey(),
  };

  /// Set once, from the first load: after that the field is the user's, and
  /// re-seeding it from state would fight the caret on every autosave.
  bool _noteSeeded = false;

  /// Null until the journal first loads; then an existing journal reopens on
  /// the tab last used and a fresh one starts on Write.
  JournalTab? _tab;

  JournalKey get _key => JournalKey(widget.targetType, widget.targetId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Dev-only screenshot seam; see [AppEnv.devJournalScroll].
  bool _devScrolled = false;

  void _applyDevScroll() {
    if (_devScrolled || AppEnv.devJournalScroll <= 0) return;
    _devScrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(
        AppEnv.devJournalScroll
            .toDouble()
            .clamp(0, _scroll.position.maxScrollExtent),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    _noteController.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounding is the one moment the debounce cannot cover on its own.
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      ref.read(journalProvider(_key).notifier).flush();
    }
  }

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final AsyncValue<JournalViewState> async = ref.watch(journalProvider(_key));

    // A live fixture, when the match is still inside the three-day window.
    // Everything else renders from the journal's own stored snapshot.
    final Fixture? fixture = widget.targetType == JournalTargetType.match
        ? ref.watch(resolvedFixtureProvider(widget.targetId))
        : null;
    if (fixture != null) {
      final JournalHeader header = _headerFrom(context, fixture);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(journalProvider(_key).notifier).attachHeader(header);
        }
      });
    }

    final bool started = async.valueOrNull?.started ?? false;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          context.l10n.journalTitle,
          style: context.type.titleMedium.copyWith(color: colors.textPrimary),
        ),
        actions: <Widget>[
          if (started) ...<Widget>[
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: context.l10n.journalSummaryAction,
              onPressed: () => _openSummary(async.requireValue.note),
            ),
            IconButton(
              icon: const Icon(MarmaIcons.clearCache),
              tooltip: context.l10n.journalDeleteAction,
              onPressed: _delete,
            ),
          ],
        ],
      ),
      body: async.when(
        loading: () => const SizedBox.shrink(),
        // A journal read never throws (the store swallows corruption and
        // returns null), so this branch exists only for completeness.
        error: (Object error, StackTrace _) => FailureView(
          failure: error,
          onRetry: () => ref.invalidate(journalProvider(_key)),
        ),
        data: _body,
      ),
    );
  }

  Widget _body(JournalViewState state) {
    // A deep link to a match that has aged out of the three-day window has no
    // fixture and, on a first visit, no snapshot either. The caller's title is
    // the last thing standing between that and a blank header.
    final FootballNote note = state.note.header.title.isEmpty &&
            (widget.fallbackTitle ?? '').isNotEmpty
        ? state.note.copyWith(
            header: state.note.header.copyWith(title: widget.fallbackTitle))
        : state.note;
    final JournalController controller = ref.read(journalProvider(_key).notifier);

    if (!_noteSeeded) {
      _noteController.text = note.note;
      _noteSeeded = true;
    }
    _tab ??= state.started ? ref.read(journalLastTabProvider) : JournalTab.write;

    _applyDevScroll();

    if (!state.started) {
      return ContentWidth(
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.blockInset, AppSpacing.sm, AppSpacing.blockInset, 0),
          children: <Widget>[
            JournalHero(note: note),
            JournalEmptyView(onStart: () {
              InterstitialGate.onAction('journal_start');
              setState(() => _tab = JournalTab.write);
              controller.start();
            }),
          ],
        ),
      );
    }

    final JournalProgress progress = JournalProgress(note);
    final JournalTab tab = _tab!;

    return ContentWidth(
      child: GestureDetector(
        // A horizontal fling moves between tabs, in reading direction.
        onHorizontalDragEnd: (DragEndDetails d) => _onSwipe(d, tab),
        child: CustomScrollView(
          controller: _scroll,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.blockInset, AppSpacing.sm, AppSpacing.blockInset, AppSpacing.md),
              sliver: SliverToBoxAdapter(
                child: JournalHero(
                  note: note,
                  progress: progress,
                  save: state.save,
                  savedAt: state.savedAtLocal,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                selected: tab,
                progress: progress,
                background: context.colors.bg,
                onSelect: _selectTab,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.blockInset, AppSpacing.sm, AppSpacing.blockInset, 0),
                child: _UpNextBanner(
                  progress: progress,
                  current: tab,
                  onGo: _goTo,
                ),
              ),
            ),
            SliverPadding(
              // The keyboard inset keeps the editor reachable above the keyboard.
              padding: EdgeInsets.fromLTRB(
                AppSpacing.blockInset,
                AppSpacing.md,
                AppSpacing.blockInset,
                AppSpacing.giant + MediaQuery.viewInsetsOf(context).bottom,
              ),
              sliver: SliverToBoxAdapter(
                child: _TabBody(
                  tab: tab,
                  children: _sectionsFor(tab, state, note, controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sectionsFor(
    JournalTab tab,
    JournalViewState state,
    FootballNote note,
    JournalController controller,
  ) {
    Widget keyed(JournalSection s, Widget child) =>
        KeyedSubtree(key: _sectionKeys[s], child: child);

    final List<Widget> cards = <Widget>[
      for (final JournalSection s in JournalProgress.sectionsOf(tab))
        keyed(s, switch (s) {
          JournalSection.note => JournalNoteCard(
              controller: _noteController,
              focusNode: _noteFocus,
              note: note,
              save: state.save,
              savedAt: state.savedAtLocal,
              onChanged: controller.setNote,
            ),
          JournalSection.reactions => ReactionsCard(note: note, controller: controller),
          JournalSection.mood => MoodCard(note: note, controller: controller),
          JournalSection.memory => MemoryCard(note: note, controller: controller),
          JournalSection.tags => TagsCard(note: note, controller: controller),
          JournalSection.rating => MatchRatingCard(note: note, controller: controller),
          JournalSection.players => PlayerRatingsCard(note: note, controller: controller),
          JournalSection.manOfTheMatch =>
            ManOfTheMatchCard(note: note, controller: controller),
          JournalSection.moments => MomentsCard(note: note, controller: controller),
          JournalSection.favouriteGoal =>
            FavouriteGoalCard(note: note, controller: controller),
          JournalSection.timeline => MatchTimelineCard(note: note, controller: controller),
          JournalSection.prediction => PredictionCard(note: note, controller: controller),
          JournalSection.tactical => TacticalCard(note: note, controller: controller),
          JournalSection.stats => StatsCard(note: note, controller: controller),
          JournalSection.rewatch => RewatchCard(note: note, controller: controller),
        }),
      if (tab == JournalTab.analysis) ...<Widget>[
        _SummaryButton(onTap: () => _openSummary(note)),
        ActivityCard(note: note),
      ],
    ];
    return <Widget>[
      for (int i = 0; i < cards.length; i++) ...<Widget>[
        if (i > 0) const SizedBox(height: AppSpacing.md),
        cards[i],
      ],
    ];
  }

  void _selectTab(JournalTab tab) {
    if (tab == _tab) return;
    unawaited(HapticFeedback.selectionClick());
    FocusScope.of(context).unfocus();
    setState(() => _tab = tab);
    ref.read(journalLastTabProvider.notifier).set(tab);
  }

  void _onSwipe(DragEndDetails details, JournalTab current) {
    final double v = details.primaryVelocity ?? 0;
    if (v.abs() < 600) return;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    // Swiping towards the start edge reveals the next tab.
    final int step = (v < 0) != rtl ? 1 : -1;
    final int next = current.index + step;
    if (next < 0 || next >= JournalTab.values.length) return;
    _selectTab(JournalTab.values[next]);
  }

  /// "Up next": switch to the section's tab, then bring it into view.
  void _goTo(JournalSection section) {
    _selectTab(section.tab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? target = _sectionKeys[section]?.currentContext;
      if (target == null || !mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: AppMotion.enabled(context) ? AppMotion.slow : Duration.zero,
        curve: AppMotion.emphasis,
        // Leaves room for the pinned tab bar above the card.
        alignment: 0.12,
      );
      if (section == JournalSection.note) _noteFocus.requestFocus();
    });
  }

  void _openSummary(FootballNote note) {
    InterstitialGate.onAction('journal_summary');
    showJournalSummary(context, note: note, onAppend: _appendToNote);
  }

  /// §17 — the summary APPENDS; it never replaces what the user wrote.
  void _appendToNote(String summary) {
    final String next = '${_noteController.text.trimRight()}\n$summary';
    _noteController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
    ref.read(journalProvider(_key).notifier).setNote(next);
  }

  /// Deletes at once and offers Undo, instead of a blocking confirmation.
  Future<void> _delete() async {
    final JournalController controller = ref.read(journalProvider(_key).notifier);
    final FootballNote? previous = ref.read(journalProvider(_key)).valueOrNull?.note;
    if (previous == null) return;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String deleted = context.l10n.journalDeleted;
    final String undo = context.l10n.journalUndo;
    await controller.deleteJournal();
    if (!mounted) return;
    _noteController.clear();
    setState(() => _tab = null);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(deleted),
        action: SnackBarAction(
          label: undo,
          onPressed: () async {
            await controller.restore(previous);
            if (!mounted) return;
            _noteController.text = previous.note;
          },
        ),
      ));
  }

  /// Snapshots everything the header needs so the journal still renders in full
  /// once the fixture has left the three-day window.
  JournalHeader _headerFrom(BuildContext context, Fixture fixture) {
    final ResolvedScoreline score = fixture.scoreline;
    return JournalHeader(
      title: fixture.home.name,
      subtitle: fixture.away.name,
      homeTeamId: fixture.home.id,
      homeTeamName: fixture.home.name,
      awayTeamId: fixture.away.id,
      awayTeamName: fixture.away.name,
      homeGoals: score.home,
      awayGoals: score.away,
      competition: fixture.league.name,
      country: countryDisplayName(fixture.league.country),
      kickoffUtcMillis: fixture.kickoffUtc.millisecondsSinceEpoch,
      venue: fixture.venue?.label,
      statusLabel: localisedStatusLong(context.l10n, fixture.status),
    );
  }
}

String _tabLabel(BuildContext context, JournalTab tab) => switch (tab) {
      JournalTab.write => context.l10n.journalTabWrite,
      JournalTab.rate => context.l10n.journalTabRate,
      JournalTab.moments => context.l10n.journalTabMoments,
      JournalTab.analysis => context.l10n.journalTabAnalysis,
    };

String journalSectionLabel(BuildContext context, JournalSection s) => switch (s) {
      JournalSection.note => context.l10n.journalSectionNote,
      JournalSection.reactions => context.l10n.journalSectionReactions,
      JournalSection.mood => context.l10n.journalSectionMood,
      JournalSection.memory => context.l10n.journalSectionMemory,
      JournalSection.tags => context.l10n.journalSectionTags,
      JournalSection.rating => context.l10n.journalSectionRating,
      JournalSection.players => context.l10n.journalSectionPlayers,
      JournalSection.manOfTheMatch => context.l10n.journalSectionMotm,
      JournalSection.moments => context.l10n.journalSectionMoments,
      JournalSection.favouriteGoal => context.l10n.journalSectionFavouriteGoal,
      JournalSection.timeline => context.l10n.journalSectionEvents,
      JournalSection.prediction => context.l10n.journalSectionPrediction,
      JournalSection.tactical => context.l10n.journalSectionTactical,
      JournalSection.stats => context.l10n.journalSectionStats,
      JournalSection.rewatch => context.l10n.journalSectionRewatch,
    };

/// Cross-fades between tabs; instant under Reduce Motion and in tests.
class _TabBody extends StatelessWidget {
  const _TabBody({required this.tab, required this.children});

  final JournalTab tab;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final Widget body = Column(
      key: ValueKey<JournalTab>(tab),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
    if (!AppMotion.enabled(context)) return body;
    return AnimatedSwitcher(
      duration: AppMotion.base,
      switchInCurve: AppMotion.emphasis,
      layoutBuilder: (Widget? current, List<Widget> previous) =>
          current ?? const SizedBox.shrink(),
      transitionBuilder: (Widget child, Animation<double> a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(a),
          child: child,
        ),
      ),
      child: body,
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({
    required this.selected,
    required this.progress,
    required this.background,
    required this.onSelect,
  });

  final JournalTab selected;
  final JournalProgress progress;
  final Color background;
  final ValueChanged<JournalTab> onSelect;

  static const double _height = 68;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(
        color: background,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.blockInset, AppSpacing.xs, AppSpacing.blockInset, AppSpacing.xs),
          child: _JournalTabBar(selected: selected, progress: progress, onSelect: onSelect),
        ),
      );

  @override
  bool shouldRebuild(_TabBarDelegate old) =>
      old.selected != selected ||
      old.progress.note != progress.note ||
      old.background != background;
}

class _JournalTabBar extends StatelessWidget {
  const _JournalTabBar({required this.selected, required this.progress, required this.onSelect});

  final JournalTab selected;
  final JournalProgress progress;
  final ValueChanged<JournalTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.chipRadius,
        boxShadow: colors.cardShadow,
        border: colors.isDark ? Border.all(color: colors.outline) : null,
      ),
      child: Row(
        children: <Widget>[
          for (final JournalTab t in JournalTab.values)
            Expanded(
              child: _TabButton(
                label: _tabLabel(context, t),
                selected: t == selected,
                done: progress.doneIn(t),
                total: JournalProgress.sectionsOf(t).length,
                onTap: () => onSelect(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final Color ink = selected ? colors.onAccent : colors.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $done/$total',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.emphasis,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.accentFill : Colors.transparent,
            borderRadius: AppRadius.chipRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.noScaling,
                style: context.type.label.copyWith(
                  color: selected ? colors.onAccent : colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              // One dot per section: filled once that section has content.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < total; i++)
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < done ? ink : ink.withValues(alpha: 0.25),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Suggests the next empty section — on this tab first — and takes the user
/// straight to it. Celebrates once everything is filled in.
class _UpNextBanner extends StatelessWidget {
  const _UpNextBanner({required this.progress, required this.current, required this.onGo});

  final JournalProgress progress;
  final JournalTab current;
  final ValueChanged<JournalSection> onGo;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    final JournalSection? next = progress.nextUp(current: current);

    final Widget content = next == null
        ? Row(
            children: <Widget>[
              Icon(Icons.verified_rounded, size: 18, color: colors.success),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.journalAllDone,
                  style: context.type.label.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          )
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onGo(next),
              borderRadius: AppRadius.ctaRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.lightbulb_outline_rounded, size: 18, color: colors.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.l10n.journalUpNext(journalSectionLabel(context, next)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.label.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(MarmaIcons.caretEnd, size: 16, color: colors.accent),
                  ],
                ),
              ),
            ),
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: next == null
            ? colors.success.withValues(alpha: colors.isDark ? 0.14 : 0.08)
            : colors.accent.withValues(alpha: colors.isDark ? 0.14 : 0.07),
        borderRadius: AppRadius.ctaRadius,
      ),
      child: content,
    );
  }
}

class _SummaryButton extends StatelessWidget {
  const _SummaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.blockRadius,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: <Color>[colors.heroStart, colors.heroEnd],
            ),
            borderRadius: AppRadius.blockRadius,
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.auto_awesome, size: 20, color: colors.onHero),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.l10n.journalSummaryAction,
                  style: context.type.titleMedium.copyWith(color: colors.onHero),
                ),
              ),
              Icon(MarmaIcons.caretEnd, size: 18, color: colors.onHero),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the journal for a fixture from anywhere in the app.
void openMatchJournal(BuildContext context, String fixtureId) {
  InterstitialGate.onAction('journal_open');
  context.push('/journal/match/$fixtureId');
}

/// The screen's own title, isolated for a bidi-safe app bar on a team journal.
String journalTitleFor(String name) => bidiIsolate(name);
