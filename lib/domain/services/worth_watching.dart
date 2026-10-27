/// "Worth watching now" — ordering live matches by what has ALREADY happened
/// in them (08_feature_worth_watching.md §4).
///
/// ## The one rule that governs this file
///
/// [WorthWatchingEntry.tension] is **unitless, private to the domain layer, and
/// is never passed to `toString()`, string interpolation, `NumberFormat`, a
/// `Text`, a `Semantics` label or an analytics payload.** Ordering is the only
/// ranking signal the user ever sees, and ordering is not a number. A rendered
/// magnitude — a percentage, a meter, a 1–5 rating, a rank ordinal — is
/// indistinguishable from an implied probability and would turn a calm
/// scoreboard into something that reads as a betting product (§1, C5).
/// `test/domain/worth_watching_test.dart` enforces this by scanning the
/// presentation layer for the token; do not suppress it.
///
/// Nothing here predicts anything. Every component is a measurement of the
/// past: how close the score is, how late it is, how recently goals arrived,
/// whether a side has come back, whether anyone has been sent off.
library;

import 'dart:math' as math;

import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_event.dart';
import 'package:marma/domain/entities/refs.dart';

/// Which factual sentence a row carries. Selection is a priority ladder
/// (§5.2), NOT "the highest-scoring component" — a red card two minutes ago is
/// more useful than "level", even though the level term scores higher.
enum ReasonCode {
  shootout,
  extraTime,
  dismissalMany,
  dismissalOne,
  comebackLead,
  burst,
  comebackLevel,
  goallessLate,
  goalless,
  levelLate,
  level,
  oneGoalLate,
  oneGoal,
  goalsSoFar,
  inPlay,
}

/// Where the recent-goal-burst evidence came from. The phrase catalogue may
/// only use a phrase the evidence supports (§5.3): `burst` requires
/// [DensitySource.events].
enum DensitySource { events, halftime, none }

/// A live fixture that qualified for the ranking, plus everything the reason
/// line needs. Immutable; built once per snapshot.
class WorthWatchingEntry {
  const WorthWatchingEntry({
    required this.fixture,
    required this.tension,
    required this.minute,
    required this.margin,
    required this.total,
    required this.reason,
    required this.densitySource,
    this.teamName,
    this.reasonMinute,
    this.reasonExtra,
    this.burstGoals,
    this.burstSpan,
  });

  final Fixture fixture;

  /// UNITLESS ORDERING KEY — NEVER RENDER. See the library doc comment.
  final double tension;

  final int minute;
  final int margin;
  final int total;
  final ReasonCode reason;
  final DensitySource densitySource;

  /// Named only to attribute a past fact (§5.5): the dismissed player's side
  /// for [ReasonCode.dismissalOne], the current leader for
  /// [ReasonCode.comebackLead]. Never used to compare two teams' prospects.
  final String? teamName;

  /// The minute a cited event happened — a red card's, never the live minute
  /// (the row's badge already carries that).
  final int? reasonMinute;
  final int? reasonExtra;

  /// `4 goals in 12 minutes`.
  final int? burstGoals;
  final int? burstSpan;

  String get fixtureId => fixture.id;
}

/// Dismissal predicate, deliberately LOCAL to this feature.
///
/// `MatchEvent.isRedCard` matches only `'red'`, so API-Football's
/// `"Second Yellow card"` — a genuine sending-off — slips past it. Other
/// surfaces depend on that widget-facing predicate, so it is left byte-
/// unchanged and the divergence is pinned by a test instead.
bool isDismissal(MatchEvent e) {
  if (e.type != EventType.card) return false;
  final String d = e.detail.toLowerCase();
  return d.contains('red') || d.contains('second yellow');
}

/// Tuning constants. Named so tests reference names, not magic numbers.
class WorthWatching {
  const WorthWatching._();

  /// Below this, a match is not "worth watching" and never appears.
  static const double kFloor = 32.0;

  /// "Late on" in the phrase catalogue.
  static const int kLateMinute = 80;

  /// The recent-goal window, in minutes.
  static const int kBurstWindow = 15;

  /// A shoot-out is the top of the list by construction, and sorts as if it
  /// were the 130th minute.
  static const double kShootoutTension = 100.0;
  static const int kShootoutMinute = 130;

  /// Status codes that can enter the ranking. `HT` and `BT` are excluded: the
  /// phase is live-ish, but nothing is happening during a break and every
  /// phrase is minute-anchored.
  static const Set<String> kRankableCodes = <String>{'1H', '2H', 'ET', 'P', 'LIVE'};

  // (a) closeness(margin) -> 0..30
  static int closeness(int margin) {
    if (margin == 0) return 30;
    if (margin == 1) return 22;
    if (margin == 2) return 8;
    return 0;
  }

  /// (b) latenessFactor(minute) -> 0.20 .. 2.00, piecewise linear, continuous.
  static double latenessFactor(int minute) {
    if (minute <= 20) return 0.20;
    if (minute <= 45) return 0.20 + 0.40 * (minute - 20) / 25;
    if (minute <= 60) return 0.60 + 0.40 * (minute - 45) / 15;
    if (minute <= 75) return 1.00 + 0.40 * (minute - 60) / 15;
    if (minute <= 90) return 1.40 + 0.60 * (minute - 75) / 15;
    return 2.00;
  }

  /// (d) goalVolume(total) -> 0..12. A small, lateness-independent nudge so a
  /// goal-heavy match is not invisible before the hour.
  static int goalVolume(int total) {
    if (total <= 2) return 0;
    if (total == 3) return 4;
    if (total <= 5) return 8;
    return 12;
  }

  /// (e) events-path density points for N goals inside the window.
  static int burstPoints(int goalsInWindow) {
    if (goalsInWindow <= 0) return 0;
    if (goalsInWindow == 1) return 4;
    if (goalsInWindow == 2) return 12;
    if (goalsInWindow == 3) return 18;
    return 22;
  }

  /// (h) The stakes-free blowout handling. `closeness` is already 0 at
  /// margin >= 3, so this only attenuates the event-driven terms.
  static double blowoutDamper(int margin) {
    if (margin <= 2) return 1.00;
    if (margin == 3) return 0.55;
    return 0.30;
  }
}

/// Intermediate, testable breakdown for one fixture. Exposed so the unit tests
/// can assert each component of §4.11 rather than only the total.
class TensionBreakdown {
  const TensionBreakdown({
    required this.core,
    required this.goalVolume,
    required this.swing,
    required this.density,
    required this.dismissal,
    required this.damper,
    required this.tension,
    required this.densitySource,
    required this.leadChanges,
    required this.maxDeficit,
    required this.goalsInWindow,
    required this.burstSpan,
    required this.dismissalCount,
    this.dismissalTeamId,
    this.dismissalMinute,
    this.dismissalExtra,
  });

  final double core;
  final int goalVolume;
  final int swing;
  final int density;
  final int dismissal;
  final double damper;
  final double tension;
  final DensitySource densitySource;
  final int leadChanges;
  final int maxDeficit;
  final int goalsInWindow;

  /// Minutes from the earliest in-window goal to now, clamped >= 1.
  final int burstSpan;

  final int dismissalCount;

  /// Attribution for [ReasonCode.dismissalOne] — the dismissed player's side
  /// and the minute it happened.
  final String? dismissalTeamId;
  final int? dismissalMinute;
  final int? dismissalExtra;
}

/// Is this fixture allowed into the ranking at all (§4.3)?
///
/// An excluded candidate is never an error — it simply does not enter the
/// ranking, and still renders normally in the list below.
bool isRankable(Fixture f) {
  final String code = f.status.shortCode.toUpperCase().trim();
  if (!WorthWatching.kRankableCodes.contains(code)) return false;
  // We do NOT derive a minute from `timestamp` and the device clock: a delayed
  // kickoff makes that derivation wrong by 15+ minutes and every phrase would
  // then state a false fact.
  if (f.status.elapsed == null && code != 'P') return false;
  // A live fixture with null goals is malformed; exclude rather than treat it
  // as 0-0 and publish a scoreline the API never sent.
  if (f.homeGoals == null || f.awayGoals == null) return false;
  return true;
}

int _eventMinute(MatchEvent e) => (e.elapsed ?? 0) + (e.extra ?? 0);

int _sign(int value) => value == 0 ? 0 : (value > 0 ? 1 : -1);

/// Scores, ranks and explains one live fixture. Returns null when the fixture
/// is not rankable (§4.3) — never throws, whatever the payload contains.
WorthWatchingEntry? evaluateWorthWatching(Fixture f) {
  if (!isRankable(f)) return null;

  final String code = f.status.shortCode.toUpperCase().trim();
  final int gh = f.homeGoals!;
  final int ga = f.awayGoals!;
  final int total = gh + ga;
  final int margin = (gh - ga).abs();

  // A shoot-out is not scored, it is pinned: nothing that follows can be more
  // worth watching than penalties, and there is no minute to anchor a phrase to.
  if (code == 'P') {
    return WorthWatchingEntry(
      fixture: f,
      tension: WorthWatching.kShootoutTension,
      minute: WorthWatching.kShootoutMinute,
      margin: margin,
      total: total,
      reason: ReasonCode.shootout,
      densitySource: DensitySource.none,
    );
  }

  final TensionBreakdown b = tensionBreakdown(f);
  final int minute =
      ((f.status.elapsed ?? 0) + (f.status.extra ?? 0)).clamp(0, 130);

  return _withReason(f, b, minute: minute, margin: margin, total: total);
}

/// The §4.6 formula, component by component.
TensionBreakdown tensionBreakdown(Fixture f) {
  final int gh = f.homeGoals ?? 0;
  final int ga = f.awayGoals ?? 0;
  final int total = gh + ga;
  final int margin = (gh - ga).abs();
  final int nowLead = _sign(gh - ga);
  final int minute =
      ((f.status.elapsed ?? 0) + (f.status.extra ?? 0)).clamp(0, 130);

  // ---- event hygiene (§4.5) -------------------------------------------------
  final String homeId = f.home.id;
  final String awayId = f.away.id;
  final List<MatchEvent> usable = f.events
      .where((MatchEvent e) =>
          // Events with a null minute cannot be placed on the timeline.
          e.elapsed != null &&
          // Matching neither side: drop it rather than guess.
          (e.teamId == homeId || e.teamId == awayId))
      .toList(growable: false)
    ..sort((MatchEvent a, MatchEvent b) => a.sortKey.compareTo(b.sortKey));

  final List<MatchEvent> goalEvents = usable
      .where((MatchEvent e) =>
          e.type == EventType.goal &&
          // API-Football emits `type: "Goal"` with `detail: "Missed Penalty"`.
          !e.detail.toLowerCase().contains('missed'))
      .toList(growable: false);

  final List<MatchEvent> dismissals =
      usable.where(isDismissal).toList(growable: false);

  // ---- goal replay (§4.4f) --------------------------------------------------
  // The replay NEVER overrides `goals`: on a partial feed the replayed
  // scoreline routinely disagrees with the API's, and `margin` / `total` /
  // `nowLead` always come from `goals`. The replay supplies only the shape of
  // the match — lead changes, equalisers, the deepest hole a side climbed out
  // of — which no other field carries.
  int rh = 0;
  int rw = 0;
  int prevLead = 0;
  // The most recent NON-ZERO leader. A lead change is scored against this,
  // not against the immediately preceding state: every lead change in football
  // passes through level, so comparing consecutive states would make the
  // events path structurally incapable of ever recording one.
  int lastLead = 0;
  int evLeadChanges = 0;
  int evEqualisers = 0;
  int homeDeficit = 0;
  int awayDeficit = 0;
  for (final MatchEvent g in goalEvents) {
    // An own goal credits the OPPOSING team.
    final bool own = g.detail.toLowerCase().contains('own');
    final bool creditHome = own ? g.teamId == awayId : g.teamId == homeId;
    if (creditHome) {
      rh++;
    } else {
      rw++;
    }
    final int lead = _sign(rh - rw);
    if (lead != 0 && lastLead != 0 && lead != lastLead) {
      evLeadChanges++;
    } else if (prevLead != 0 && lead == 0) {
      evEqualisers++;
    }
    if (lead != 0) lastLead = lead;
    prevLead = lead;
    homeDeficit = math.max(homeDeficit, rw - rh);
    awayDeficit = math.max(awayDeficit, rh - rw);
  }
  final int evMaxDeficit = rh > rw
      ? homeDeficit
      : (rw > rh ? awayDeficit : math.max(homeDeficit, awayDeficit));

  // ---- halftime evidence ----------------------------------------------------
  final ScoreLine ht = f.halftime;
  final bool htPresent = ht.isPresent;
  final int hth = ht.home ?? 0;
  final int hta = ht.away ?? 0;
  final int htMargin = (hth - hta).abs();
  final int htLead = _sign(hth - hta);
  final int secondHalfGoals = math.max(0, total - (hth + hta));

  // ---- (c) core -------------------------------------------------------------
  // Multiplicative, not additive: this is what stops a 5' 0-0 (level, but
  // meaningless) from qualifying, and stops lateness alone from lifting a 0-4.
  final double core =
      WorthWatching.closeness(margin) * WorthWatching.latenessFactor(minute);

  // ---- (f) swing: take the MAXIMUM of whichever paths are computable --------
  int evSwing = -1;
  if (goalEvents.length >= 2) {
    evSwing = math.min(
      16,
      8 * evLeadChanges + 5 * evEqualisers + 3 * math.max(0, evMaxDeficit - 1),
    );
  }
  int htSwing = -1;
  int htLeadChanges = 0;
  int htMaxDeficit = 0;
  if (htPresent && minute > 45) {
    if (htLead != 0 && nowLead != 0 && htLead != nowLead) {
      htSwing = 16;
      htLeadChanges = 1;
    } else if (htLead != 0 && nowLead == 0 && htMargin >= 2) {
      htSwing = 16;
    } else if (htLead != 0 && nowLead == 0) {
      htSwing = 12;
    } else if (htLead == 0 && margin == 1) {
      htSwing = 6;
    } else {
      htSwing = 0;
    }
    htMaxDeficit = (htLead != 0 && nowLead != htLead) ? htMargin : 0;
  }
  final int swing = math.max(math.max(evSwing, htSwing), 0);
  final int leadChanges = math.max(evLeadChanges, htLeadChanges);
  final int maxDeficit = math.max(evMaxDeficit, htMaxDeficit);

  // ---- (e) density: same "take the maximum" rule ---------------------------
  // A partial event feed must never score LOWER than the events-free path.
  int goalsInWindow = 0;
  int earliestInWindow = minute;
  int evDensity = -1;
  if (goalEvents.isNotEmpty) {
    for (final MatchEvent g in goalEvents) {
      final int m = _eventMinute(g);
      if (m >= minute - WorthWatching.kBurstWindow) {
        goalsInWindow++;
        earliestInWindow = math.min(earliestInWindow, m);
      }
    }
    evDensity = WorthWatching.burstPoints(goalsInWindow);
  }
  int htDensity = -1;
  if (htPresent && minute >= 60) {
    // Capped below the events path: we know less, so we claim less.
    htDensity = math.min(secondHalfGoals, 4) * 3;
  }
  final int density = math.max(math.max(evDensity, htDensity), 0);
  final DensitySource densitySource = (evDensity >= htDensity && evDensity > 0)
      ? DensitySource.events
      : (htDensity > 0 ? DensitySource.halftime : DensitySource.none);

  // ---- (g) dismissal --------------------------------------------------------
  int dismissalPts = 0;
  MatchEvent? lastDismissal;
  if (dismissals.isNotEmpty) {
    int mostRecent = 0;
    for (final MatchEvent d in dismissals) {
      final int m = _eventMinute(d);
      if (lastDismissal == null || m >= mostRecent) lastDismissal = d;
      mostRecent = math.max(mostRecent, m);
    }
    final int base =
        (minute - mostRecent) <= WorthWatching.kBurstWindow ? 14 : 10;
    dismissalPts = (base + 3 * (dismissals.length - 1)).clamp(0, 16);
  }

  final double damper = WorthWatching.blowoutDamper(margin);
  final double tension =
      (core + WorthWatching.goalVolume(total) + swing + density + dismissalPts) *
          damper;

  return TensionBreakdown(
    core: core,
    goalVolume: WorthWatching.goalVolume(total),
    swing: swing,
    density: density,
    dismissal: dismissalPts,
    damper: damper,
    tension: tension,
    densitySource: densitySource,
    leadChanges: leadChanges,
    maxDeficit: maxDeficit,
    goalsInWindow: goalsInWindow,
    burstSpan: math.max(1, minute - earliestInWindow),
    dismissalCount: dismissals.length,
    dismissalTeamId: lastDismissal?.teamId,
    dismissalMinute: lastDismissal?.elapsed,
    dismissalExtra: lastDismissal?.extra,
  );
}

/// The §5.2 priority ladder. THE FIRST MATCHING GUARD WINS — priority encodes
/// newsworthiness, not magnitude.
///
/// Every guard describes something that has already happened. There is no
/// future tense anywhere in this function or in the catalogue it selects from.
WorthWatchingEntry _withReason(
  Fixture f,
  TensionBreakdown b, {
  required int minute,
  required int margin,
  required int total,
}) {
  final String code = f.status.shortCode.toUpperCase().trim();
  final bool late = minute >= WorthWatching.kLateMinute;
  final int nowLead = _sign((f.homeGoals ?? 0) - (f.awayGoals ?? 0));

  String? team;
  int? reasonMinute;
  int? reasonExtra;
  int? burstGoals;
  int? burstSpan;
  final ReasonCode reason;

  if (code == 'ET') {
    reason = ReasonCode.extraTime;
  } else if (b.dismissalCount >= 2) {
    reason = ReasonCode.dismissalMany;
  } else if (b.dismissalCount == 1) {
    reason = ReasonCode.dismissalOne;
    team = b.dismissalTeamId == f.home.id ? f.home.name : f.away.name;
    reasonMinute = b.dismissalMinute;
    reasonExtra = b.dismissalExtra;
  } else if (b.leadChanges >= 1) {
    // The team that currently leads — by definition the one that turned it
    // around. Naming it attributes a past fact; it compares nothing (B4).
    reason = ReasonCode.comebackLead;
    team = nowLead > 0 ? f.home.name : f.away.name;
  } else if (b.densitySource == DensitySource.events && b.goalsInWindow >= 2) {
    reason = ReasonCode.burst;
    burstGoals = b.goalsInWindow;
    burstSpan = b.burstSpan;
  } else if (margin == 0 && b.maxDeficit >= 2) {
    reason = ReasonCode.comebackLevel;
  } else if (total == 0 && late) {
    reason = ReasonCode.goallessLate;
  } else if (total == 0) {
    reason = ReasonCode.goalless;
  } else if (margin == 0 && late) {
    reason = ReasonCode.levelLate;
  } else if (margin == 0) {
    reason = ReasonCode.level;
  } else if (margin == 1 && late) {
    reason = ReasonCode.oneGoalLate;
  } else if (margin == 1) {
    reason = ReasonCode.oneGoal;
  } else if (total >= 4) {
    reason = ReasonCode.goalsSoFar;
    burstGoals = total;
  } else {
    // Unreachable at kFloor = 32, but a row must NEVER be blank.
    reason = ReasonCode.inPlay;
  }

  return WorthWatchingEntry(
    fixture: f,
    tension: b.tension,
    minute: minute,
    margin: margin,
    total: total,
    reason: reason,
    densitySource: b.densitySource,
    teamName: team,
    reasonMinute: reasonMinute,
    reasonExtra: reasonExtra,
    burstGoals: burstGoals,
    burstSpan: burstSpan,
  );
}

/// Deterministic tie-breaks (§4.8). First difference wins.
///
/// Never iterate a Set/Map and rely on insertion order — sort explicitly, or
/// the list churns between polls and the widget tests are not reproducible.
/// There is deliberately no league, prestige or favourites tie-break (§3.7).
int compareWorthWatching(WorthWatchingEntry a, WorthWatchingEntry b) {
  final int byTension = b.tension.compareTo(a.tension);
  if (byTension != 0) return byTension;
  final int byMinute = b.minute.compareTo(a.minute);
  if (byMinute != 0) return byMinute;
  final int byMargin = a.margin.compareTo(b.margin);
  if (byMargin != 0) return byMargin;
  final int byTotal = b.total.compareTo(a.total);
  if (byTotal != 0) return byTotal;
  return a.fixtureId.compareTo(b.fixtureId);
}

/// The whole of surface A's model: one pass over the current `/live` snapshot.
///
/// O(n + sum of events) over <= ~120 live fixtures; budget < 3 ms. Memoise it
/// behind a `Provider` — never call it from `build()`.
///
/// Returns the FULL qualifying list, ordered. Trimming to three is a
/// presentation decision and lives in the notifier.
List<WorthWatchingEntry> rankLiveMatches(LiveSnapshot snapshot) {
  final List<WorthWatchingEntry> out = <WorthWatchingEntry>[];
  for (final Fixture f in snapshot.byId.values) {
    final WorthWatchingEntry? entry = evaluateWorthWatching(f);
    if (entry == null) continue;
    if (entry.tension < WorthWatching.kFloor) continue;
    out.add(entry);
  }
  out.sort(compareWorthWatching);
  return List<WorthWatchingEntry>.unmodifiable(out);
}
