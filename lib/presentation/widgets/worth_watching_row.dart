import 'package:flutter/material.dart';
import 'package:marma/core/extensions/context_x.dart';
import 'package:marma/core/utils/app_format.dart';
import 'package:marma/core/utils/bidi.dart';
import 'package:marma/domain/services/worth_watching.dart';
import 'package:marma/l10n/app_localizations.dart';
import 'package:marma/presentation/theme/app_colors.dart';
import 'package:marma/presentation/theme/app_spacing.dart';
import 'package:marma/presentation/widgets/match_row.dart';

/// The one factual sentence a ranked row carries.
///
/// Every phrase is PAST OR PRESENT TENSE and describes something that has
/// already happened. There is no "will", "could", "expected", "likely",
/// "on course for" or "set to" in the catalogue, in either locale, and no
/// number derived from the ordering appears in any of them.
/// `test/domain/worth_watching_test.dart` renders every code in both locales
/// and asserts it against the banned-token list.
String worthReasonText(
  AppL10n l10n,
  String languageCode,
  WorthWatchingEntry entry,
) {
  switch (entry.reason) {
    case ReasonCode.shootout:
      return l10n.worthReasonShootout;
    case ReasonCode.extraTime:
      return l10n.worthReasonExtraTime;
    case ReasonCode.dismissalMany:
      return l10n.worthReasonRedCardMany;
    case ReasonCode.dismissalOne:
      return l10n.worthReasonRedCardOne(
        bidiIsolate(entry.teamName),
        // `+` is bidi-neutral, so an added-time citation must be isolated too.
        bidiIsolate(AppFormat.minuteOrdinal(
          entry.reasonMinute ?? entry.minute,
          extra: entry.reasonExtra ?? 0,
          languageCode: languageCode,
        )),
      );
    case ReasonCode.comebackLead:
      return l10n.worthReasonComebackLead(bidiIsolate(entry.teamName));
    case ReasonCode.burst:
      return l10n.worthReasonBurst(
        l10n.worthBurstGoals(entry.burstGoals ?? 0),
        l10n.worthBurstMinutes(entry.burstSpan ?? 1),
      );
    case ReasonCode.comebackLevel:
      return l10n.worthReasonComebackLevel;
    case ReasonCode.goallessLate:
      return l10n.worthReasonGoallessLate;
    case ReasonCode.goalless:
      return l10n.worthReasonGoalless;
    case ReasonCode.levelLate:
      return l10n.worthReasonLevelLate;
    case ReasonCode.level:
      return l10n.worthReasonLevel;
    case ReasonCode.oneGoalLate:
      return l10n.worthReasonOneGoalLate;
    case ReasonCode.oneGoal:
      return l10n.worthReasonOneGoal;
    case ReasonCode.goalsSoFar:
      return l10n.worthReasonGoalsSoFar(l10n.worthBurstGoals(entry.burstGoals ?? 0));
    case ReasonCode.inPlay:
      return l10n.worthReasonInPlay;
  }
}

/// A ranked row: the UNMODIFIED [MatchRow] atom with one sentence beneath it.
///
/// No fork, no copy, no variant flag — `MatchRow` supplies the `InkWell`, the
/// 68 dp minimum height, the live badge, the team badges, the score column,
/// long-press actions and navigation to `/match/:id`. None of that is
/// re-implemented here.
class WorthWatchingRow extends StatelessWidget {
  const WorthWatchingRow({
    required this.entry,
    this.rewardedOnOpen = false,
    super.key,
  });

  final WorthWatchingEntry entry;
  final bool rewardedOnOpen;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MatchRow(
            fixtureId: entry.fixtureId,
            fallback: entry.fixture,
            rewardedOnOpen: rewardedOnOpen,
          ),
          _ReasonLine(
            text: worthReasonText(context.l10n, context.languageCode, entry),
          ),
        ],
      ),
    );
  }
}

class _ReasonLine extends StatelessWidget {
  const _ReasonLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final MarmaColors colors = context.colors;
    return Padding(
      // 60 = MatchRow's status-column minimum (52) plus its gap (8), so the
      // phrase aligns under the team names. At large text scales the status
      // cell grows and the alignment becomes approximate BY DESIGN — never
      // clamp it, never let it overflow.
      padding: const EdgeInsetsDirectional.only(
        start: 60,
        end: AppSpacing.lg,
        bottom: AppSpacing.sm + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Ornament only: identical on every row, encodes nothing. It is NOT
          // a magnitude, NOT proportional to anything, and is excluded from
          // semantics. Fixed size so it cannot balloon at 1.6x type.
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.type.label.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
