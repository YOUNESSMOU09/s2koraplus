import 'package:marma/domain/entities/app_settings.dart';
import 'package:marma/domain/entities/day_bucket.dart';
import 'package:marma/domain/entities/fixture.dart';
import 'package:marma/domain/entities/match_status.dart';

enum FollowingSection { live, laterToday, tomorrow, finished }

class FollowingFeed {
  const FollowingFeed({required this.sections, required this.totalCount});

  /// Ordered, non-empty sections only.
  final List<MapEntry<FollowingSection, List<Fixture>>> sections;
  final int totalCount;

  bool get isEmpty => totalCount == 0;

  static const FollowingFeed empty =
      FollowingFeed(sections: <MapEntry<FollowingSection, List<Fixture>>>[], totalCount: 0);
}

/// Client-side filtering of the three cached buckets + the live snapshot.
///
/// A followed competition with no fixtures in the three-day window (e.g. a
/// league that is out of season) is a legitimate, designed empty result — not
/// an error.
FollowingFeed buildFollowingFeed({
  required Favourites favourites,
  required List<DayBucket> buckets,
  required LiveSnapshot live,
}) {
  if (favourites.isEmpty) return FollowingFeed.empty;

  final Set<String> teamIds = favourites.teamIds;
  final Set<String> leagueIds = favourites.leagueIds;

  final Map<String, Fixture> selected = <String, Fixture>{};
  for (final DayBucket bucket in buckets) {
    for (final Fixture f in bucket.byId.values) {
      if (f.involvesTeam(teamIds) || leagueIds.contains(f.league.id)) {
        final Fixture? liveVersion = live.byId[f.id];
        selected[f.id] = liveVersion == null ? f : f.mergeLive(liveVersion);
      }
    }
  }
  // Live fixtures the buckets may not carry yet.
  for (final Fixture f in live.byId.values) {
    if (f.involvesTeam(teamIds) || leagueIds.contains(f.league.id)) {
      selected.putIfAbsent(f.id, () => f);
    }
  }

  if (selected.isEmpty) return FollowingFeed.empty;

  final DateTime now = DateTime.now();
  final DateTime endOfToday =
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

  final List<Fixture> liveList = <Fixture>[];
  final List<Fixture> laterToday = <Fixture>[];
  final List<Fixture> tomorrow = <Fixture>[];
  final List<Fixture> finished = <Fixture>[];

  for (final Fixture f in selected.values) {
    final MatchPhase phase = f.phase;
    if (phase.isLiveish) {
      liveList.add(f);
    } else if (phase == MatchPhase.finished ||
        phase == MatchPhase.abandoned ||
        phase == MatchPhase.postponed) {
      finished.add(f);
    } else if (f.kickoffLocal.isBefore(endOfToday)) {
      laterToday.add(f);
    } else {
      tomorrow.add(f);
    }
  }

  int byKickoff(Fixture a, Fixture b) {
    final int t = a.timestamp.compareTo(b.timestamp);
    return t != 0 ? t : a.id.compareTo(b.id);
  }

  liveList.sort(byKickoff);
  laterToday.sort(byKickoff);
  tomorrow.sort(byKickoff);
  finished.sort((Fixture a, Fixture b) => byKickoff(b, a)); // most recent first

  final List<MapEntry<FollowingSection, List<Fixture>>> sections =
      <MapEntry<FollowingSection, List<Fixture>>>[
    if (liveList.isNotEmpty) MapEntry<FollowingSection, List<Fixture>>(FollowingSection.live, liveList),
    if (laterToday.isNotEmpty)
      MapEntry<FollowingSection, List<Fixture>>(FollowingSection.laterToday, laterToday),
    if (tomorrow.isNotEmpty)
      MapEntry<FollowingSection, List<Fixture>>(FollowingSection.tomorrow, tomorrow),
    if (finished.isNotEmpty)
      MapEntry<FollowingSection, List<Fixture>>(FollowingSection.finished, finished),
  ];

  return FollowingFeed(sections: sections, totalCount: selected.length);
}
