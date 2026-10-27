import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Marma'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'No odds. No noise. Just football.'**
  String get appTagline;

  /// No description provided for @navMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get navMatches;

  /// No description provided for @navLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get navLive;

  /// No description provided for @navFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get navFollowing;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// No description provided for @screenMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get screenMatches;

  /// No description provided for @screenLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get screenLive;

  /// No description provided for @screenFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get screenFollowing;

  /// No description provided for @screenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get screenSettings;

  /// No description provided for @screenSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get screenSearch;

  /// No description provided for @screenManageFavourites.
  ///
  /// In en, this message translates to:
  /// **'Manage favourites'**
  String get screenManageFavourites;

  /// No description provided for @screenAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get screenAppearance;

  /// No description provided for @screenLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get screenLanguage;

  /// No description provided for @screenAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get screenAbout;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get actionFollow;

  /// No description provided for @actionUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get actionUnfollow;

  /// No description provided for @actionGoToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get actionGoToToday;

  /// No description provided for @actionSeeTodaysFixtures.
  ///
  /// In en, this message translates to:
  /// **'See today\'s fixtures'**
  String get actionSeeTodaysFixtures;

  /// No description provided for @actionAddFavourites.
  ///
  /// In en, this message translates to:
  /// **'Add favourites'**
  String get actionAddFavourites;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get actionGetStarted;

  /// No description provided for @actionSwitchDay.
  ///
  /// In en, this message translates to:
  /// **'Switch day'**
  String get actionSwitchDay;

  /// No description provided for @statusTbd.
  ///
  /// In en, this message translates to:
  /// **'Time to be defined'**
  String get statusTbd;

  /// No description provided for @statusNs.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get statusNs;

  /// No description provided for @statusFirstHalf.
  ///
  /// In en, this message translates to:
  /// **'First half'**
  String get statusFirstHalf;

  /// No description provided for @statusHalfTime.
  ///
  /// In en, this message translates to:
  /// **'Half time'**
  String get statusHalfTime;

  /// No description provided for @statusSecondHalf.
  ///
  /// In en, this message translates to:
  /// **'Second half'**
  String get statusSecondHalf;

  /// No description provided for @statusExtraTime.
  ///
  /// In en, this message translates to:
  /// **'Extra time'**
  String get statusExtraTime;

  /// No description provided for @statusBreakTime.
  ///
  /// In en, this message translates to:
  /// **'Break time'**
  String get statusBreakTime;

  /// No description provided for @statusPenaltyShootout.
  ///
  /// In en, this message translates to:
  /// **'Penalty shootout'**
  String get statusPenaltyShootout;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Interrupted'**
  String get statusInterrupted;

  /// No description provided for @statusFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full time'**
  String get statusFullTime;

  /// No description provided for @statusAfterExtraTime.
  ///
  /// In en, this message translates to:
  /// **'After extra time'**
  String get statusAfterExtraTime;

  /// No description provided for @statusAfterPenalties.
  ///
  /// In en, this message translates to:
  /// **'After penalties'**
  String get statusAfterPenalties;

  /// No description provided for @statusPostponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get statusPostponed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get statusAbandoned;

  /// No description provided for @statusTechnicalLoss.
  ///
  /// In en, this message translates to:
  /// **'Technical loss'**
  String get statusTechnicalLoss;

  /// No description provided for @statusWalkover.
  ///
  /// In en, this message translates to:
  /// **'Walkover'**
  String get statusWalkover;

  /// No description provided for @statusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusLive;

  /// No description provided for @abbrFullTime.
  ///
  /// In en, this message translates to:
  /// **'FT'**
  String get abbrFullTime;

  /// No description provided for @abbrAfterExtraTime.
  ///
  /// In en, this message translates to:
  /// **'AET'**
  String get abbrAfterExtraTime;

  /// No description provided for @abbrPenalties.
  ///
  /// In en, this message translates to:
  /// **'PEN'**
  String get abbrPenalties;

  /// No description provided for @abbrHalfTime.
  ///
  /// In en, this message translates to:
  /// **'HT'**
  String get abbrHalfTime;

  /// No description provided for @abbrExtraTime.
  ///
  /// In en, this message translates to:
  /// **'ET'**
  String get abbrExtraTime;

  /// No description provided for @abbrPostponed.
  ///
  /// In en, this message translates to:
  /// **'POST'**
  String get abbrPostponed;

  /// No description provided for @abbrCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANC'**
  String get abbrCancelled;

  /// No description provided for @abbrAbandoned.
  ///
  /// In en, this message translates to:
  /// **'ABD'**
  String get abbrAbandoned;

  /// No description provided for @abbrLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get abbrLive;

  /// No description provided for @eventNormalGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get eventNormalGoal;

  /// No description provided for @eventOwnGoal.
  ///
  /// In en, this message translates to:
  /// **'Own goal'**
  String get eventOwnGoal;

  /// No description provided for @eventPenaltyGoal.
  ///
  /// In en, this message translates to:
  /// **'Penalty'**
  String get eventPenaltyGoal;

  /// No description provided for @eventMissedPenalty.
  ///
  /// In en, this message translates to:
  /// **'Missed penalty'**
  String get eventMissedPenalty;

  /// No description provided for @eventYellowCard.
  ///
  /// In en, this message translates to:
  /// **'Yellow card'**
  String get eventYellowCard;

  /// No description provided for @eventRedCard.
  ///
  /// In en, this message translates to:
  /// **'Red card'**
  String get eventRedCard;

  /// No description provided for @eventSecondYellow.
  ///
  /// In en, this message translates to:
  /// **'Second yellow'**
  String get eventSecondYellow;

  /// No description provided for @eventSubstitution.
  ///
  /// In en, this message translates to:
  /// **'Substitution'**
  String get eventSubstitution;

  /// No description provided for @labelVenue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get labelVenue;

  /// No description provided for @labelReferee.
  ///
  /// In en, this message translates to:
  /// **'Referee'**
  String get labelReferee;

  /// No description provided for @labelRound.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get labelRound;

  /// No description provided for @labelSeason.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get labelSeason;

  /// No description provided for @labelKickoff.
  ///
  /// In en, this message translates to:
  /// **'Kick-off'**
  String get labelKickoff;

  /// No description provided for @labelCompetition.
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get labelCompetition;

  /// No description provided for @labelTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get labelTimeline;

  /// No description provided for @labelCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get labelCompetitions;

  /// No description provided for @labelTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get labelTeams;

  /// No description provided for @labelMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get labelMatches;

  /// No description provided for @labelAssist.
  ///
  /// In en, this message translates to:
  /// **'Assist: {name}'**
  String labelAssist(String name);

  /// No description provided for @labelFullTimeScore.
  ///
  /// In en, this message translates to:
  /// **'FT {home}–{away}'**
  String labelFullTimeScore(String home, String away);

  /// No description provided for @labelPenaltiesScore.
  ///
  /// In en, this message translates to:
  /// **'PEN {home}–{away}'**
  String labelPenaltiesScore(String home, String away);

  /// No description provided for @freshUpdatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get freshUpdatedJustNow;

  /// No description provided for @freshUpdatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {minutes} min ago'**
  String freshUpdatedMinutesAgo(int minutes);

  /// No description provided for @freshOfflineFrom.
  ///
  /// In en, this message translates to:
  /// **'Offline · from {minutes} min ago'**
  String freshOfflineFrom(int minutes);

  /// No description provided for @freshOfflineNoData.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get freshOfflineNoData;

  /// No description provided for @freshNeverUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated yet'**
  String get freshNeverUpdated;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved scores.'**
  String get offlineBanner;

  /// No description provided for @errorOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get errorOfflineTitle;

  /// No description provided for @errorOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Showing scores saved {minutes} min ago.'**
  String errorOfflineBody(int minutes);

  /// No description provided for @errorOfflineBodyNoCache.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to load today\'s matches.'**
  String get errorOfflineBodyNoCache;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Scores are taking a while'**
  String get errorTimeoutTitle;

  /// No description provided for @errorTimeoutBody.
  ///
  /// In en, this message translates to:
  /// **'The score feed didn\'t answer in time.'**
  String get errorTimeoutBody;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'The score feed is having a moment'**
  String get errorServerTitle;

  /// No description provided for @errorServerBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll keep trying.'**
  String get errorServerBody;

  /// No description provided for @errorBadResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the score feed'**
  String get errorBadResponseTitle;

  /// No description provided for @errorBadResponseBody.
  ///
  /// In en, this message translates to:
  /// **'The response wasn\'t in a shape we understand.'**
  String get errorBadResponseBody;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get errorUnknownBody;

  /// No description provided for @emptyDayTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled'**
  String get emptyDayTitle;

  /// No description provided for @emptyDayBody.
  ///
  /// In en, this message translates to:
  /// **'Football takes the occasional day off.'**
  String get emptyDayBody;

  /// No description provided for @emptyLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches in play right now'**
  String get emptyLiveTitle;

  /// No description provided for @emptyLiveBody.
  ///
  /// In en, this message translates to:
  /// **'Live minutes and goals appear here the moment a match kicks off.'**
  String get emptyLiveBody;

  /// No description provided for @emptyFollowingTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow a team to build your feed'**
  String get emptyFollowingTitle;

  /// No description provided for @emptyFollowingBody.
  ///
  /// In en, this message translates to:
  /// **'Your teams and competitions from yesterday, today and tomorrow, in one place.'**
  String get emptyFollowingBody;

  /// No description provided for @emptyFollowingNoFixturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing on for who you follow'**
  String get emptyFollowingNoFixturesTitle;

  /// No description provided for @emptyFollowingNoFixturesBody.
  ///
  /// In en, this message translates to:
  /// **'None of your teams or competitions have a match yesterday, today or tomorrow. Some leagues are out of season.'**
  String get emptyFollowingNoFixturesBody;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search yesterday, today and tomorrow'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchBody.
  ///
  /// In en, this message translates to:
  /// **'Find a team, a competition or a country.'**
  String get emptySearchBody;

  /// No description provided for @noResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\"'**
  String noResultsTitle(String query);

  /// No description provided for @noResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Marma searches yesterday, today and tomorrow only.'**
  String get noResultsBody;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'This match isn\'t in the current three-day window'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'Marma only covers yesterday, today and tomorrow.'**
  String get notFoundBody;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'That screen doesn\'t exist'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The link you followed doesn\'t lead anywhere in Marma.'**
  String get routeNotFoundBody;

  /// No description provided for @loadingMatches.
  ///
  /// In en, this message translates to:
  /// **'Loading matches'**
  String get loadingMatches;

  /// No description provided for @liveCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} live'**
  String liveCountLabel(int count);

  /// No description provided for @sectionLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get sectionLive;

  /// No description provided for @sectionLaterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get sectionLaterToday;

  /// No description provided for @sectionTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get sectionTomorrow;

  /// No description provided for @sectionFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get sectionFinished;

  /// No description provided for @matchesFollowedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matches} =1{1 match} other{{count} matches}}'**
  String matchesFollowedCount(int count);

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionYourFootball.
  ///
  /// In en, this message translates to:
  /// **'Your football'**
  String get settingsSectionYourFootball;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal & support'**
  String get settingsSectionLegal;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get settingsFollowing;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTerms;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Marma'**
  String get settingsAbout;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutAttribution.
  ///
  /// In en, this message translates to:
  /// **'Data provided by GOAL API (goal-api.com).'**
  String get aboutAttribution;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Marma is not affiliated with, endorsed by, or connected to any football club, league, federation or governing body. Scores may be delayed and are unofficial.'**
  String get aboutDisclaimer;

  /// No description provided for @aboutPrivacyPosture.
  ///
  /// In en, this message translates to:
  /// **'No account, no login, no tracking. Your favourites, settings and cached scores never leave this device.'**
  String get aboutPrivacyPosture;

  /// No description provided for @aboutBackendStatus.
  ///
  /// In en, this message translates to:
  /// **'Score feed status'**
  String get aboutBackendStatus;

  /// No description provided for @aboutBackendHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get aboutBackendHealthy;

  /// No description provided for @aboutBackendUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get aboutBackendUnhealthy;

  /// No description provided for @aboutBackendChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get aboutBackendChecking;

  /// No description provided for @aboutBackendUpdated.
  ///
  /// In en, this message translates to:
  /// **'Feed updated {minutes} min ago'**
  String aboutBackendUpdated(int minutes);

  /// No description provided for @aboutClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cached data'**
  String get aboutClearCache;

  /// No description provided for @aboutClearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{kilobytes} KB of saved fixtures'**
  String aboutClearCacheSubtitle(int kilobytes);

  /// No description provided for @aboutCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cached data cleared.'**
  String get aboutCacheCleared;

  /// No description provided for @manageEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing followed yet'**
  String get manageEmptyTitle;

  /// No description provided for @manageEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a team or competition and it will appear here.'**
  String get manageEmptyBody;

  /// No description provided for @manageTeamsHeader.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get manageTeamsHeader;

  /// No description provided for @manageCompetitionsHeader.
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get manageCompetitionsHeader;

  /// No description provided for @manageRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String manageRemoved(String name);

  /// No description provided for @sheetFollowHome.
  ///
  /// In en, this message translates to:
  /// **'Follow {name}'**
  String sheetFollowHome(String name);

  /// No description provided for @sheetFollowCompetition.
  ///
  /// In en, this message translates to:
  /// **'Follow {name}'**
  String sheetFollowCompetition(String name);

  /// No description provided for @sheetUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow {name}'**
  String sheetUnfollow(String name);

  /// No description provided for @semanticsMatchScheduled.
  ///
  /// In en, this message translates to:
  /// **'{home} versus {away}, kicks off {time}, {competition}, {country}'**
  String semanticsMatchScheduled(
    String home,
    String away,
    String time,
    String competition,
    String country,
  );

  /// No description provided for @semanticsMatchLive.
  ///
  /// In en, this message translates to:
  /// **'{home} {homeGoals}, {away} {awayGoals}, {minute}, {competition}, {country}'**
  String semanticsMatchLive(
    String home,
    String homeGoals,
    String away,
    String awayGoals,
    String minute,
    String competition,
    String country,
  );

  /// VoiceOver reading of a live minute. Never the prime-mark form.
  ///
  /// In en, this message translates to:
  /// **'{minute}th minute'**
  String semanticsMinute(String minute);

  /// VoiceOver reading of a live minute in added time.
  ///
  /// In en, this message translates to:
  /// **'{minute}th minute plus {added}'**
  String semanticsMinuteAdded(String minute, String added);

  /// No description provided for @semanticsMatchFinished.
  ///
  /// In en, this message translates to:
  /// **'{home} {homeGoals}, {away} {awayGoals}, full time, {competition}, {country}'**
  String semanticsMatchFinished(
    String home,
    String homeGoals,
    String away,
    String awayGoals,
    String competition,
    String country,
  );

  /// No description provided for @semanticsFollowToggle.
  ///
  /// In en, this message translates to:
  /// **'Follow {name}'**
  String semanticsFollowToggle(String name);

  /// No description provided for @semanticsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh scores'**
  String get semanticsRefresh;

  /// No description provided for @semanticsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search matches'**
  String get semanticsSearch;

  /// No description provided for @semanticsLiveTabBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} matches in play'**
  String semanticsLiveTabBadge(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Team, competition or country'**
  String get searchHint;

  /// No description provided for @matchDetailAttribution.
  ///
  /// In en, this message translates to:
  /// **'Data provided by GOAL API (goal-api.com). Marma is not affiliated with any club, league or federation. Scores may be delayed and are unofficial.'**
  String get matchDetailAttribution;

  /// No description provided for @matchDetailNoTimeline.
  ///
  /// In en, this message translates to:
  /// **'Goals, cards and substitutions appear here while a match is live.'**
  String get matchDetailNoTimeline;

  /// No description provided for @matchDetailTimelineLiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Timelines are available for matches in play.'**
  String get matchDetailTimelineLiveOnly;

  /// No description provided for @worthTitle.
  ///
  /// In en, this message translates to:
  /// **'Worth watching'**
  String get worthTitle;

  /// No description provided for @worthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live now, ordered by what\'s happening.'**
  String get worthSubtitle;

  /// No description provided for @worthAllLive.
  ///
  /// In en, this message translates to:
  /// **'All live matches'**
  String get worthAllLive;

  /// No description provided for @worthNoneTight.
  ///
  /// In en, this message translates to:
  /// **'Nothing tight right now. Every live match is below.'**
  String get worthNoneTight;

  /// No description provided for @worthPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused — these scores are more than 10 minutes old.'**
  String get worthPaused;

  /// No description provided for @liveViewCompetition.
  ///
  /// In en, this message translates to:
  /// **'By competition'**
  String get liveViewCompetition;

  /// No description provided for @liveViewCountry.
  ///
  /// In en, this message translates to:
  /// **'By country'**
  String get liveViewCountry;

  /// Reason line for a match that has reached a penalty shoot-out.
  ///
  /// In en, this message translates to:
  /// **'Penalty shoot-out'**
  String get worthReasonShootout;

  /// No description provided for @worthReasonExtraTime.
  ///
  /// In en, this message translates to:
  /// **'Extra time'**
  String get worthReasonExtraTime;

  /// No description provided for @worthReasonRedCardMany.
  ///
  /// In en, this message translates to:
  /// **'Two players sent off'**
  String get worthReasonRedCardMany;

  /// One side has had a player sent off. {minute} is an ordinal such as 61st.
  ///
  /// In en, this message translates to:
  /// **'{team} down to ten since the {minute}'**
  String worthReasonRedCardOne(String team, String minute);

  /// No description provided for @worthReasonComebackLead.
  ///
  /// In en, this message translates to:
  /// **'{team} came from behind'**
  String worthReasonComebackLead(String team);

  /// Composed from worthBurstGoals and worthBurstMinutes so no message nests two plurals.
  ///
  /// In en, this message translates to:
  /// **'{goals} in {span}'**
  String worthReasonBurst(String goals, String span);

  /// No description provided for @worthReasonComebackLevel.
  ///
  /// In en, this message translates to:
  /// **'Level again after going behind'**
  String get worthReasonComebackLevel;

  /// No description provided for @worthReasonGoallessLate.
  ///
  /// In en, this message translates to:
  /// **'Still goalless, late on'**
  String get worthReasonGoallessLate;

  /// No description provided for @worthReasonGoalless.
  ///
  /// In en, this message translates to:
  /// **'Goalless, second half'**
  String get worthReasonGoalless;

  /// No description provided for @worthReasonLevelLate.
  ///
  /// In en, this message translates to:
  /// **'Still level, late on'**
  String get worthReasonLevelLate;

  /// No description provided for @worthReasonLevel.
  ///
  /// In en, this message translates to:
  /// **'Level, second half'**
  String get worthReasonLevel;

  /// No description provided for @worthReasonOneGoalLate.
  ///
  /// In en, this message translates to:
  /// **'One goal in it, late on'**
  String get worthReasonOneGoalLate;

  /// No description provided for @worthReasonOneGoal.
  ///
  /// In en, this message translates to:
  /// **'One goal in it'**
  String get worthReasonOneGoal;

  /// No description provided for @worthReasonGoalsSoFar.
  ///
  /// In en, this message translates to:
  /// **'{goals} so far'**
  String worthReasonGoalsSoFar(String goals);

  /// No description provided for @worthReasonInPlay.
  ///
  /// In en, this message translates to:
  /// **'In play'**
  String get worthReasonInPlay;

  /// No description provided for @worthBurstGoals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 goal} other{{count} goals}}'**
  String worthBurstGoals(int count);

  /// No description provided for @worthBurstMinutes.
  ///
  /// In en, this message translates to:
  /// **'{span, plural, one{1 minute} other{{span} minutes}}'**
  String worthBurstMinutes(int span);

  /// No description provided for @worthHowAction.
  ///
  /// In en, this message translates to:
  /// **'How “Worth watching” is ordered'**
  String get worthHowAction;

  /// No description provided for @worthHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How “Worth watching” is ordered'**
  String get worthHowTitle;

  /// No description provided for @worthHowBody1.
  ///
  /// In en, this message translates to:
  /// **'These are matches being played right now, ordered by what has already happened in them.'**
  String get worthHowBody1;

  /// No description provided for @worthHowBody2.
  ///
  /// In en, this message translates to:
  /// **'Marma looks at how close the score is, how late in the match it is, whether goals have arrived in a short space of time, whether a side has come back, and whether anyone has been sent off.'**
  String get worthHowBody2;

  /// The only string in the app that names the vocabulary of wagering, and it names it in order to deny it. Whitelisted by key in the gambling-guard test.
  ///
  /// In en, this message translates to:
  /// **'It is not a prediction. Marma never says who will win, shows no odds, no probabilities and no percentages, and carries no betting content of any kind.'**
  String get worthHowBody3;

  /// No description provided for @atlasCountries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 country} other{{count} countries}}'**
  String atlasCountries(int count);

  /// No description provided for @atlasMatches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 match} other{{count} matches}}'**
  String atlasMatches(int count);

  /// No description provided for @atlasSummary.
  ///
  /// In en, this message translates to:
  /// **'{a} · {b}'**
  String atlasSummary(String a, String b);

  /// No description provided for @atlasAsOf.
  ///
  /// In en, this message translates to:
  /// **'as of {minutes} min ago'**
  String atlasAsOf(int minutes);

  /// No description provided for @atlasOfflineAsOf.
  ///
  /// In en, this message translates to:
  /// **'Offline · as of {minutes} min ago'**
  String atlasOfflineAsOf(int minutes);

  /// No description provided for @atlasInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get atlasInternational;

  /// No description provided for @atlasInternationalOnly.
  ///
  /// In en, this message translates to:
  /// **'International competitions only'**
  String get atlasInternationalOnly;

  /// No description provided for @semanticsCountryRow.
  ///
  /// In en, this message translates to:
  /// **'{country}, {matches}'**
  String semanticsCountryRow(String country, String matches);

  /// No description provided for @semanticsWorthHeader.
  ///
  /// In en, this message translates to:
  /// **'Worth watching, {matches}'**
  String semanticsWorthHeader(String matches);

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Football journal'**
  String get journalTitle;

  /// No description provided for @journalActionOpen.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalActionOpen;

  /// No description provided for @journalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Write your football story.'**
  String get journalEmptyTitle;

  /// No description provided for @journalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save your reactions, favourite moments, predictions, player ratings and memories from the beautiful game.'**
  String get journalEmptyBody;

  /// No description provided for @journalEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Start football journal'**
  String get journalEmptyAction;

  /// No description provided for @journalDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete journal'**
  String get journalDeleteAction;

  /// No description provided for @journalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this journal?'**
  String get journalDeleteTitle;

  /// No description provided for @journalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you wrote about this match is on this device only, and cannot be recovered.'**
  String get journalDeleteBody;

  /// No description provided for @journalSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Your notes'**
  String get journalSectionNote;

  /// No description provided for @journalNoteHintMatch.
  ///
  /// In en, this message translates to:
  /// **'What did you think about this match?'**
  String get journalNoteHintMatch;

  /// No description provided for @journalNoteHintTeam.
  ///
  /// In en, this message translates to:
  /// **'What do you think about this team?'**
  String get journalNoteHintTeam;

  /// No description provided for @journalNoteHintPlayer.
  ///
  /// In en, this message translates to:
  /// **'What do you think about this player?'**
  String get journalNoteHintPlayer;

  /// No description provided for @journalNoteFormattingHint.
  ///
  /// In en, this message translates to:
  /// **'# heading · **bold** · - list'**
  String get journalNoteFormattingHint;

  /// No description provided for @journalSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get journalSaving;

  /// No description provided for @journalSavedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Saved just now'**
  String get journalSavedJustNow;

  /// No description provided for @journalSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved at {time}'**
  String journalSavedAt(String time);

  /// No description provided for @journalUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet'**
  String get journalUnsaved;

  /// No description provided for @journalWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No words} =1{1 word} other{{count} words}}'**
  String journalWordCount(int count);

  /// No description provided for @journalCharacterCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 characters} =1{1 character} other{{count} characters}}'**
  String journalCharacterCount(int count);

  /// No description provided for @journalSectionReactions.
  ///
  /// In en, this message translates to:
  /// **'Match reaction'**
  String get journalSectionReactions;

  /// No description provided for @journalReactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Pick as many as you felt.'**
  String get journalReactionsHint;

  /// No description provided for @journalReactionIncredible.
  ///
  /// In en, this message translates to:
  /// **'Incredible'**
  String get journalReactionIncredible;

  /// No description provided for @journalReactionLoved.
  ///
  /// In en, this message translates to:
  /// **'Loved it'**
  String get journalReactionLoved;

  /// No description provided for @journalReactionUnbelievable.
  ///
  /// In en, this message translates to:
  /// **'Unbelievable'**
  String get journalReactionUnbelievable;

  /// No description provided for @journalReactionFunny.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get journalReactionFunny;

  /// No description provided for @journalReactionAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get journalReactionAngry;

  /// No description provided for @journalReactionHeartbreaking.
  ///
  /// In en, this message translates to:
  /// **'Heartbreaking'**
  String get journalReactionHeartbreaking;

  /// No description provided for @journalReactionCrazy.
  ///
  /// In en, this message translates to:
  /// **'Crazy match'**
  String get journalReactionCrazy;

  /// No description provided for @journalReactionBoring.
  ///
  /// In en, this message translates to:
  /// **'Boring'**
  String get journalReactionBoring;

  /// No description provided for @journalReactionGreatPerformance.
  ///
  /// In en, this message translates to:
  /// **'Great performance'**
  String get journalReactionGreatPerformance;

  /// No description provided for @journalReactionDisaster.
  ///
  /// In en, this message translates to:
  /// **'Disaster'**
  String get journalReactionDisaster;

  /// No description provided for @journalSectionRating.
  ///
  /// In en, this message translates to:
  /// **'Your match rating'**
  String get journalSectionRating;

  /// No description provided for @journalRatingOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get journalRatingOverall;

  /// No description provided for @journalRatingHome.
  ///
  /// In en, this message translates to:
  /// **'Home team'**
  String get journalRatingHome;

  /// No description provided for @journalRatingAway.
  ///
  /// In en, this message translates to:
  /// **'Away team'**
  String get journalRatingAway;

  /// No description provided for @journalRatingReferee.
  ///
  /// In en, this message translates to:
  /// **'Referee'**
  String get journalRatingReferee;

  /// No description provided for @journalRatingAtmosphere.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere'**
  String get journalRatingAtmosphere;

  /// No description provided for @journalRatingExperience.
  ///
  /// In en, this message translates to:
  /// **'Match experience'**
  String get journalRatingExperience;

  /// No description provided for @journalRatingOutOf.
  ///
  /// In en, this message translates to:
  /// **'{value}/10'**
  String journalRatingOutOf(String value);

  /// No description provided for @journalRatingUnset.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get journalRatingUnset;

  /// No description provided for @journalRatingClear.
  ///
  /// In en, this message translates to:
  /// **'Clear rating'**
  String get journalRatingClear;

  /// No description provided for @journalSectionPlayers.
  ///
  /// In en, this message translates to:
  /// **'Player performance'**
  String get journalSectionPlayers;

  /// No description provided for @journalPlayersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No players rated yet.'**
  String get journalPlayersEmpty;

  /// No description provided for @journalPlayerAdd.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get journalPlayerAdd;

  /// No description provided for @journalPlayerEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get journalPlayerEdit;

  /// No description provided for @journalPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get journalPlayerName;

  /// No description provided for @journalPlayerRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get journalPlayerRating;

  /// No description provided for @journalPlayerGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get journalPlayerGoals;

  /// No description provided for @journalPlayerAssists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get journalPlayerAssists;

  /// No description provided for @journalPlayerKeyPasses.
  ///
  /// In en, this message translates to:
  /// **'Key passes'**
  String get journalPlayerKeyPasses;

  /// No description provided for @journalPlayerDefending.
  ///
  /// In en, this message translates to:
  /// **'Defensive performance'**
  String get journalPlayerDefending;

  /// No description provided for @journalPlayerComment.
  ///
  /// In en, this message translates to:
  /// **'Personal comment'**
  String get journalPlayerComment;

  /// No description provided for @journalPlayerCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Very dangerous throughout the match.'**
  String get journalPlayerCommentHint;

  /// No description provided for @journalPlayerSortRating.
  ///
  /// In en, this message translates to:
  /// **'Highest rated first'**
  String get journalPlayerSortRating;

  /// No description provided for @journalPlayerSortAdded.
  ///
  /// In en, this message translates to:
  /// **'Order added'**
  String get journalPlayerSortAdded;

  /// No description provided for @journalSectionMoments.
  ///
  /// In en, this message translates to:
  /// **'Favourite moments'**
  String get journalSectionMoments;

  /// No description provided for @journalMomentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet. The moment you keep replaying goes here.'**
  String get journalMomentsEmpty;

  /// No description provided for @journalMomentAdd.
  ///
  /// In en, this message translates to:
  /// **'Add moment'**
  String get journalMomentAdd;

  /// No description provided for @journalMomentEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit moment'**
  String get journalMomentEdit;

  /// No description provided for @journalMomentTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get journalMomentTitle;

  /// No description provided for @journalMomentTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Goal of the night'**
  String get journalMomentTitleHint;

  /// No description provided for @journalMomentDescription.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get journalMomentDescription;

  /// No description provided for @journalMomentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'That counter attack was incredible.'**
  String get journalMomentDescriptionHint;

  /// No description provided for @journalMomentMinute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get journalMomentMinute;

  /// No description provided for @journalMomentSecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get journalMomentSecond;

  /// No description provided for @journalMomentPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player (optional)'**
  String get journalMomentPlayer;

  /// No description provided for @journalMomentGlyph.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get journalMomentGlyph;

  /// No description provided for @journalSectionEvents.
  ///
  /// In en, this message translates to:
  /// **'Match timeline'**
  String get journalSectionEvents;

  /// No description provided for @journalEventsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add the goals, cards and turning points you remember.'**
  String get journalEventsEmpty;

  /// No description provided for @journalEventAdd.
  ///
  /// In en, this message translates to:
  /// **'Add event'**
  String get journalEventAdd;

  /// No description provided for @journalEventEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get journalEventEdit;

  /// No description provided for @journalEventKind.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get journalEventKind;

  /// No description provided for @journalEventMinute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get journalEventMinute;

  /// No description provided for @journalEventExtra.
  ///
  /// In en, this message translates to:
  /// **'Added time'**
  String get journalEventExtra;

  /// No description provided for @journalEventLabel.
  ///
  /// In en, this message translates to:
  /// **'Player or note'**
  String get journalEventLabel;

  /// No description provided for @journalEventSide.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get journalEventSide;

  /// No description provided for @journalEventGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get journalEventGoal;

  /// No description provided for @journalEventYellowCard.
  ///
  /// In en, this message translates to:
  /// **'Yellow card'**
  String get journalEventYellowCard;

  /// No description provided for @journalEventRedCard.
  ///
  /// In en, this message translates to:
  /// **'Red card'**
  String get journalEventRedCard;

  /// No description provided for @journalEventSubstitution.
  ///
  /// In en, this message translates to:
  /// **'Substitution'**
  String get journalEventSubstitution;

  /// No description provided for @journalEventSave.
  ///
  /// In en, this message translates to:
  /// **'Great save'**
  String get journalEventSave;

  /// No description provided for @journalEventAssist.
  ///
  /// In en, this message translates to:
  /// **'Assist'**
  String get journalEventAssist;

  /// No description provided for @journalEventMissedChance.
  ///
  /// In en, this message translates to:
  /// **'Missed chance'**
  String get journalEventMissedChance;

  /// No description provided for @journalEventRefereeDecision.
  ///
  /// In en, this message translates to:
  /// **'Referee decision'**
  String get journalEventRefereeDecision;

  /// No description provided for @journalSectionFavouriteGoal.
  ///
  /// In en, this message translates to:
  /// **'Favourite goal'**
  String get journalSectionFavouriteGoal;

  /// No description provided for @journalFavouriteGoalEmpty.
  ///
  /// In en, this message translates to:
  /// **'Choose the goal you would watch again.'**
  String get journalFavouriteGoalEmpty;

  /// No description provided for @journalFavouriteGoalSet.
  ///
  /// In en, this message translates to:
  /// **'Choose favourite goal'**
  String get journalFavouriteGoalSet;

  /// No description provided for @journalFavouriteGoalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit favourite goal'**
  String get journalFavouriteGoalEdit;

  /// No description provided for @journalFavouriteGoalPlayer.
  ///
  /// In en, this message translates to:
  /// **'Scorer'**
  String get journalFavouriteGoalPlayer;

  /// No description provided for @journalFavouriteGoalMinute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get journalFavouriteGoalMinute;

  /// No description provided for @journalFavouriteGoalKind.
  ///
  /// In en, this message translates to:
  /// **'Type of goal'**
  String get journalFavouriteGoalKind;

  /// No description provided for @journalFavouriteGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe it'**
  String get journalFavouriteGoalDescription;

  /// No description provided for @journalGoalKindLongShot.
  ///
  /// In en, this message translates to:
  /// **'Long shot'**
  String get journalGoalKindLongShot;

  /// No description provided for @journalGoalKindCounterAttack.
  ///
  /// In en, this message translates to:
  /// **'Counter attack'**
  String get journalGoalKindCounterAttack;

  /// No description provided for @journalGoalKindFreeKick.
  ///
  /// In en, this message translates to:
  /// **'Free kick'**
  String get journalGoalKindFreeKick;

  /// No description provided for @journalGoalKindHeader.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get journalGoalKindHeader;

  /// No description provided for @journalGoalKindPenalty.
  ///
  /// In en, this message translates to:
  /// **'Penalty'**
  String get journalGoalKindPenalty;

  /// No description provided for @journalGoalKindTeamGoal.
  ///
  /// In en, this message translates to:
  /// **'Team goal'**
  String get journalGoalKindTeamGoal;

  /// No description provided for @journalGoalKindSoloGoal.
  ///
  /// In en, this message translates to:
  /// **'Solo goal'**
  String get journalGoalKindSoloGoal;

  /// No description provided for @journalSectionTactical.
  ///
  /// In en, this message translates to:
  /// **'Tactical notes'**
  String get journalSectionTactical;

  /// No description provided for @journalTacticalFormation.
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get journalTacticalFormation;

  /// No description provided for @journalTacticalFormationHint.
  ///
  /// In en, this message translates to:
  /// **'4-3-3'**
  String get journalTacticalFormationHint;

  /// No description provided for @journalTacticalBestTactic.
  ///
  /// In en, this message translates to:
  /// **'Best tactic'**
  String get journalTacticalBestTactic;

  /// No description provided for @journalTacticalBestTacticHint.
  ///
  /// In en, this message translates to:
  /// **'High press'**
  String get journalTacticalBestTacticHint;

  /// No description provided for @journalTacticalWeakness.
  ///
  /// In en, this message translates to:
  /// **'Key weakness'**
  String get journalTacticalWeakness;

  /// No description provided for @journalTacticalWeaknessHint.
  ///
  /// In en, this message translates to:
  /// **'Defensive transitions'**
  String get journalTacticalWeaknessHint;

  /// No description provided for @journalTacticalBestPlayer.
  ///
  /// In en, this message translates to:
  /// **'Best player'**
  String get journalTacticalBestPlayer;

  /// No description provided for @journalTacticalComment.
  ///
  /// In en, this message translates to:
  /// **'Tactical comment'**
  String get journalTacticalComment;

  /// No description provided for @journalTacticalAspects.
  ///
  /// In en, this message translates to:
  /// **'Rate the game'**
  String get journalTacticalAspects;

  /// No description provided for @journalAspectPossession.
  ///
  /// In en, this message translates to:
  /// **'Possession'**
  String get journalAspectPossession;

  /// No description provided for @journalAspectPressing.
  ///
  /// In en, this message translates to:
  /// **'Pressing'**
  String get journalAspectPressing;

  /// No description provided for @journalAspectCounterAttacks.
  ///
  /// In en, this message translates to:
  /// **'Counter attacks'**
  String get journalAspectCounterAttacks;

  /// No description provided for @journalAspectDefensiveOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Defensive organisation'**
  String get journalAspectDefensiveOrganisation;

  /// No description provided for @journalAspectSetPieces.
  ///
  /// In en, this message translates to:
  /// **'Set pieces'**
  String get journalAspectSetPieces;

  /// No description provided for @journalAspectBuildUp.
  ///
  /// In en, this message translates to:
  /// **'Build-up'**
  String get journalAspectBuildUp;

  /// No description provided for @journalSectionPrediction.
  ///
  /// In en, this message translates to:
  /// **'My call'**
  String get journalSectionPrediction;

  /// No description provided for @journalPredictionHint.
  ///
  /// In en, this message translates to:
  /// **'What you called before kickoff.'**
  String get journalPredictionHint;

  /// No description provided for @journalPredictionHomeScore.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get journalPredictionHomeScore;

  /// No description provided for @journalPredictionAwayScore.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get journalPredictionAwayScore;

  /// No description provided for @journalPredictionWinner.
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get journalPredictionWinner;

  /// No description provided for @journalPredictionWinnerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get journalPredictionWinnerHome;

  /// No description provided for @journalPredictionWinnerDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get journalPredictionWinnerDraw;

  /// No description provided for @journalPredictionWinnerAway.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get journalPredictionWinnerAway;

  /// No description provided for @journalPredictionFirstScorer.
  ///
  /// In en, this message translates to:
  /// **'First goalscorer'**
  String get journalPredictionFirstScorer;

  /// No description provided for @journalPredictionMotm.
  ///
  /// In en, this message translates to:
  /// **'Man of the match'**
  String get journalPredictionMotm;

  /// No description provided for @journalPredictionResult.
  ///
  /// In en, this message translates to:
  /// **'How it went'**
  String get journalPredictionResult;

  /// No description provided for @journalPredictionExact.
  ///
  /// In en, this message translates to:
  /// **'You called it exactly.'**
  String get journalPredictionExact;

  /// No description provided for @journalPredictionRightWinner.
  ///
  /// In en, this message translates to:
  /// **'Close. You said {called}, it finished {actual}.'**
  String journalPredictionRightWinner(String called, String actual);

  /// No description provided for @journalPredictionMissed.
  ///
  /// In en, this message translates to:
  /// **'Not this time. You said {called}, it finished {actual}.'**
  String journalPredictionMissed(String called, String actual);

  /// No description provided for @journalPredictionPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing to compare yet — no final score.'**
  String get journalPredictionPending;

  /// No description provided for @journalPredictionAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy {value}'**
  String journalPredictionAccuracy(String value);

  /// No description provided for @journalPredictionSave.
  ///
  /// In en, this message translates to:
  /// **'Save my call'**
  String get journalPredictionSave;

  /// No description provided for @journalSectionMood.
  ///
  /// In en, this message translates to:
  /// **'How you watched it'**
  String get journalSectionMood;

  /// No description provided for @journalMoodHype.
  ///
  /// In en, this message translates to:
  /// **'Hyped'**
  String get journalMoodHype;

  /// No description provided for @journalMoodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get journalMoodHappy;

  /// No description provided for @journalMoodEmotional.
  ///
  /// In en, this message translates to:
  /// **'Emotional'**
  String get journalMoodEmotional;

  /// No description provided for @journalMoodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get journalMoodAngry;

  /// No description provided for @journalMoodNervous.
  ///
  /// In en, this message translates to:
  /// **'Nervous'**
  String get journalMoodNervous;

  /// No description provided for @journalMoodShocked.
  ///
  /// In en, this message translates to:
  /// **'Shocked'**
  String get journalMoodShocked;

  /// No description provided for @journalMoodEntertained.
  ///
  /// In en, this message translates to:
  /// **'Entertained'**
  String get journalMoodEntertained;

  /// No description provided for @journalMoodRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get journalMoodRelaxed;

  /// No description provided for @journalMoodBored.
  ///
  /// In en, this message translates to:
  /// **'Bored'**
  String get journalMoodBored;

  /// No description provided for @journalSectionMemory.
  ///
  /// In en, this message translates to:
  /// **'My football memory'**
  String get journalSectionMemory;

  /// No description provided for @journalMemoryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where did you watch this match?'**
  String get journalMemoryQuestion;

  /// No description provided for @journalMemoryStoryHint.
  ///
  /// In en, this message translates to:
  /// **'I watched this match with my friends at a café.'**
  String get journalMemoryStoryHint;

  /// No description provided for @journalMemoryLocation.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get journalMemoryLocation;

  /// No description provided for @journalMemoryPeople.
  ///
  /// In en, this message translates to:
  /// **'Watched with'**
  String get journalMemoryPeople;

  /// No description provided for @journalMemoryOccasion.
  ///
  /// In en, this message translates to:
  /// **'Special occasion'**
  String get journalMemoryOccasion;

  /// No description provided for @journalMemoryDate.
  ///
  /// In en, this message translates to:
  /// **'Date watched'**
  String get journalMemoryDate;

  /// No description provided for @journalMemoryPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get journalMemoryPickDate;

  /// No description provided for @journalSectionTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get journalSectionTags;

  /// No description provided for @journalTagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tag this match so you can find it again.'**
  String get journalTagsEmpty;

  /// No description provided for @journalTagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add your own tag'**
  String get journalTagAdd;

  /// No description provided for @journalTagMasterclass.
  ///
  /// In en, this message translates to:
  /// **'Masterclass'**
  String get journalTagMasterclass;

  /// No description provided for @journalTagDerby.
  ///
  /// In en, this message translates to:
  /// **'Derby'**
  String get journalTagDerby;

  /// No description provided for @journalTagChampionsLeague.
  ///
  /// In en, this message translates to:
  /// **'Champions League'**
  String get journalTagChampionsLeague;

  /// No description provided for @journalTagComeback.
  ///
  /// In en, this message translates to:
  /// **'Comeback'**
  String get journalTagComeback;

  /// No description provided for @journalTagHistoric.
  ///
  /// In en, this message translates to:
  /// **'Historic'**
  String get journalTagHistoric;

  /// No description provided for @journalTagCrazyMatch.
  ///
  /// In en, this message translates to:
  /// **'Crazy match'**
  String get journalTagCrazyMatch;

  /// No description provided for @journalTagFavourite.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get journalTagFavourite;

  /// No description provided for @journalTagGoalFest.
  ///
  /// In en, this message translates to:
  /// **'Goal fest'**
  String get journalTagGoalFest;

  /// No description provided for @journalTagDefensiveMasterclass.
  ///
  /// In en, this message translates to:
  /// **'Defensive masterclass'**
  String get journalTagDefensiveMasterclass;

  /// No description provided for @journalTagBadReferee.
  ///
  /// In en, this message translates to:
  /// **'Bad referee'**
  String get journalTagBadReferee;

  /// No description provided for @journalTagMustWatch.
  ///
  /// In en, this message translates to:
  /// **'Must watch'**
  String get journalTagMustWatch;

  /// No description provided for @journalSectionMotm.
  ///
  /// In en, this message translates to:
  /// **'Man of the match'**
  String get journalSectionMotm;

  /// No description provided for @journalMotmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Who ran the game?'**
  String get journalMotmEmpty;

  /// No description provided for @journalMotmSet.
  ///
  /// In en, this message translates to:
  /// **'Choose man of the match'**
  String get journalMotmSet;

  /// No description provided for @journalMotmEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit man of the match'**
  String get journalMotmEdit;

  /// No description provided for @journalMotmPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get journalMotmPlayer;

  /// No description provided for @journalMotmRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get journalMotmRating;

  /// No description provided for @journalMotmReason.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get journalMotmReason;

  /// No description provided for @journalMotmReasonHint.
  ///
  /// In en, this message translates to:
  /// **'He completely controlled the midfield.'**
  String get journalMotmReasonHint;

  /// No description provided for @journalSectionActivity.
  ///
  /// In en, this message translates to:
  /// **'Journal timeline'**
  String get journalSectionActivity;

  /// No description provided for @journalActivityCreated.
  ///
  /// In en, this message translates to:
  /// **'Journal started'**
  String get journalActivityCreated;

  /// No description provided for @journalActivityNoteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Notes updated'**
  String get journalActivityNoteUpdated;

  /// No description provided for @journalActivityRated.
  ///
  /// In en, this message translates to:
  /// **'Match rated {detail}'**
  String journalActivityRated(String detail);

  /// No description provided for @journalActivityReactionAdded.
  ///
  /// In en, this message translates to:
  /// **'Reaction added {detail}'**
  String journalActivityReactionAdded(String detail);

  /// No description provided for @journalActivityMoodSet.
  ///
  /// In en, this message translates to:
  /// **'Mood saved {detail}'**
  String journalActivityMoodSet(String detail);

  /// No description provided for @journalActivityMomentAdded.
  ///
  /// In en, this message translates to:
  /// **'Moment saved · {detail}'**
  String journalActivityMomentAdded(String detail);

  /// No description provided for @journalActivityFavouriteGoalSet.
  ///
  /// In en, this message translates to:
  /// **'Favourite goal · {detail}'**
  String journalActivityFavouriteGoalSet(String detail);

  /// No description provided for @journalActivityManOfTheMatchSet.
  ///
  /// In en, this message translates to:
  /// **'Man of the match · {detail}'**
  String journalActivityManOfTheMatchSet(String detail);

  /// No description provided for @journalActivityPlayerRated.
  ///
  /// In en, this message translates to:
  /// **'Player rated · {detail}'**
  String journalActivityPlayerRated(String detail);

  /// No description provided for @journalActivityPredictionMade.
  ///
  /// In en, this message translates to:
  /// **'Call saved'**
  String get journalActivityPredictionMade;

  /// No description provided for @journalActivityTacticalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Tactical notes updated'**
  String get journalActivityTacticalUpdated;

  /// No description provided for @journalActivityMemoryWritten.
  ///
  /// In en, this message translates to:
  /// **'Memory saved'**
  String get journalActivityMemoryWritten;

  /// No description provided for @journalActivityEventAdded.
  ///
  /// In en, this message translates to:
  /// **'Timeline event added {detail}'**
  String journalActivityEventAdded(String detail);

  /// No description provided for @journalActivityStatAdded.
  ///
  /// In en, this message translates to:
  /// **'Statistic added · {detail}'**
  String journalActivityStatAdded(String detail);

  /// No description provided for @journalActivityTagAdded.
  ///
  /// In en, this message translates to:
  /// **'Tag added · {detail}'**
  String journalActivityTagAdded(String detail);

  /// No description provided for @journalActivityWatchedAgain.
  ///
  /// In en, this message translates to:
  /// **'Watched again'**
  String get journalActivityWatchedAgain;

  /// No description provided for @journalSectionStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics you noted'**
  String get journalSectionStats;

  /// No description provided for @journalStatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Record the numbers that stood out.'**
  String get journalStatsEmpty;

  /// No description provided for @journalStatAdd.
  ///
  /// In en, this message translates to:
  /// **'Add statistic'**
  String get journalStatAdd;

  /// No description provided for @journalStatEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit statistic'**
  String get journalStatEdit;

  /// No description provided for @journalStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Statistic'**
  String get journalStatLabel;

  /// No description provided for @journalStatHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get journalStatHome;

  /// No description provided for @journalStatAway.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get journalStatAway;

  /// No description provided for @journalStatPossession.
  ///
  /// In en, this message translates to:
  /// **'Possession'**
  String get journalStatPossession;

  /// No description provided for @journalStatShots.
  ///
  /// In en, this message translates to:
  /// **'Shots'**
  String get journalStatShots;

  /// No description provided for @journalStatShotsOnTarget.
  ///
  /// In en, this message translates to:
  /// **'Shots on target'**
  String get journalStatShotsOnTarget;

  /// No description provided for @journalStatCorners.
  ///
  /// In en, this message translates to:
  /// **'Corners'**
  String get journalStatCorners;

  /// No description provided for @journalStatBigChances.
  ///
  /// In en, this message translates to:
  /// **'Big moments'**
  String get journalStatBigChances;

  /// No description provided for @journalSummaryAction.
  ///
  /// In en, this message translates to:
  /// **'Summarise my match'**
  String get journalSummaryAction;

  /// No description provided for @journalSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your match, in short'**
  String get journalSummaryTitle;

  /// No description provided for @journalSummaryOpinion.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get journalSummaryOpinion;

  /// No description provided for @journalSummaryBestPlayer.
  ///
  /// In en, this message translates to:
  /// **'Best player'**
  String get journalSummaryBestPlayer;

  /// No description provided for @journalSummaryFavouriteMoment.
  ///
  /// In en, this message translates to:
  /// **'Favourite moment'**
  String get journalSummaryFavouriteMoment;

  /// No description provided for @journalSummaryTactical.
  ///
  /// In en, this message translates to:
  /// **'Tactical observation'**
  String get journalSummaryTactical;

  /// No description provided for @journalSummaryDisappointment.
  ///
  /// In en, this message translates to:
  /// **'Biggest disappointment'**
  String get journalSummaryDisappointment;

  /// No description provided for @journalSummaryFinalRating.
  ///
  /// In en, this message translates to:
  /// **'Final rating'**
  String get journalSummaryFinalRating;

  /// No description provided for @journalSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write a little more and the summary will have something to work with.'**
  String get journalSummaryEmpty;

  /// No description provided for @journalSummaryAppend.
  ///
  /// In en, this message translates to:
  /// **'Add to my notes'**
  String get journalSummaryAppend;

  /// No description provided for @journalSummaryNote.
  ///
  /// In en, this message translates to:
  /// **'Built from what you wrote. Your notes are never replaced.'**
  String get journalSummaryNote;

  /// No description provided for @journalSectionRewatch.
  ///
  /// In en, this message translates to:
  /// **'Rewatched'**
  String get journalSectionRewatch;

  /// No description provided for @journalWatchedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not logged yet} =1{Watched once} other{Watched {count} times}}'**
  String journalWatchedTimes(int count);

  /// No description provided for @journalFirstWatched.
  ///
  /// In en, this message translates to:
  /// **'First watched'**
  String get journalFirstWatched;

  /// No description provided for @journalLastWatched.
  ///
  /// In en, this message translates to:
  /// **'Last watched'**
  String get journalLastWatched;

  /// No description provided for @journalWatchAgain.
  ///
  /// In en, this message translates to:
  /// **'Watched again'**
  String get journalWatchAgain;

  /// No description provided for @journalBarNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get journalBarNote;

  /// No description provided for @journalBarMoment.
  ///
  /// In en, this message translates to:
  /// **'Moment'**
  String get journalBarMoment;

  /// No description provided for @journalBarRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get journalBarRate;

  /// No description provided for @journalBarPredict.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get journalBarPredict;

  /// No description provided for @journalHeaderTeam.
  ///
  /// In en, this message translates to:
  /// **'Team journal'**
  String get journalHeaderTeam;

  /// No description provided for @journalHeaderPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player journal'**
  String get journalHeaderPlayer;

  /// No description provided for @journalRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get journalRemove;

  /// No description provided for @journalSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get journalSave;

  /// No description provided for @journalOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get journalOptional;

  /// No description provided for @journalSemanticsRating.
  ///
  /// In en, this message translates to:
  /// **'{label}, {value} out of 10'**
  String journalSemanticsRating(String label, String value);

  /// No description provided for @journalSemanticsReaction.
  ///
  /// In en, this message translates to:
  /// **'{label}, {state}'**
  String journalSemanticsReaction(String label, String state);

  /// No description provided for @journalStateSelected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get journalStateSelected;

  /// No description provided for @journalStateNotSelected.
  ///
  /// In en, this message translates to:
  /// **'not selected'**
  String get journalStateNotSelected;

  /// No description provided for @journalPreviewOn.
  ///
  /// In en, this message translates to:
  /// **'Preview formatting'**
  String get journalPreviewOn;

  /// No description provided for @journalPreviewOff.
  ///
  /// In en, this message translates to:
  /// **'Back to editing'**
  String get journalPreviewOff;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @journalIndexTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journal'**
  String get journalIndexTitle;

  /// No description provided for @journalIndexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing written yet} =1{1 match written up} other{{count} matches written up}}'**
  String journalIndexSubtitle(int count);

  /// No description provided for @journalIndexEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your football story starts here.'**
  String get journalIndexEmptyTitle;

  /// No description provided for @journalIndexEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open any match and tap the journal icon to save what you thought, what you felt, and where you watched it.'**
  String get journalIndexEmptyBody;

  /// No description provided for @journalIndexEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Find a match'**
  String get journalIndexEmptyAction;

  /// No description provided for @journalIndexUnknownMatch.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get journalIndexUnknownMatch;

  /// No description provided for @journalIndexUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {date}'**
  String journalIndexUpdated(String date);

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support the app'**
  String get settingsSectionSupport;

  /// No description provided for @settingsRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad, browse ad-free'**
  String get settingsRewardTitle;

  /// No description provided for @settingsRewardBody.
  ///
  /// In en, this message translates to:
  /// **'One short video buys you {minutes} minutes without interruptions.'**
  String settingsRewardBody(int minutes);

  /// No description provided for @settingsRewardAction.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get settingsRewardAction;

  /// No description provided for @settingsAdFreeActive.
  ///
  /// In en, this message translates to:
  /// **'Ad-free for another {minutes} min'**
  String settingsAdFreeActive(int minutes);

  /// No description provided for @settingsAdFreeThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks — enjoy the quiet.'**
  String get settingsAdFreeThanks;

  /// No description provided for @settingsRewardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No video is ready just now. Try again in a moment.'**
  String get settingsRewardUnavailable;

  /// No description provided for @journalTabWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get journalTabWrite;

  /// No description provided for @journalTabRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get journalTabRate;

  /// No description provided for @journalTabMoments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get journalTabMoments;

  /// No description provided for @journalTabAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get journalTabAnalysis;

  /// No description provided for @journalProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} sections'**
  String journalProgress(int done, int total);

  /// No description provided for @journalUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next: {section}'**
  String journalUpNext(String section);

  /// No description provided for @journalAllDone.
  ///
  /// In en, this message translates to:
  /// **'Every section filled in. A complete journal.'**
  String get journalAllDone;

  /// No description provided for @journalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Journal deleted'**
  String get journalDeleted;

  /// No description provided for @journalUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get journalUndo;

  /// No description provided for @journalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search teams, competitions, notes'**
  String get journalSearchHint;

  /// No description provided for @journalFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get journalFilterAll;

  /// No description provided for @journalFilterRated.
  ///
  /// In en, this message translates to:
  /// **'Rated'**
  String get journalFilterRated;

  /// No description provided for @journalFilterNotes.
  ///
  /// In en, this message translates to:
  /// **'With notes'**
  String get journalFilterNotes;

  /// No description provided for @journalFilterPredictions.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get journalFilterPredictions;

  /// No description provided for @journalFilterTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get journalFilterTopRated;

  /// No description provided for @journalSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get journalSortTooltip;

  /// No description provided for @journalSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently edited'**
  String get journalSortRecent;

  /// No description provided for @journalSortMatchDate.
  ///
  /// In en, this message translates to:
  /// **'Match date'**
  String get journalSortMatchDate;

  /// No description provided for @journalSortRating.
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get journalSortRating;

  /// No description provided for @journalStatJournals.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get journalStatJournals;

  /// No description provided for @journalStatAverage.
  ///
  /// In en, this message translates to:
  /// **'Avg rating'**
  String get journalStatAverage;

  /// No description provided for @journalStatWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get journalStatWords;

  /// No description provided for @journalNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No journals match'**
  String get journalNoResultsTitle;

  /// No description provided for @journalNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another search or clear the filters.'**
  String get journalNoResultsBody;

  /// No description provided for @journalClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get journalClearFilters;

  /// No description provided for @journalByRating.
  ///
  /// In en, this message translates to:
  /// **'By rating'**
  String get journalByRating;

  /// No description provided for @journalSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get journalSwipeDelete;

  /// No description provided for @journalMoodHint.
  ///
  /// In en, this message translates to:
  /// **'Tap everything you felt. Your vibe updates as you go.'**
  String get journalMoodHint;

  /// No description provided for @journalMoodVibe.
  ///
  /// In en, this message translates to:
  /// **'Your vibe: {vibe}'**
  String journalMoodVibe(String vibe);

  /// No description provided for @journalMoodElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get journalMoodElectric;

  /// No description provided for @journalMoodTense.
  ///
  /// In en, this message translates to:
  /// **'Tense'**
  String get journalMoodTense;

  /// No description provided for @journalMoodContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get journalMoodContent;

  /// No description provided for @journalMoodFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat'**
  String get journalMoodFlat;

  /// No description provided for @journalMoodElectricHint.
  ///
  /// In en, this message translates to:
  /// **'High energy · good'**
  String get journalMoodElectricHint;

  /// No description provided for @journalMoodTenseHint.
  ///
  /// In en, this message translates to:
  /// **'High energy · rough'**
  String get journalMoodTenseHint;

  /// No description provided for @journalMoodContentHint.
  ///
  /// In en, this message translates to:
  /// **'Low energy · good'**
  String get journalMoodContentHint;

  /// No description provided for @journalMoodFlatHint.
  ///
  /// In en, this message translates to:
  /// **'Low energy · rough'**
  String get journalMoodFlatHint;

  /// No description provided for @journalReactionGood.
  ///
  /// In en, this message translates to:
  /// **'The good'**
  String get journalReactionGood;

  /// No description provided for @journalReactionBad.
  ///
  /// In en, this message translates to:
  /// **'The bad'**
  String get journalReactionBad;

  /// No description provided for @journalVerdict.
  ///
  /// In en, this message translates to:
  /// **'Your verdict: {verdict}'**
  String journalVerdict(String verdict);

  /// No description provided for @journalVerdictClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get journalVerdictClassic;

  /// No description provided for @journalVerdictGoodWatch.
  ///
  /// In en, this message translates to:
  /// **'Good watch'**
  String get journalVerdictGoodWatch;

  /// No description provided for @journalVerdictMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get journalVerdictMixed;

  /// No description provided for @journalVerdictRough.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get journalVerdictRough;

  /// No description provided for @journalVerdictForgettable.
  ///
  /// In en, this message translates to:
  /// **'Forgettable'**
  String get journalVerdictForgettable;

  /// No description provided for @journalStatVerdict.
  ///
  /// In en, this message translates to:
  /// **'Usual verdict'**
  String get journalStatVerdict;

  /// No description provided for @splashStepConfig.
  ///
  /// In en, this message translates to:
  /// **'Getting things ready…'**
  String get splashStepConfig;

  /// No description provided for @splashStepMatches.
  ///
  /// In en, this message translates to:
  /// **'Loading today\'s matches…'**
  String get splashStepMatches;

  /// No description provided for @splashStepReady.
  ///
  /// In en, this message translates to:
  /// **'Kick-off!'**
  String get splashStepReady;

  /// No description provided for @splashToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match today} other{{count} matches today}}'**
  String splashToday(int count);

  /// No description provided for @splashLive.
  ///
  /// In en, this message translates to:
  /// **'{count} live now'**
  String splashLive(int count);

  /// No description provided for @splashReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get splashReconnecting;

  /// No description provided for @splashAutoRetry.
  ///
  /// In en, this message translates to:
  /// **'We\'ll carry on as soon as you\'re back online.'**
  String get splashAutoRetry;

  /// No description provided for @errorQuotaTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s data limit is reached'**
  String get errorQuotaTitle;

  /// No description provided for @errorQuotaBody.
  ///
  /// In en, this message translates to:
  /// **'Scores already loaded stay on screen. Fresh data comes back when the limit resets.'**
  String get errorQuotaBody;

  /// No description provided for @settingsFollowingSummary.
  ///
  /// In en, this message translates to:
  /// **'{teams, plural, =1{1 team} other{{teams} teams}} · {competitions, plural, =1{1 competition} other{{competitions} competitions}}'**
  String settingsFollowingSummary(int teams, int competitions);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppL10nAr();
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
