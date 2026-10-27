import 'package:flutter/material.dart';
import 'package:marma/domain/entities/journal/journal_enums.dart';
import 'package:marma/presentation/theme/app_colors.dart';

/// Line icons for every journal vocabulary — the single replacement for the
/// emoji the journal used to draw. Domain enums keep their glyph strings for
/// stored data; nothing in the UI renders them any more.
class JournalIcons {
  const JournalIcons._();

  static const IconData note = Icons.edit_note_rounded;
  static const IconData reactions = Icons.local_fire_department_outlined;
  static const IconData mood = Icons.mood_rounded;
  static const IconData tags = Icons.sell_outlined;
  static const IconData memory = Icons.place_outlined;
  static const IconData motm = Icons.emoji_events_outlined;
  static const IconData rewatch = Icons.replay_rounded;
  static const IconData activity = Icons.history_rounded;
  static const IconData moments = Icons.favorite_border_rounded;
  static const IconData timeline = Icons.timer_outlined;
  static const IconData goal = Icons.sports_soccer_rounded;
  static const IconData rating = Icons.star_outline_rounded;
  static const IconData players = Icons.groups_outlined;
  static const IconData tactical = Icons.schema_outlined;
  static const IconData prediction = Icons.online_prediction_rounded;
  static const IconData stats = Icons.bar_chart_rounded;
  static const IconData star = Icons.star_rounded;

  static const IconData assists = Icons.call_made_rounded;
  static const IconData keyPasses = Icons.vpn_key_outlined;
  static const IconData defending = Icons.shield_outlined;

  static IconData activityKind(JournalActivityKind k) => switch (k) {
        JournalActivityKind.created => Icons.menu_book_rounded,
        JournalActivityKind.noteUpdated => note,
        JournalActivityKind.rated => rating,
        JournalActivityKind.reactionAdded => reactions,
        JournalActivityKind.moodSet => mood,
        JournalActivityKind.momentAdded => moments,
        JournalActivityKind.favouriteGoalSet => goal,
        JournalActivityKind.manOfTheMatchSet => motm,
        JournalActivityKind.playerRated => players,
        JournalActivityKind.predictionMade => prediction,
        JournalActivityKind.tacticalUpdated => tactical,
        JournalActivityKind.memoryWritten => memory,
        JournalActivityKind.eventAdded => timeline,
        JournalActivityKind.statAdded => stats,
        JournalActivityKind.tagAdded => tags,
        JournalActivityKind.watchedAgain => rewatch,
      };

  static IconData goalKind(GoalKind k) => switch (k) {
        GoalKind.longShot => Icons.rocket_launch_outlined,
        GoalKind.counterAttack => Icons.bolt_rounded,
        GoalKind.freeKick => Icons.gps_fixed_rounded,
        GoalKind.header => Icons.face_outlined,
        GoalKind.penalty => Icons.adjust_rounded,
        GoalKind.teamGoal => Icons.groups_rounded,
        GoalKind.soloGoal => Icons.directions_run_rounded,
      };

  static IconData eventKind(JournalEventKind k) => switch (k) {
        JournalEventKind.goal => goal,
        JournalEventKind.yellowCard || JournalEventKind.redCard => Icons.square_rounded,
        JournalEventKind.substitution => Icons.swap_horiz_rounded,
        JournalEventKind.save => Icons.back_hand_outlined,
        JournalEventKind.assist => assists,
        JournalEventKind.missedChance => Icons.close_rounded,
        JournalEventKind.refereeDecision => Icons.sports_rounded,
      };

  /// Cards keep their real colours; everything else takes the accent.
  static Color eventTint(JournalEventKind k, MarmaColors colors) => switch (k) {
        JournalEventKind.yellowCard => const Color(0xFFF5C542),
        JournalEventKind.redCard => colors.danger,
        _ => colors.accent,
      };

  /// Moment markers, by the key the moment form now stores.
  static const Map<String, IconData> momentKeys = <String, IconData>{
    'goal': Icons.sports_soccer_rounded,
    'fire': Icons.local_fire_department_outlined,
    'shock': Icons.priority_high_rounded,
    'wow': Icons.auto_awesome_outlined,
    'save': Icons.back_hand_outlined,
    'target': Icons.gps_fixed_rounded,
    'red': Icons.square_rounded,
    'heartbreak': Icons.heart_broken_outlined,
    'applause': Icons.celebration_outlined,
    'magic': Icons.auto_fix_high_outlined,
  };

  /// Moments saved before icons stored the emoji itself.
  static const Map<String, String> _legacyMoment = <String, String>{
    '⚽': 'goal', '🔥': 'fire', '😱': 'shock', '🤯': 'wow', '🧤': 'save',
    '🎯': 'target', '🟥': 'red', '💔': 'heartbreak', '👏': 'applause', '🎩': 'magic',
  };

  /// Normalises a stored moment marker (new key or legacy emoji) to a key.
  static String momentKey(String? stored) =>
      momentKeys.containsKey(stored) ? stored! : (_legacyMoment[stored] ?? 'goal');

  static IconData moment(String? stored) => momentKeys[momentKey(stored)]!;
}
