import 'package:marma/domain/entities/match_event.dart';
import 'package:marma/domain/entities/match_status.dart';
import 'package:marma/l10n/app_localizations.dart';

/// Localised long form for every one of the 19 API status codes.
///
/// An unrecognised code falls back to the API's own `long` text rather than a
/// blank or an English placeholder — the app must never render nothing.
String localisedStatusLong(AppL10n l10n, MatchStatus status) {
  switch (status.shortCode.toUpperCase()) {
    case 'TBD':
      return l10n.statusTbd;
    case 'NS':
      return l10n.statusNs;
    case '1H':
      return l10n.statusFirstHalf;
    case 'HT':
      return l10n.statusHalfTime;
    case '2H':
      return l10n.statusSecondHalf;
    case 'ET':
      return l10n.statusExtraTime;
    case 'BT':
      return l10n.statusBreakTime;
    case 'P':
      return l10n.statusPenaltyShootout;
    case 'SUSP':
      return l10n.statusSuspended;
    case 'INT':
      return l10n.statusInterrupted;
    case 'FT':
      return l10n.statusFullTime;
    case 'AET':
      return l10n.statusAfterExtraTime;
    case 'PEN':
      return l10n.statusAfterPenalties;
    case 'PST':
      return l10n.statusPostponed;
    case 'CANC':
      return l10n.statusCancelled;
    case 'ABD':
      return l10n.statusAbandoned;
    case 'AWD':
      return l10n.statusTechnicalLoss;
    case 'WO':
      return l10n.statusWalkover;
    case 'LIVE':
      return l10n.statusLive;
    default:
      return status.longText;
  }
}

/// Short badge text for the list row's status column.
String localisedStatusAbbr(AppL10n l10n, MatchStatus status) {
  switch (status.shortCode.toUpperCase()) {
    case 'FT':
    case 'AWD':
    case 'WO':
      return l10n.abbrFullTime;
    case 'AET':
      return l10n.abbrAfterExtraTime;
    case 'PEN':
      return l10n.abbrPenalties;
    case 'HT':
      return l10n.abbrHalfTime;
    case 'PST':
      return l10n.abbrPostponed;
    case 'CANC':
      return l10n.abbrCancelled;
    case 'ABD':
    case 'SUSP':
    case 'INT':
      return l10n.abbrAbandoned;
    default:
      return status.shortCode.isEmpty ? l10n.abbrLive : status.shortCode;
  }
}

/// Localised event description. The API's `detail` strings are English and
/// finite, so they map cleanly; anything unknown falls through verbatim.
String localisedEventDetail(AppL10n l10n, MatchEvent event) {
  final String d = event.detail.toLowerCase();
  if (d.contains('own goal')) return l10n.eventOwnGoal;
  if (d.contains('missed penalty')) return l10n.eventMissedPenalty;
  if (d.contains('penalty') && event.type == EventType.goal) {
    return l10n.eventPenaltyGoal;
  }
  if (d.contains('second yellow')) return l10n.eventSecondYellow;
  if (d.contains('yellow')) return l10n.eventYellowCard;
  if (d.contains('red')) return l10n.eventRedCard;
  if (event.type == EventType.subst) return l10n.eventSubstitution;
  if (event.type == EventType.goal) return l10n.eventNormalGoal;
  return event.detail;
}
