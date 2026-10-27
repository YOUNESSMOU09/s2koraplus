// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Marma';

  @override
  String get appTagline => 'No odds. No noise. Just football.';

  @override
  String get navMatches => 'Matches';

  @override
  String get navLive => 'Live';

  @override
  String get navFollowing => 'Following';

  @override
  String get navSettings => 'Settings';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get screenMatches => 'Matches';

  @override
  String get screenLive => 'Live';

  @override
  String get screenFollowing => 'Following';

  @override
  String get screenSettings => 'Settings';

  @override
  String get screenSearch => 'Search';

  @override
  String get screenManageFavourites => 'Manage favourites';

  @override
  String get screenAppearance => 'Appearance';

  @override
  String get screenLanguage => 'Language';

  @override
  String get screenAbout => 'About';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFollow => 'Follow';

  @override
  String get actionUnfollow => 'Unfollow';

  @override
  String get actionGoToToday => 'Go to today';

  @override
  String get actionSeeTodaysFixtures => 'See today\'s fixtures';

  @override
  String get actionAddFavourites => 'Add favourites';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionGetStarted => 'Get started';

  @override
  String get actionSwitchDay => 'Switch day';

  @override
  String get statusTbd => 'Time to be defined';

  @override
  String get statusNs => 'Not started';

  @override
  String get statusFirstHalf => 'First half';

  @override
  String get statusHalfTime => 'Half time';

  @override
  String get statusSecondHalf => 'Second half';

  @override
  String get statusExtraTime => 'Extra time';

  @override
  String get statusBreakTime => 'Break time';

  @override
  String get statusPenaltyShootout => 'Penalty shootout';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusInterrupted => 'Interrupted';

  @override
  String get statusFullTime => 'Full time';

  @override
  String get statusAfterExtraTime => 'After extra time';

  @override
  String get statusAfterPenalties => 'After penalties';

  @override
  String get statusPostponed => 'Postponed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusAbandoned => 'Abandoned';

  @override
  String get statusTechnicalLoss => 'Technical loss';

  @override
  String get statusWalkover => 'Walkover';

  @override
  String get statusLive => 'Live';

  @override
  String get abbrFullTime => 'FT';

  @override
  String get abbrAfterExtraTime => 'AET';

  @override
  String get abbrPenalties => 'PEN';

  @override
  String get abbrHalfTime => 'HT';

  @override
  String get abbrExtraTime => 'ET';

  @override
  String get abbrPostponed => 'POST';

  @override
  String get abbrCancelled => 'CANC';

  @override
  String get abbrAbandoned => 'ABD';

  @override
  String get abbrLive => 'LIVE';

  @override
  String get eventNormalGoal => 'Goal';

  @override
  String get eventOwnGoal => 'Own goal';

  @override
  String get eventPenaltyGoal => 'Penalty';

  @override
  String get eventMissedPenalty => 'Missed penalty';

  @override
  String get eventYellowCard => 'Yellow card';

  @override
  String get eventRedCard => 'Red card';

  @override
  String get eventSecondYellow => 'Second yellow';

  @override
  String get eventSubstitution => 'Substitution';

  @override
  String get labelVenue => 'Venue';

  @override
  String get labelReferee => 'Referee';

  @override
  String get labelRound => 'Round';

  @override
  String get labelSeason => 'Season';

  @override
  String get labelKickoff => 'Kick-off';

  @override
  String get labelCompetition => 'Competition';

  @override
  String get labelTimeline => 'Timeline';

  @override
  String get labelCompetitions => 'Competitions';

  @override
  String get labelTeams => 'Teams';

  @override
  String get labelMatches => 'Matches';

  @override
  String labelAssist(String name) {
    return 'Assist: $name';
  }

  @override
  String labelFullTimeScore(String home, String away) {
    return 'FT $home–$away';
  }

  @override
  String labelPenaltiesScore(String home, String away) {
    return 'PEN $home–$away';
  }

  @override
  String get freshUpdatedJustNow => 'Updated just now';

  @override
  String freshUpdatedMinutesAgo(int minutes) {
    return 'Updated $minutes min ago';
  }

  @override
  String freshOfflineFrom(int minutes) {
    return 'Offline · from $minutes min ago';
  }

  @override
  String get freshOfflineNoData => 'Offline';

  @override
  String get freshNeverUpdated => 'Not updated yet';

  @override
  String get offlineBanner => 'You\'re offline. Showing saved scores.';

  @override
  String get errorOfflineTitle => 'You\'re offline';

  @override
  String errorOfflineBody(int minutes) {
    return 'Showing scores saved $minutes min ago.';
  }

  @override
  String get errorOfflineBodyNoCache =>
      'Connect to the internet to load today\'s matches.';

  @override
  String get errorTimeoutTitle => 'Scores are taking a while';

  @override
  String get errorTimeoutBody => 'The score feed didn\'t answer in time.';

  @override
  String get errorServerTitle => 'The score feed is having a moment';

  @override
  String get errorServerBody => 'We\'ll keep trying.';

  @override
  String get errorBadResponseTitle => 'We couldn\'t read the score feed';

  @override
  String get errorBadResponseBody =>
      'The response wasn\'t in a shape we understand.';

  @override
  String get errorUnknownTitle => 'Something went wrong';

  @override
  String get errorUnknownBody => 'Pull down to try again.';

  @override
  String get emptyDayTitle => 'No matches scheduled';

  @override
  String get emptyDayBody => 'Football takes the occasional day off.';

  @override
  String get emptyLiveTitle => 'No matches in play right now';

  @override
  String get emptyLiveBody =>
      'Live minutes and goals appear here the moment a match kicks off.';

  @override
  String get emptyFollowingTitle => 'Follow a team to build your feed';

  @override
  String get emptyFollowingBody =>
      'Your teams and competitions from yesterday, today and tomorrow, in one place.';

  @override
  String get emptyFollowingNoFixturesTitle => 'Nothing on for who you follow';

  @override
  String get emptyFollowingNoFixturesBody =>
      'None of your teams or competitions have a match yesterday, today or tomorrow. Some leagues are out of season.';

  @override
  String get emptySearchTitle => 'Search yesterday, today and tomorrow';

  @override
  String get emptySearchBody => 'Find a team, a competition or a country.';

  @override
  String noResultsTitle(String query) {
    return 'No matches for \"$query\"';
  }

  @override
  String get noResultsBody =>
      'Marma searches yesterday, today and tomorrow only.';

  @override
  String get notFoundTitle =>
      'This match isn\'t in the current three-day window';

  @override
  String get notFoundBody => 'Marma only covers yesterday, today and tomorrow.';

  @override
  String get routeNotFoundTitle => 'That screen doesn\'t exist';

  @override
  String get routeNotFoundBody =>
      'The link you followed doesn\'t lead anywhere in Marma.';

  @override
  String get loadingMatches => 'Loading matches';

  @override
  String liveCountLabel(int count) {
    return '$count live';
  }

  @override
  String get sectionLive => 'Live';

  @override
  String get sectionLaterToday => 'Later today';

  @override
  String get sectionTomorrow => 'Tomorrow';

  @override
  String get sectionFinished => 'Finished';

  @override
  String matchesFollowedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
      zero: 'No matches',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionYourFootball => 'Your football';

  @override
  String get settingsSectionLegal => 'Legal & support';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsFollowing => 'Following';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsAbout => 'About Marma';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutAttribution => 'Data provided by GOAL API (goal-api.com).';

  @override
  String get aboutDisclaimer =>
      'Marma is not affiliated with, endorsed by, or connected to any football club, league, federation or governing body. Scores may be delayed and are unofficial.';

  @override
  String get aboutPrivacyPosture =>
      'No account, no login, no tracking. Your favourites, settings and cached scores never leave this device.';

  @override
  String get aboutBackendStatus => 'Score feed status';

  @override
  String get aboutBackendHealthy => 'Healthy';

  @override
  String get aboutBackendUnhealthy => 'Unavailable';

  @override
  String get aboutBackendChecking => 'Checking…';

  @override
  String aboutBackendUpdated(int minutes) {
    return 'Feed updated $minutes min ago';
  }

  @override
  String get aboutClearCache => 'Clear cached data';

  @override
  String aboutClearCacheSubtitle(int kilobytes) {
    return '$kilobytes KB of saved fixtures';
  }

  @override
  String get aboutCacheCleared => 'Cached data cleared.';

  @override
  String get manageEmptyTitle => 'Nothing followed yet';

  @override
  String get manageEmptyBody =>
      'Add a team or competition and it will appear here.';

  @override
  String get manageTeamsHeader => 'Teams';

  @override
  String get manageCompetitionsHeader => 'Competitions';

  @override
  String manageRemoved(String name) {
    return '$name removed';
  }

  @override
  String sheetFollowHome(String name) {
    return 'Follow $name';
  }

  @override
  String sheetFollowCompetition(String name) {
    return 'Follow $name';
  }

  @override
  String sheetUnfollow(String name) {
    return 'Unfollow $name';
  }

  @override
  String semanticsMatchScheduled(
    String home,
    String away,
    String time,
    String competition,
    String country,
  ) {
    return '$home versus $away, kicks off $time, $competition, $country';
  }

  @override
  String semanticsMatchLive(
    String home,
    String homeGoals,
    String away,
    String awayGoals,
    String minute,
    String competition,
    String country,
  ) {
    return '$home $homeGoals, $away $awayGoals, $minute, $competition, $country';
  }

  @override
  String semanticsMinute(String minute) {
    return '${minute}th minute';
  }

  @override
  String semanticsMinuteAdded(String minute, String added) {
    return '${minute}th minute plus $added';
  }

  @override
  String semanticsMatchFinished(
    String home,
    String homeGoals,
    String away,
    String awayGoals,
    String competition,
    String country,
  ) {
    return '$home $homeGoals, $away $awayGoals, full time, $competition, $country';
  }

  @override
  String semanticsFollowToggle(String name) {
    return 'Follow $name';
  }

  @override
  String get semanticsRefresh => 'Refresh scores';

  @override
  String get semanticsSearch => 'Search matches';

  @override
  String semanticsLiveTabBadge(int count) {
    return '$count matches in play';
  }

  @override
  String get searchHint => 'Team, competition or country';

  @override
  String get matchDetailAttribution =>
      'Data provided by GOAL API (goal-api.com). Marma is not affiliated with any club, league or federation. Scores may be delayed and are unofficial.';

  @override
  String get matchDetailNoTimeline =>
      'Goals, cards and substitutions appear here while a match is live.';

  @override
  String get matchDetailTimelineLiveOnly =>
      'Timelines are available for matches in play.';

  @override
  String get worthTitle => 'Worth watching';

  @override
  String get worthSubtitle => 'Live now, ordered by what\'s happening.';

  @override
  String get worthAllLive => 'All live matches';

  @override
  String get worthNoneTight =>
      'Nothing tight right now. Every live match is below.';

  @override
  String get worthPaused =>
      'Paused — these scores are more than 10 minutes old.';

  @override
  String get liveViewCompetition => 'By competition';

  @override
  String get liveViewCountry => 'By country';

  @override
  String get worthReasonShootout => 'Penalty shoot-out';

  @override
  String get worthReasonExtraTime => 'Extra time';

  @override
  String get worthReasonRedCardMany => 'Two players sent off';

  @override
  String worthReasonRedCardOne(String team, String minute) {
    return '$team down to ten since the $minute';
  }

  @override
  String worthReasonComebackLead(String team) {
    return '$team came from behind';
  }

  @override
  String worthReasonBurst(String goals, String span) {
    return '$goals in $span';
  }

  @override
  String get worthReasonComebackLevel => 'Level again after going behind';

  @override
  String get worthReasonGoallessLate => 'Still goalless, late on';

  @override
  String get worthReasonGoalless => 'Goalless, second half';

  @override
  String get worthReasonLevelLate => 'Still level, late on';

  @override
  String get worthReasonLevel => 'Level, second half';

  @override
  String get worthReasonOneGoalLate => 'One goal in it, late on';

  @override
  String get worthReasonOneGoal => 'One goal in it';

  @override
  String worthReasonGoalsSoFar(String goals) {
    return '$goals so far';
  }

  @override
  String get worthReasonInPlay => 'In play';

  @override
  String worthBurstGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goals',
      one: '1 goal',
    );
    return '$_temp0';
  }

  @override
  String worthBurstMinutes(int span) {
    String _temp0 = intl.Intl.pluralLogic(
      span,
      locale: localeName,
      other: '$span minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get worthHowAction => 'How “Worth watching” is ordered';

  @override
  String get worthHowTitle => 'How “Worth watching” is ordered';

  @override
  String get worthHowBody1 =>
      'These are matches being played right now, ordered by what has already happened in them.';

  @override
  String get worthHowBody2 =>
      'Marma looks at how close the score is, how late in the match it is, whether goals have arrived in a short space of time, whether a side has come back, and whether anyone has been sent off.';

  @override
  String get worthHowBody3 =>
      'It is not a prediction. Marma never says who will win, shows no odds, no probabilities and no percentages, and carries no betting content of any kind.';

  @override
  String atlasCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries',
      one: '1 country',
    );
    return '$_temp0';
  }

  @override
  String atlasMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String atlasSummary(String a, String b) {
    return '$a · $b';
  }

  @override
  String atlasAsOf(int minutes) {
    return 'as of $minutes min ago';
  }

  @override
  String atlasOfflineAsOf(int minutes) {
    return 'Offline · as of $minutes min ago';
  }

  @override
  String get atlasInternational => 'International';

  @override
  String get atlasInternationalOnly => 'International competitions only';

  @override
  String semanticsCountryRow(String country, String matches) {
    return '$country, $matches';
  }

  @override
  String semanticsWorthHeader(String matches) {
    return 'Worth watching, $matches';
  }

  @override
  String get journalTitle => 'Football journal';

  @override
  String get journalActionOpen => 'Journal';

  @override
  String get journalEmptyTitle => 'Write your football story.';

  @override
  String get journalEmptyBody =>
      'Save your reactions, favourite moments, predictions, player ratings and memories from the beautiful game.';

  @override
  String get journalEmptyAction => 'Start football journal';

  @override
  String get journalDeleteAction => 'Delete journal';

  @override
  String get journalDeleteTitle => 'Delete this journal?';

  @override
  String get journalDeleteBody =>
      'Everything you wrote about this match is on this device only, and cannot be recovered.';

  @override
  String get journalSectionNote => 'Your notes';

  @override
  String get journalNoteHintMatch => 'What did you think about this match?';

  @override
  String get journalNoteHintTeam => 'What do you think about this team?';

  @override
  String get journalNoteHintPlayer => 'What do you think about this player?';

  @override
  String get journalNoteFormattingHint => '# heading · **bold** · - list';

  @override
  String get journalSaving => 'Saving…';

  @override
  String get journalSavedJustNow => 'Saved just now';

  @override
  String journalSavedAt(String time) {
    return 'Saved at $time';
  }

  @override
  String get journalUnsaved => 'Not saved yet';

  @override
  String journalWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
      zero: 'No words',
    );
    return '$_temp0';
  }

  @override
  String journalCharacterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters',
      one: '1 character',
      zero: '0 characters',
    );
    return '$_temp0';
  }

  @override
  String get journalSectionReactions => 'Match reaction';

  @override
  String get journalReactionsHint => 'Pick as many as you felt.';

  @override
  String get journalReactionIncredible => 'Incredible';

  @override
  String get journalReactionLoved => 'Loved it';

  @override
  String get journalReactionUnbelievable => 'Unbelievable';

  @override
  String get journalReactionFunny => 'Funny';

  @override
  String get journalReactionAngry => 'Angry';

  @override
  String get journalReactionHeartbreaking => 'Heartbreaking';

  @override
  String get journalReactionCrazy => 'Crazy match';

  @override
  String get journalReactionBoring => 'Boring';

  @override
  String get journalReactionGreatPerformance => 'Great performance';

  @override
  String get journalReactionDisaster => 'Disaster';

  @override
  String get journalSectionRating => 'Your match rating';

  @override
  String get journalRatingOverall => 'Overall';

  @override
  String get journalRatingHome => 'Home team';

  @override
  String get journalRatingAway => 'Away team';

  @override
  String get journalRatingReferee => 'Referee';

  @override
  String get journalRatingAtmosphere => 'Atmosphere';

  @override
  String get journalRatingExperience => 'Match experience';

  @override
  String journalRatingOutOf(String value) {
    return '$value/10';
  }

  @override
  String get journalRatingUnset => 'Not rated';

  @override
  String get journalRatingClear => 'Clear rating';

  @override
  String get journalSectionPlayers => 'Player performance';

  @override
  String get journalPlayersEmpty => 'No players rated yet.';

  @override
  String get journalPlayerAdd => 'Add player';

  @override
  String get journalPlayerEdit => 'Edit player';

  @override
  String get journalPlayerName => 'Player name';

  @override
  String get journalPlayerRating => 'Rating';

  @override
  String get journalPlayerGoals => 'Goals';

  @override
  String get journalPlayerAssists => 'Assists';

  @override
  String get journalPlayerKeyPasses => 'Key passes';

  @override
  String get journalPlayerDefending => 'Defensive performance';

  @override
  String get journalPlayerComment => 'Personal comment';

  @override
  String get journalPlayerCommentHint => 'Very dangerous throughout the match.';

  @override
  String get journalPlayerSortRating => 'Highest rated first';

  @override
  String get journalPlayerSortAdded => 'Order added';

  @override
  String get journalSectionMoments => 'Favourite moments';

  @override
  String get journalMomentsEmpty =>
      'Nothing saved yet. The moment you keep replaying goes here.';

  @override
  String get journalMomentAdd => 'Add moment';

  @override
  String get journalMomentEdit => 'Edit moment';

  @override
  String get journalMomentTitle => 'Title';

  @override
  String get journalMomentTitleHint => 'Goal of the night';

  @override
  String get journalMomentDescription => 'What happened';

  @override
  String get journalMomentDescriptionHint =>
      'That counter attack was incredible.';

  @override
  String get journalMomentMinute => 'Minute';

  @override
  String get journalMomentSecond => 'Second';

  @override
  String get journalMomentPlayer => 'Player (optional)';

  @override
  String get journalMomentGlyph => 'Emoji';

  @override
  String get journalSectionEvents => 'Match timeline';

  @override
  String get journalEventsEmpty =>
      'Add the goals, cards and turning points you remember.';

  @override
  String get journalEventAdd => 'Add event';

  @override
  String get journalEventEdit => 'Edit event';

  @override
  String get journalEventKind => 'Event';

  @override
  String get journalEventMinute => 'Minute';

  @override
  String get journalEventExtra => 'Added time';

  @override
  String get journalEventLabel => 'Player or note';

  @override
  String get journalEventSide => 'Side';

  @override
  String get journalEventGoal => 'Goal';

  @override
  String get journalEventYellowCard => 'Yellow card';

  @override
  String get journalEventRedCard => 'Red card';

  @override
  String get journalEventSubstitution => 'Substitution';

  @override
  String get journalEventSave => 'Great save';

  @override
  String get journalEventAssist => 'Assist';

  @override
  String get journalEventMissedChance => 'Missed chance';

  @override
  String get journalEventRefereeDecision => 'Referee decision';

  @override
  String get journalSectionFavouriteGoal => 'Favourite goal';

  @override
  String get journalFavouriteGoalEmpty =>
      'Choose the goal you would watch again.';

  @override
  String get journalFavouriteGoalSet => 'Choose favourite goal';

  @override
  String get journalFavouriteGoalEdit => 'Edit favourite goal';

  @override
  String get journalFavouriteGoalPlayer => 'Scorer';

  @override
  String get journalFavouriteGoalMinute => 'Minute';

  @override
  String get journalFavouriteGoalKind => 'Type of goal';

  @override
  String get journalFavouriteGoalDescription => 'Describe it';

  @override
  String get journalGoalKindLongShot => 'Long shot';

  @override
  String get journalGoalKindCounterAttack => 'Counter attack';

  @override
  String get journalGoalKindFreeKick => 'Free kick';

  @override
  String get journalGoalKindHeader => 'Header';

  @override
  String get journalGoalKindPenalty => 'Penalty';

  @override
  String get journalGoalKindTeamGoal => 'Team goal';

  @override
  String get journalGoalKindSoloGoal => 'Solo goal';

  @override
  String get journalSectionTactical => 'Tactical notes';

  @override
  String get journalTacticalFormation => 'Formation';

  @override
  String get journalTacticalFormationHint => '4-3-3';

  @override
  String get journalTacticalBestTactic => 'Best tactic';

  @override
  String get journalTacticalBestTacticHint => 'High press';

  @override
  String get journalTacticalWeakness => 'Key weakness';

  @override
  String get journalTacticalWeaknessHint => 'Defensive transitions';

  @override
  String get journalTacticalBestPlayer => 'Best player';

  @override
  String get journalTacticalComment => 'Tactical comment';

  @override
  String get journalTacticalAspects => 'Rate the game';

  @override
  String get journalAspectPossession => 'Possession';

  @override
  String get journalAspectPressing => 'Pressing';

  @override
  String get journalAspectCounterAttacks => 'Counter attacks';

  @override
  String get journalAspectDefensiveOrganisation => 'Defensive organisation';

  @override
  String get journalAspectSetPieces => 'Set pieces';

  @override
  String get journalAspectBuildUp => 'Build-up';

  @override
  String get journalSectionPrediction => 'My call';

  @override
  String get journalPredictionHint => 'What you called before kickoff.';

  @override
  String get journalPredictionHomeScore => 'Home';

  @override
  String get journalPredictionAwayScore => 'Away';

  @override
  String get journalPredictionWinner => 'Winner';

  @override
  String get journalPredictionWinnerHome => 'Home';

  @override
  String get journalPredictionWinnerDraw => 'Draw';

  @override
  String get journalPredictionWinnerAway => 'Away';

  @override
  String get journalPredictionFirstScorer => 'First goalscorer';

  @override
  String get journalPredictionMotm => 'Man of the match';

  @override
  String get journalPredictionResult => 'How it went';

  @override
  String get journalPredictionExact => 'You called it exactly.';

  @override
  String journalPredictionRightWinner(String called, String actual) {
    return 'Close. You said $called, it finished $actual.';
  }

  @override
  String journalPredictionMissed(String called, String actual) {
    return 'Not this time. You said $called, it finished $actual.';
  }

  @override
  String get journalPredictionPending =>
      'Nothing to compare yet — no final score.';

  @override
  String journalPredictionAccuracy(String value) {
    return 'Accuracy $value';
  }

  @override
  String get journalPredictionSave => 'Save my call';

  @override
  String get journalSectionMood => 'How you watched it';

  @override
  String get journalMoodHype => 'Hyped';

  @override
  String get journalMoodHappy => 'Happy';

  @override
  String get journalMoodEmotional => 'Emotional';

  @override
  String get journalMoodAngry => 'Angry';

  @override
  String get journalMoodNervous => 'Nervous';

  @override
  String get journalMoodShocked => 'Shocked';

  @override
  String get journalMoodEntertained => 'Entertained';

  @override
  String get journalMoodRelaxed => 'Relaxed';

  @override
  String get journalMoodBored => 'Bored';

  @override
  String get journalSectionMemory => 'My football memory';

  @override
  String get journalMemoryQuestion => 'Where did you watch this match?';

  @override
  String get journalMemoryStoryHint =>
      'I watched this match with my friends at a café.';

  @override
  String get journalMemoryLocation => 'Place';

  @override
  String get journalMemoryPeople => 'Watched with';

  @override
  String get journalMemoryOccasion => 'Special occasion';

  @override
  String get journalMemoryDate => 'Date watched';

  @override
  String get journalMemoryPickDate => 'Pick a date';

  @override
  String get journalSectionTags => 'Tags';

  @override
  String get journalTagsEmpty => 'Tag this match so you can find it again.';

  @override
  String get journalTagAdd => 'Add your own tag';

  @override
  String get journalTagMasterclass => 'Masterclass';

  @override
  String get journalTagDerby => 'Derby';

  @override
  String get journalTagChampionsLeague => 'Champions League';

  @override
  String get journalTagComeback => 'Comeback';

  @override
  String get journalTagHistoric => 'Historic';

  @override
  String get journalTagCrazyMatch => 'Crazy match';

  @override
  String get journalTagFavourite => 'Favourite';

  @override
  String get journalTagGoalFest => 'Goal fest';

  @override
  String get journalTagDefensiveMasterclass => 'Defensive masterclass';

  @override
  String get journalTagBadReferee => 'Bad referee';

  @override
  String get journalTagMustWatch => 'Must watch';

  @override
  String get journalSectionMotm => 'Man of the match';

  @override
  String get journalMotmEmpty => 'Who ran the game?';

  @override
  String get journalMotmSet => 'Choose man of the match';

  @override
  String get journalMotmEdit => 'Edit man of the match';

  @override
  String get journalMotmPlayer => 'Player';

  @override
  String get journalMotmRating => 'Rating';

  @override
  String get journalMotmReason => 'Why?';

  @override
  String get journalMotmReasonHint => 'He completely controlled the midfield.';

  @override
  String get journalSectionActivity => 'Journal timeline';

  @override
  String get journalActivityCreated => 'Journal started';

  @override
  String get journalActivityNoteUpdated => 'Notes updated';

  @override
  String journalActivityRated(String detail) {
    return 'Match rated $detail';
  }

  @override
  String journalActivityReactionAdded(String detail) {
    return 'Reaction added $detail';
  }

  @override
  String journalActivityMoodSet(String detail) {
    return 'Mood saved $detail';
  }

  @override
  String journalActivityMomentAdded(String detail) {
    return 'Moment saved · $detail';
  }

  @override
  String journalActivityFavouriteGoalSet(String detail) {
    return 'Favourite goal · $detail';
  }

  @override
  String journalActivityManOfTheMatchSet(String detail) {
    return 'Man of the match · $detail';
  }

  @override
  String journalActivityPlayerRated(String detail) {
    return 'Player rated · $detail';
  }

  @override
  String get journalActivityPredictionMade => 'Call saved';

  @override
  String get journalActivityTacticalUpdated => 'Tactical notes updated';

  @override
  String get journalActivityMemoryWritten => 'Memory saved';

  @override
  String journalActivityEventAdded(String detail) {
    return 'Timeline event added $detail';
  }

  @override
  String journalActivityStatAdded(String detail) {
    return 'Statistic added · $detail';
  }

  @override
  String journalActivityTagAdded(String detail) {
    return 'Tag added · $detail';
  }

  @override
  String get journalActivityWatchedAgain => 'Watched again';

  @override
  String get journalSectionStats => 'Statistics you noted';

  @override
  String get journalStatsEmpty => 'Record the numbers that stood out.';

  @override
  String get journalStatAdd => 'Add statistic';

  @override
  String get journalStatEdit => 'Edit statistic';

  @override
  String get journalStatLabel => 'Statistic';

  @override
  String get journalStatHome => 'Home';

  @override
  String get journalStatAway => 'Away';

  @override
  String get journalStatPossession => 'Possession';

  @override
  String get journalStatShots => 'Shots';

  @override
  String get journalStatShotsOnTarget => 'Shots on target';

  @override
  String get journalStatCorners => 'Corners';

  @override
  String get journalStatBigChances => 'Big moments';

  @override
  String get journalSummaryAction => 'Summarise my match';

  @override
  String get journalSummaryTitle => 'Your match, in short';

  @override
  String get journalSummaryOpinion => 'Overall';

  @override
  String get journalSummaryBestPlayer => 'Best player';

  @override
  String get journalSummaryFavouriteMoment => 'Favourite moment';

  @override
  String get journalSummaryTactical => 'Tactical observation';

  @override
  String get journalSummaryDisappointment => 'Biggest disappointment';

  @override
  String get journalSummaryFinalRating => 'Final rating';

  @override
  String get journalSummaryEmpty =>
      'Write a little more and the summary will have something to work with.';

  @override
  String get journalSummaryAppend => 'Add to my notes';

  @override
  String get journalSummaryNote =>
      'Built from what you wrote. Your notes are never replaced.';

  @override
  String get journalSectionRewatch => 'Rewatched';

  @override
  String journalWatchedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Watched $count times',
      one: 'Watched once',
      zero: 'Not logged yet',
    );
    return '$_temp0';
  }

  @override
  String get journalFirstWatched => 'First watched';

  @override
  String get journalLastWatched => 'Last watched';

  @override
  String get journalWatchAgain => 'Watched again';

  @override
  String get journalBarNote => 'Note';

  @override
  String get journalBarMoment => 'Moment';

  @override
  String get journalBarRate => 'Rate';

  @override
  String get journalBarPredict => 'Call';

  @override
  String get journalHeaderTeam => 'Team journal';

  @override
  String get journalHeaderPlayer => 'Player journal';

  @override
  String get journalRemove => 'Remove';

  @override
  String get journalSave => 'Save';

  @override
  String get journalOptional => 'Optional';

  @override
  String journalSemanticsRating(String label, String value) {
    return '$label, $value out of 10';
  }

  @override
  String journalSemanticsReaction(String label, String state) {
    return '$label, $state';
  }

  @override
  String get journalStateSelected => 'selected';

  @override
  String get journalStateNotSelected => 'not selected';

  @override
  String get journalPreviewOn => 'Preview formatting';

  @override
  String get journalPreviewOff => 'Back to editing';

  @override
  String get navJournal => 'Journal';

  @override
  String get journalIndexTitle => 'Your journal';

  @override
  String journalIndexSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches written up',
      one: '1 match written up',
      zero: 'Nothing written yet',
    );
    return '$_temp0';
  }

  @override
  String get journalIndexEmptyTitle => 'Your football story starts here.';

  @override
  String get journalIndexEmptyBody =>
      'Open any match and tap the journal icon to save what you thought, what you felt, and where you watched it.';

  @override
  String get journalIndexEmptyAction => 'Find a match';

  @override
  String get journalIndexUnknownMatch => 'Match';

  @override
  String journalIndexUpdated(String date) {
    return 'Updated $date';
  }

  @override
  String get settingsSectionSupport => 'Support the app';

  @override
  String get settingsRewardTitle => 'Watch an ad, browse ad-free';

  @override
  String settingsRewardBody(int minutes) {
    return 'One short video buys you $minutes minutes without interruptions.';
  }

  @override
  String get settingsRewardAction => 'Watch';

  @override
  String settingsAdFreeActive(int minutes) {
    return 'Ad-free for another $minutes min';
  }

  @override
  String get settingsAdFreeThanks => 'Thanks — enjoy the quiet.';

  @override
  String get settingsRewardUnavailable =>
      'No video is ready just now. Try again in a moment.';

  @override
  String get journalTabWrite => 'Write';

  @override
  String get journalTabRate => 'Rate';

  @override
  String get journalTabMoments => 'Moments';

  @override
  String get journalTabAnalysis => 'Analysis';

  @override
  String journalProgress(int done, int total) {
    return '$done of $total sections';
  }

  @override
  String journalUpNext(String section) {
    return 'Up next: $section';
  }

  @override
  String get journalAllDone => 'Every section filled in. A complete journal.';

  @override
  String get journalDeleted => 'Journal deleted';

  @override
  String get journalUndo => 'Undo';

  @override
  String get journalSearchHint => 'Search teams, competitions, notes';

  @override
  String get journalFilterAll => 'All';

  @override
  String get journalFilterRated => 'Rated';

  @override
  String get journalFilterNotes => 'With notes';

  @override
  String get journalFilterPredictions => 'Predictions';

  @override
  String get journalFilterTopRated => 'Top rated';

  @override
  String get journalSortTooltip => 'Sort';

  @override
  String get journalSortRecent => 'Recently edited';

  @override
  String get journalSortMatchDate => 'Match date';

  @override
  String get journalSortRating => 'Highest rated';

  @override
  String get journalStatJournals => 'Journals';

  @override
  String get journalStatAverage => 'Avg rating';

  @override
  String get journalStatWords => 'Words';

  @override
  String get journalNoResultsTitle => 'No journals match';

  @override
  String get journalNoResultsBody => 'Try another search or clear the filters.';

  @override
  String get journalClearFilters => 'Clear filters';

  @override
  String get journalByRating => 'By rating';

  @override
  String get journalSwipeDelete => 'Delete';

  @override
  String get journalMoodHint =>
      'Tap everything you felt. Your vibe updates as you go.';

  @override
  String journalMoodVibe(String vibe) {
    return 'Your vibe: $vibe';
  }

  @override
  String get journalMoodElectric => 'Electric';

  @override
  String get journalMoodTense => 'Tense';

  @override
  String get journalMoodContent => 'Content';

  @override
  String get journalMoodFlat => 'Flat';

  @override
  String get journalMoodElectricHint => 'High energy · good';

  @override
  String get journalMoodTenseHint => 'High energy · rough';

  @override
  String get journalMoodContentHint => 'Low energy · good';

  @override
  String get journalMoodFlatHint => 'Low energy · rough';

  @override
  String get journalReactionGood => 'The good';

  @override
  String get journalReactionBad => 'The bad';

  @override
  String journalVerdict(String verdict) {
    return 'Your verdict: $verdict';
  }

  @override
  String get journalVerdictClassic => 'Classic';

  @override
  String get journalVerdictGoodWatch => 'Good watch';

  @override
  String get journalVerdictMixed => 'Mixed';

  @override
  String get journalVerdictRough => 'Rough';

  @override
  String get journalVerdictForgettable => 'Forgettable';

  @override
  String get journalStatVerdict => 'Usual verdict';

  @override
  String get splashStepConfig => 'Getting things ready…';

  @override
  String get splashStepMatches => 'Loading today\'s matches…';

  @override
  String get splashStepReady => 'Kick-off!';

  @override
  String splashToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches today',
      one: '1 match today',
    );
    return '$_temp0';
  }

  @override
  String splashLive(int count) {
    return '$count live now';
  }

  @override
  String get splashReconnecting => 'Reconnecting…';

  @override
  String get splashAutoRetry =>
      'We\'ll carry on as soon as you\'re back online.';

  @override
  String get errorQuotaTitle => 'Today\'s data limit is reached';

  @override
  String get errorQuotaBody =>
      'Scores already loaded stay on screen. Fresh data comes back when the limit resets.';

  @override
  String settingsFollowingSummary(int teams, int competitions) {
    String _temp0 = intl.Intl.pluralLogic(
      teams,
      locale: localeName,
      other: '$teams teams',
      one: '1 team',
    );
    String _temp1 = intl.Intl.pluralLogic(
      competitions,
      locale: localeName,
      other: '$competitions competitions',
      one: '1 competition',
    );
    return '$_temp0 · $_temp1';
  }
}
