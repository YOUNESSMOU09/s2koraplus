// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppL10nAr extends AppL10n {
  AppL10nAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مرمى';

  @override
  String get appTagline => 'بدون رهانات. بدون ضجيج. كرة قدم فقط.';

  @override
  String get navMatches => 'المباريات';

  @override
  String get navLive => 'مباشر';

  @override
  String get navFollowing => 'متابعة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get dayYesterday => 'أمس';

  @override
  String get dayToday => 'اليوم';

  @override
  String get dayTomorrow => 'غداً';

  @override
  String get screenMatches => 'المباريات';

  @override
  String get screenLive => 'مباشر';

  @override
  String get screenFollowing => 'متابعة';

  @override
  String get screenSettings => 'الإعدادات';

  @override
  String get screenSearch => 'بحث';

  @override
  String get screenManageFavourites => 'إدارة المفضّلة';

  @override
  String get screenAppearance => 'المظهر';

  @override
  String get screenLanguage => 'اللغة';

  @override
  String get screenAbout => 'عن التطبيق';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionDone => 'تم';

  @override
  String get actionSkip => 'تخطّي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionFollow => 'متابعة';

  @override
  String get actionUnfollow => 'إلغاء المتابعة';

  @override
  String get actionGoToToday => 'الانتقال إلى اليوم';

  @override
  String get actionSeeTodaysFixtures => 'عرض مباريات اليوم';

  @override
  String get actionAddFavourites => 'إضافة إلى المفضّلة';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get actionGetStarted => 'لنبدأ';

  @override
  String get actionSwitchDay => 'تغيير اليوم';

  @override
  String get statusTbd => 'الموعد لم يُحدَّد';

  @override
  String get statusNs => 'لم تبدأ';

  @override
  String get statusFirstHalf => 'الشوط الأول';

  @override
  String get statusHalfTime => 'استراحة بين الشوطين';

  @override
  String get statusSecondHalf => 'الشوط الثاني';

  @override
  String get statusExtraTime => 'الوقت الإضافي';

  @override
  String get statusBreakTime => 'استراحة';

  @override
  String get statusPenaltyShootout => 'ركلات الترجيح';

  @override
  String get statusSuspended => 'موقوفة';

  @override
  String get statusInterrupted => 'متوقفة';

  @override
  String get statusFullTime => 'انتهت';

  @override
  String get statusAfterExtraTime => 'انتهت بعد الوقت الإضافي';

  @override
  String get statusAfterPenalties => 'انتهت بركلات الترجيح';

  @override
  String get statusPostponed => 'تأجّلت';

  @override
  String get statusCancelled => 'أُلغيت';

  @override
  String get statusAbandoned => 'أُلغيت بعد البدء';

  @override
  String get statusTechnicalLoss => 'خسارة بقرار';

  @override
  String get statusWalkover => 'فوز بالانسحاب';

  @override
  String get statusLive => 'مباشر';

  @override
  String get abbrFullTime => 'انتهت';

  @override
  String get abbrAfterExtraTime => 'إضافي';

  @override
  String get abbrPenalties => 'ترجيح';

  @override
  String get abbrHalfTime => 'استراحة';

  @override
  String get abbrExtraTime => 'إضافي';

  @override
  String get abbrPostponed => 'تأجّلت';

  @override
  String get abbrCancelled => 'أُلغيت';

  @override
  String get abbrAbandoned => 'توقفت';

  @override
  String get abbrLive => 'مباشر';

  @override
  String get eventNormalGoal => 'هدف';

  @override
  String get eventOwnGoal => 'هدف في مرماه';

  @override
  String get eventPenaltyGoal => 'هدف من ركلة جزاء';

  @override
  String get eventMissedPenalty => 'أضاع ركلة جزاء';

  @override
  String get eventYellowCard => 'بطاقة صفراء';

  @override
  String get eventRedCard => 'بطاقة حمراء';

  @override
  String get eventSecondYellow => 'صفراء ثانية';

  @override
  String get eventSubstitution => 'تبديل';

  @override
  String get labelVenue => 'الملعب';

  @override
  String get labelReferee => 'الحكم';

  @override
  String get labelRound => 'الجولة';

  @override
  String get labelSeason => 'الموسم';

  @override
  String get labelKickoff => 'موعد البداية';

  @override
  String get labelCompetition => 'البطولة';

  @override
  String get labelTimeline => 'أحداث المباراة';

  @override
  String get labelCompetitions => 'البطولات';

  @override
  String get labelTeams => 'الفرق';

  @override
  String get labelMatches => 'المباريات';

  @override
  String labelAssist(String name) {
    return 'صناعة: $name';
  }

  @override
  String labelFullTimeScore(String home, String away) {
    return 'الوقت الأصلي $home–$away';
  }

  @override
  String labelPenaltiesScore(String home, String away) {
    return 'الترجيح $home–$away';
  }

  @override
  String get freshUpdatedJustNow => 'حُدِّثت الآن';

  @override
  String freshUpdatedMinutesAgo(int minutes) {
    return 'حُدِّثت قبل $minutes دقيقة';
  }

  @override
  String freshOfflineFrom(int minutes) {
    return 'دون اتصال · بيانات قبل $minutes دقيقة';
  }

  @override
  String get freshOfflineNoData => 'دون اتصال';

  @override
  String get freshNeverUpdated => 'لم تُحدَّث بعد';

  @override
  String get offlineBanner => 'لا يوجد اتصال. نعرض النتائج المحفوظة.';

  @override
  String get errorOfflineTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String errorOfflineBody(int minutes) {
    return 'نعرض نتائج محفوظة قبل $minutes دقيقة.';
  }

  @override
  String get errorOfflineBodyNoCache => 'اتصل بالإنترنت لتحميل مباريات اليوم.';

  @override
  String get errorTimeoutTitle => 'النتائج تتأخر قليلاً';

  @override
  String get errorTimeoutBody => 'لم يستجب مزوّد النتائج في الوقت المحدد.';

  @override
  String get errorServerTitle => 'مزوّد النتائج يمر بمشكلة';

  @override
  String get errorServerBody => 'سنواصل المحاولة.';

  @override
  String get errorBadResponseTitle => 'تعذّرت قراءة بيانات النتائج';

  @override
  String get errorBadResponseBody => 'وصلتنا بيانات بصيغة غير متوقعة.';

  @override
  String get errorUnknownTitle => 'حدث خطأ ما';

  @override
  String get errorUnknownBody => 'اسحب للأسفل للمحاولة من جديد.';

  @override
  String get emptyDayTitle => 'لا توجد مباريات';

  @override
  String get emptyDayBody => 'الكرة تأخذ إجازة أحياناً.';

  @override
  String get emptyLiveTitle => 'لا توجد مباريات جارية الآن';

  @override
  String get emptyLiveBody =>
      'ستظهر هنا الدقائق والأهداف فور انطلاق أي مباراة.';

  @override
  String get emptyFollowingTitle => 'تابع فريقاً لتبني قائمتك';

  @override
  String get emptyFollowingBody =>
      'فرقك وبطولاتك من أمس واليوم وغد، في مكان واحد.';

  @override
  String get emptyFollowingNoFixturesTitle => 'لا مباريات لمن تتابع';

  @override
  String get emptyFollowingNoFixturesBody =>
      'لا يوجد لفرقك أو بطولاتك مباريات أمس أو اليوم أو غداً. بعض الدوريات خارج الموسم.';

  @override
  String get emptySearchTitle => 'ابحث في أمس واليوم وغد';

  @override
  String get emptySearchBody => 'ابحث عن فريق أو بطولة أو دولة.';

  @override
  String noResultsTitle(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String get noResultsBody => 'يبحث تطبيق مرمى في مباريات أمس واليوم وغد فقط.';

  @override
  String get notFoundTitle => 'هذه المباراة خارج نطاق الأيام الثلاثة';

  @override
  String get notFoundBody => 'يغطي تطبيق مرمى مباريات أمس واليوم وغد فقط.';

  @override
  String get routeNotFoundTitle => 'هذه الصفحة غير موجودة';

  @override
  String get routeNotFoundBody =>
      'الرابط الذي فتحته لا يؤدي إلى أي شاشة في تطبيق مرمى.';

  @override
  String get loadingMatches => 'جارٍ تحميل المباريات';

  @override
  String liveCountLabel(int count) {
    return '$count مباشرة';
  }

  @override
  String get sectionLive => 'مباشر';

  @override
  String get sectionLaterToday => 'لاحقاً اليوم';

  @override
  String get sectionTomorrow => 'غداً';

  @override
  String get sectionFinished => 'انتهت';

  @override
  String matchesFollowedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة',
      few: '$count مباريات',
      two: 'مباراتان',
      one: 'مباراة واحدة',
      zero: 'لا مباريات',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionGeneral => 'عام';

  @override
  String get settingsSectionYourFootball => 'كرتك';

  @override
  String get settingsSectionLegal => 'القانونية والدعم';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsFollowing => 'المتابعة';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsTerms => 'شروط الاستخدام';

  @override
  String get settingsSupport => 'الدعم';

  @override
  String get settingsAbout => 'عن تطبيق مرمى';

  @override
  String get themeSystem => 'حسب النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageSystem => 'حسب النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String aboutVersion(String version, String build) {
    return 'الإصدار $version ($build)';
  }

  @override
  String get aboutAttribution =>
      'البيانات مقدَّمة من GOAL API ‏(goal-api.com).';

  @override
  String get aboutDisclaimer =>
      'تطبيق مرمى ليس تابعاً لأي نادٍ أو دوري أو اتحاد أو جهة تنظيمية، وليس معتمداً منها أو مرتبطاً بها. قد تتأخر النتائج وهي غير رسمية.';

  @override
  String get aboutPrivacyPosture =>
      'بدون حساب، وبدون تسجيل دخول، وبدون تتبّع. مفضّلاتك وإعداداتك والنتائج المحفوظة لا تغادر هذا الجهاز.';

  @override
  String get aboutBackendStatus => 'حالة مزوّد النتائج';

  @override
  String get aboutBackendHealthy => 'يعمل';

  @override
  String get aboutBackendUnhealthy => 'غير متاح';

  @override
  String get aboutBackendChecking => 'جارٍ التحقق…';

  @override
  String aboutBackendUpdated(int minutes) {
    return 'حُدِّثت البيانات قبل $minutes دقيقة';
  }

  @override
  String get aboutClearCache => 'مسح البيانات المحفوظة';

  @override
  String aboutClearCacheSubtitle(int kilobytes) {
    return '$kilobytes كيلوبايت من المباريات المحفوظة';
  }

  @override
  String get aboutCacheCleared => 'تم مسح البيانات المحفوظة.';

  @override
  String get manageEmptyTitle => 'لا توجد متابعات بعد';

  @override
  String get manageEmptyBody => 'أضف فريقاً أو بطولة وستظهر هنا.';

  @override
  String get manageTeamsHeader => 'الفرق';

  @override
  String get manageCompetitionsHeader => 'البطولات';

  @override
  String manageRemoved(String name) {
    return 'تمت إزالة $name';
  }

  @override
  String sheetFollowHome(String name) {
    return 'متابعة $name';
  }

  @override
  String sheetFollowCompetition(String name) {
    return 'متابعة $name';
  }

  @override
  String sheetUnfollow(String name) {
    return 'إلغاء متابعة $name';
  }

  @override
  String semanticsMatchScheduled(
    String home,
    String away,
    String time,
    String competition,
    String country,
  ) {
    return '$home ضد $away، تبدأ $time، $competition، $country';
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
    return '$home $homeGoals، $away $awayGoals، $minute، $competition، $country';
  }

  @override
  String semanticsMinute(String minute) {
    return 'الدقيقة $minute';
  }

  @override
  String semanticsMinuteAdded(String minute, String added) {
    return 'الدقيقة $minute زائد $added';
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
    return '$home $homeGoals، $away $awayGoals، انتهت، $competition، $country';
  }

  @override
  String semanticsFollowToggle(String name) {
    return 'متابعة $name';
  }

  @override
  String get semanticsRefresh => 'تحديث النتائج';

  @override
  String get semanticsSearch => 'البحث في المباريات';

  @override
  String semanticsLiveTabBadge(int count) {
    return '$count مباريات جارية';
  }

  @override
  String get searchHint => 'فريق أو بطولة أو دولة';

  @override
  String get matchDetailAttribution =>
      'البيانات مقدَّمة من GOAL API ‏(goal-api.com). تطبيق مرمى ليس تابعاً لأي نادٍ أو دوري أو اتحاد. قد تتأخر النتائج وهي غير رسمية.';

  @override
  String get matchDetailNoTimeline =>
      'تظهر هنا الأهداف والبطاقات والتبديلات أثناء سير المباراة.';

  @override
  String get matchDetailTimelineLiveOnly =>
      'أحداث المباراة متاحة للمباريات الجارية فقط.';

  @override
  String get worthTitle => 'يستحق المشاهدة';

  @override
  String get worthSubtitle => 'مباريات جارية، مرتبة حسب ما يحدث فيها.';

  @override
  String get worthAllLive => 'كل المباريات الجارية';

  @override
  String get worthNoneTight =>
      'لا توجد مباراة متقاربة الآن. كل المباريات الجارية بالأسفل.';

  @override
  String get worthPaused => 'متوقف مؤقتا — هذه النتائج أقدم من 10 دقائق.';

  @override
  String get liveViewCompetition => 'حسب المسابقة';

  @override
  String get liveViewCountry => 'حسب الدولة';

  @override
  String get worthReasonShootout => 'ركلات الترجيح';

  @override
  String get worthReasonExtraTime => 'الوقت الإضافي';

  @override
  String get worthReasonRedCardMany => 'طرد لاعبين';

  @override
  String worthReasonRedCardOne(String team, String minute) {
    return '$team بعشرة لاعبين منذ الدقيقة $minute';
  }

  @override
  String worthReasonComebackLead(String team) {
    return '$team قلب النتيجة';
  }

  @override
  String worthReasonBurst(String goals, String span) {
    return '$goals في $span';
  }

  @override
  String get worthReasonComebackLevel => 'تعادل بعد تأخر';

  @override
  String get worthReasonGoallessLate => 'بلا أهداف حتى الدقائق الأخيرة';

  @override
  String get worthReasonGoalless => 'بلا أهداف في الشوط الثاني';

  @override
  String get worthReasonLevelLate => 'التعادل مستمر في الدقائق الأخيرة';

  @override
  String get worthReasonLevel => 'تعادل في الشوط الثاني';

  @override
  String get worthReasonOneGoalLate => 'فارق هدف في الدقائق الأخيرة';

  @override
  String get worthReasonOneGoal => 'فارق هدف واحد';

  @override
  String worthReasonGoalsSoFar(String goals) {
    return '$goals حتى الآن';
  }

  @override
  String get worthReasonInPlay => 'جارية الآن';

  @override
  String worthBurstGoals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count هدفا',
      few: '$count أهداف',
      two: 'هدفان',
      one: 'هدف واحد',
    );
    return '$_temp0';
  }

  @override
  String worthBurstMinutes(int span) {
    String _temp0 = intl.Intl.pluralLogic(
      span,
      locale: localeName,
      other: '$span دقيقة',
      few: '$span دقائق',
      two: 'دقيقتين',
      one: 'دقيقة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get worthHowAction => 'كيف تُرتب «يستحق المشاهدة»';

  @override
  String get worthHowTitle => 'كيف تُرتب «يستحق المشاهدة»';

  @override
  String get worthHowBody1 =>
      'هذه مباريات تُلعب الآن، مرتبة حسب ما حدث فيها بالفعل.';

  @override
  String get worthHowBody2 =>
      'ينظر تطبيق مرمى إلى قرب النتيجة، وكم بقي من زمن المباراة، وهل جاءت الأهداف في وقت قصير، وهل عاد فريق بعد تأخر، وهل طُرد أحد اللاعبين.';

  @override
  String get worthHowBody3 =>
      'هذا ليس توقعا. لا يقول تطبيق مرمى من سيفوز، ولا يعرض أي احتمالات أو نسب مئوية، ولا يحتوي على أي محتوى مراهنات.';

  @override
  String atlasCountries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دولة',
      few: '$count دول',
      two: 'دولتان',
      one: 'دولة واحدة',
    );
    return '$_temp0';
  }

  @override
  String atlasMatches(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة',
      few: '$count مباريات',
      two: 'مباراتان',
      one: 'مباراة واحدة',
    );
    return '$_temp0';
  }

  @override
  String atlasSummary(String a, String b) {
    return '$a · $b';
  }

  @override
  String atlasAsOf(int minutes) {
    return 'حتى قبل $minutes دقيقة';
  }

  @override
  String atlasOfflineAsOf(int minutes) {
    return 'بدون اتصال · حتى قبل $minutes دقيقة';
  }

  @override
  String get atlasInternational => 'مسابقات دولية';

  @override
  String get atlasInternationalOnly => 'مسابقات دولية فقط';

  @override
  String semanticsCountryRow(String country, String matches) {
    return '$country، $matches';
  }

  @override
  String semanticsWorthHeader(String matches) {
    return 'يستحق المشاهدة، $matches';
  }

  @override
  String get journalTitle => 'يوميات الكرة';

  @override
  String get journalActionOpen => 'اليوميات';

  @override
  String get journalEmptyTitle => 'اكتب حكايتك مع الكرة.';

  @override
  String get journalEmptyBody =>
      'احفظ انفعالاتك ولحظاتك المفضّلة وتوقيعاتك وتقييمات اللاعبين وذكرياتك مع اللعبة الجميلة.';

  @override
  String get journalEmptyAction => 'ابدأ يومياتك';

  @override
  String get journalDeleteAction => 'حذف اليوميات';

  @override
  String get journalDeleteTitle => 'حذف هذه اليوميات؟';

  @override
  String get journalDeleteBody =>
      'كل ما كتبته عن هذه المباراة محفوظ على هذا الجهاز فقط، ولا يمكن استرجاعه.';

  @override
  String get journalSectionNote => 'ملاحظاتك';

  @override
  String get journalNoteHintMatch => 'ما رأيك في هذه المباراة؟';

  @override
  String get journalNoteHintTeam => 'ما رأيك في هذا الفريق؟';

  @override
  String get journalNoteHintPlayer => 'ما رأيك في هذا اللاعب؟';

  @override
  String get journalNoteFormattingHint => '# عنوان · **عريض** · - قائمة';

  @override
  String get journalSaving => 'جارٍ الحفظ…';

  @override
  String get journalSavedJustNow => 'تم الحفظ الآن';

  @override
  String journalSavedAt(String time) {
    return 'تم الحفظ $time';
  }

  @override
  String get journalUnsaved => 'لم يُحفظ بعد';

  @override
  String journalWordCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كلمة',
      few: '$count كلمات',
      two: 'كلمتان',
      one: 'كلمة واحدة',
      zero: 'لا كلمات',
    );
    return '$_temp0';
  }

  @override
  String journalCharacterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حرفًا',
      few: '$count حروف',
      two: 'حرفان',
      one: 'حرف واحد',
      zero: 'لا حروف',
    );
    return '$_temp0';
  }

  @override
  String get journalSectionReactions => 'انفعالك بالمباراة';

  @override
  String get journalReactionsHint => 'اختر كل ما شعرت به.';

  @override
  String get journalReactionIncredible => 'مذهلة';

  @override
  String get journalReactionLoved => 'أحببتها';

  @override
  String get journalReactionUnbelievable => 'لا تُصدَّق';

  @override
  String get journalReactionFunny => 'مضحكة';

  @override
  String get journalReactionAngry => 'غاضب';

  @override
  String get journalReactionHeartbreaking => 'موجعة';

  @override
  String get journalReactionCrazy => 'مباراة جنونية';

  @override
  String get journalReactionBoring => 'مملة';

  @override
  String get journalReactionGreatPerformance => 'أداء رائع';

  @override
  String get journalReactionDisaster => 'كارثة';

  @override
  String get journalSectionRating => 'تقييمك للمباراة';

  @override
  String get journalRatingOverall => 'التقييم العام';

  @override
  String get journalRatingHome => 'الفريق المضيف';

  @override
  String get journalRatingAway => 'الفريق الضيف';

  @override
  String get journalRatingReferee => 'الحكم';

  @override
  String get journalRatingAtmosphere => 'الأجواء';

  @override
  String get journalRatingExperience => 'تجربة المباراة';

  @override
  String journalRatingOutOf(String value) {
    return '$value/10';
  }

  @override
  String get journalRatingUnset => 'بدون تقييم';

  @override
  String get journalRatingClear => 'مسح التقييم';

  @override
  String get journalSectionPlayers => 'أداء اللاعبين';

  @override
  String get journalPlayersEmpty => 'لم تقيّم أي لاعب بعد.';

  @override
  String get journalPlayerAdd => 'إضافة لاعب';

  @override
  String get journalPlayerEdit => 'تعديل اللاعب';

  @override
  String get journalPlayerName => 'اسم اللاعب';

  @override
  String get journalPlayerRating => 'التقييم';

  @override
  String get journalPlayerGoals => 'الأهداف';

  @override
  String get journalPlayerAssists => 'التمريرات الحاسمة';

  @override
  String get journalPlayerKeyPasses => 'التمريرات المفتاحية';

  @override
  String get journalPlayerDefending => 'الأداء الدفاعي';

  @override
  String get journalPlayerComment => 'تعليقك';

  @override
  String get journalPlayerCommentHint => 'كان خطيرًا طوال المباراة.';

  @override
  String get journalPlayerSortRating => 'الأعلى تقييمًا أولًا';

  @override
  String get journalPlayerSortAdded => 'ترتيب الإضافة';

  @override
  String get journalSectionMoments => 'لحظاتك المفضّلة';

  @override
  String get journalMomentsEmpty =>
      'لا شيء محفوظ بعد. اللحظة التي تعيد مشاهدتها تُكتب هنا.';

  @override
  String get journalMomentAdd => 'إضافة لحظة';

  @override
  String get journalMomentEdit => 'تعديل اللحظة';

  @override
  String get journalMomentTitle => 'العنوان';

  @override
  String get journalMomentTitleHint => 'هدف الليلة';

  @override
  String get journalMomentDescription => 'ماذا حدث';

  @override
  String get journalMomentDescriptionHint => 'تلك الهجمة المرتدة كانت مذهلة.';

  @override
  String get journalMomentMinute => 'الدقيقة';

  @override
  String get journalMomentSecond => 'الثانية';

  @override
  String get journalMomentPlayer => 'اللاعب (اختياري)';

  @override
  String get journalMomentGlyph => 'رمز تعبيري';

  @override
  String get journalSectionEvents => 'شريط أحداث المباراة';

  @override
  String get journalEventsEmpty =>
      'أضف الأهداف والبطاقات ونقاط التحول التي تتذكرها.';

  @override
  String get journalEventAdd => 'إضافة حدث';

  @override
  String get journalEventEdit => 'تعديل الحدث';

  @override
  String get journalEventKind => 'الحدث';

  @override
  String get journalEventMinute => 'الدقيقة';

  @override
  String get journalEventExtra => 'الوقت المحتسب';

  @override
  String get journalEventLabel => 'لاعب أو ملاحظة';

  @override
  String get journalEventSide => 'الطرف';

  @override
  String get journalEventGoal => 'هدف';

  @override
  String get journalEventYellowCard => 'بطاقة صفراء';

  @override
  String get journalEventRedCard => 'بطاقة حمراء';

  @override
  String get journalEventSubstitution => 'تبديل';

  @override
  String get journalEventSave => 'تصدٍّ رائع';

  @override
  String get journalEventAssist => 'تمريرة حاسمة';

  @override
  String get journalEventMissedChance => 'فرصة ضائعة';

  @override
  String get journalEventRefereeDecision => 'قرار تحكيمي';

  @override
  String get journalSectionFavouriteGoal => 'الهدف المفضّل';

  @override
  String get journalFavouriteGoalEmpty =>
      'اختر الهدف الذي تودّ مشاهدته مرة أخرى.';

  @override
  String get journalFavouriteGoalSet => 'اختر الهدف المفضّل';

  @override
  String get journalFavouriteGoalEdit => 'تعديل الهدف المفضّل';

  @override
  String get journalFavouriteGoalPlayer => 'المسجّل';

  @override
  String get journalFavouriteGoalMinute => 'الدقيقة';

  @override
  String get journalFavouriteGoalKind => 'نوع الهدف';

  @override
  String get journalFavouriteGoalDescription => 'صِف الهدف';

  @override
  String get journalGoalKindLongShot => 'تسديدة بعيدة';

  @override
  String get journalGoalKindCounterAttack => 'هجمة مرتدة';

  @override
  String get journalGoalKindFreeKick => 'ركلة حرة';

  @override
  String get journalGoalKindHeader => 'ضربة رأس';

  @override
  String get journalGoalKindPenalty => 'ركلة جزاء';

  @override
  String get journalGoalKindTeamGoal => 'هدف جماعي';

  @override
  String get journalGoalKindSoloGoal => 'هدف فردي';

  @override
  String get journalSectionTactical => 'ملاحظات تكتيكية';

  @override
  String get journalTacticalFormation => 'التشكيل';

  @override
  String get journalTacticalFormationHint => '4-3-3';

  @override
  String get journalTacticalBestTactic => 'أفضل تكتيك';

  @override
  String get journalTacticalBestTacticHint => 'ضغط عالٍ';

  @override
  String get journalTacticalWeakness => 'أبرز نقطة ضعف';

  @override
  String get journalTacticalWeaknessHint => 'التحولات الدفاعية';

  @override
  String get journalTacticalBestPlayer => 'أفضل لاعب';

  @override
  String get journalTacticalComment => 'تعليق تكتيكي';

  @override
  String get journalTacticalAspects => 'قيّم جوانب اللعب';

  @override
  String get journalAspectPossession => 'الاستحواذ';

  @override
  String get journalAspectPressing => 'الضغط';

  @override
  String get journalAspectCounterAttacks => 'الهجمات المرتدة';

  @override
  String get journalAspectDefensiveOrganisation => 'التنظيم الدفاعي';

  @override
  String get journalAspectSetPieces => 'الكرات الثابتة';

  @override
  String get journalAspectBuildUp => 'بناء اللعب';

  @override
  String get journalSectionPrediction => 'قراءتك للمباراة';

  @override
  String get journalPredictionHint => 'ما قلته قبل صافرة البداية.';

  @override
  String get journalPredictionHomeScore => 'المضيف';

  @override
  String get journalPredictionAwayScore => 'الضيف';

  @override
  String get journalPredictionWinner => 'الفائز';

  @override
  String get journalPredictionWinnerHome => 'المضيف';

  @override
  String get journalPredictionWinnerDraw => 'تعادل';

  @override
  String get journalPredictionWinnerAway => 'الضيف';

  @override
  String get journalPredictionFirstScorer => 'أول مسجّل';

  @override
  String get journalPredictionMotm => 'رجل المباراة';

  @override
  String get journalPredictionResult => 'كيف انتهت';

  @override
  String get journalPredictionExact => 'أصبت تمامًا.';

  @override
  String journalPredictionRightWinner(String called, String actual) {
    return 'قريب. قلت $called، وانتهت $actual.';
  }

  @override
  String journalPredictionMissed(String called, String actual) {
    return 'ليس هذه المرة. قلت $called، وانتهت $actual.';
  }

  @override
  String get journalPredictionPending =>
      'لا شيء للمقارنة بعد — لا نتيجة نهائية.';

  @override
  String journalPredictionAccuracy(String value) {
    return 'الدقة $value';
  }

  @override
  String get journalPredictionSave => 'احفظ قراءتك';

  @override
  String get journalSectionMood => 'كيف تابعتها';

  @override
  String get journalMoodHype => 'متحمّس';

  @override
  String get journalMoodHappy => 'سعيد';

  @override
  String get journalMoodEmotional => 'متأثّر';

  @override
  String get journalMoodAngry => 'غاضب';

  @override
  String get journalMoodNervous => 'متوتّر';

  @override
  String get journalMoodShocked => 'مصدوم';

  @override
  String get journalMoodEntertained => 'مستمتع';

  @override
  String get journalMoodRelaxed => 'مرتاح';

  @override
  String get journalMoodBored => 'ملول';

  @override
  String get journalSectionMemory => 'ذكرياتي مع المباراة';

  @override
  String get journalMemoryQuestion => 'أين شاهدت هذه المباراة؟';

  @override
  String get journalMemoryStoryHint => 'شاهدت المباراة مع أصدقائي في المقهى.';

  @override
  String get journalMemoryLocation => 'المكان';

  @override
  String get journalMemoryPeople => 'شاهدتها مع';

  @override
  String get journalMemoryOccasion => 'مناسبة خاصة';

  @override
  String get journalMemoryDate => 'تاريخ المشاهدة';

  @override
  String get journalMemoryPickDate => 'اختر تاريخًا';

  @override
  String get journalSectionTags => 'الوسوم';

  @override
  String get journalTagsEmpty => 'ضع وسمًا لهذه المباراة كي تجدها لاحقًا.';

  @override
  String get journalTagAdd => 'أضف وسمك الخاص';

  @override
  String get journalTagMasterclass => 'درس في الكرة';

  @override
  String get journalTagDerby => 'ديربي';

  @override
  String get journalTagChampionsLeague => 'دوري الأبطال';

  @override
  String get journalTagComeback => 'ريمونتادا';

  @override
  String get journalTagHistoric => 'تاريخية';

  @override
  String get journalTagCrazyMatch => 'مباراة جنونية';

  @override
  String get journalTagFavourite => 'مفضّلة';

  @override
  String get journalTagGoalFest => 'مهرجان أهداف';

  @override
  String get journalTagDefensiveMasterclass => 'أداء دفاعي مثالي';

  @override
  String get journalTagBadReferee => 'تحكيم سيئ';

  @override
  String get journalTagMustWatch => 'تستحق المشاهدة';

  @override
  String get journalSectionMotm => 'رجل المباراة';

  @override
  String get journalMotmEmpty => 'من أدار اللقاء؟';

  @override
  String get journalMotmSet => 'اختر رجل المباراة';

  @override
  String get journalMotmEdit => 'تعديل رجل المباراة';

  @override
  String get journalMotmPlayer => 'اللاعب';

  @override
  String get journalMotmRating => 'التقييم';

  @override
  String get journalMotmReason => 'لماذا؟';

  @override
  String get journalMotmReasonHint => 'سيطر تمامًا على وسط الملعب.';

  @override
  String get journalSectionActivity => 'سجل يومياتك';

  @override
  String get journalActivityCreated => 'بدأت اليوميات';

  @override
  String get journalActivityNoteUpdated => 'تحديث الملاحظات';

  @override
  String journalActivityRated(String detail) {
    return 'تقييم المباراة $detail';
  }

  @override
  String journalActivityReactionAdded(String detail) {
    return 'إضافة انفعال $detail';
  }

  @override
  String journalActivityMoodSet(String detail) {
    return 'حفظ الحالة $detail';
  }

  @override
  String journalActivityMomentAdded(String detail) {
    return 'حفظ لحظة · $detail';
  }

  @override
  String journalActivityFavouriteGoalSet(String detail) {
    return 'الهدف المفضّل · $detail';
  }

  @override
  String journalActivityManOfTheMatchSet(String detail) {
    return 'رجل المباراة · $detail';
  }

  @override
  String journalActivityPlayerRated(String detail) {
    return 'تقييم لاعب · $detail';
  }

  @override
  String get journalActivityPredictionMade => 'حفظ قراءتك';

  @override
  String get journalActivityTacticalUpdated => 'تحديث الملاحظات التكتيكية';

  @override
  String get journalActivityMemoryWritten => 'حفظ الذكرى';

  @override
  String journalActivityEventAdded(String detail) {
    return 'إضافة حدث $detail';
  }

  @override
  String journalActivityStatAdded(String detail) {
    return 'إضافة إحصائية · $detail';
  }

  @override
  String journalActivityTagAdded(String detail) {
    return 'إضافة وسم · $detail';
  }

  @override
  String get journalActivityWatchedAgain => 'مشاهدة جديدة';

  @override
  String get journalSectionStats => 'إحصائيات دوّنتها';

  @override
  String get journalStatsEmpty => 'سجّل الأرقام التي لفتت انتباهك.';

  @override
  String get journalStatAdd => 'إضافة إحصائية';

  @override
  String get journalStatEdit => 'تعديل الإحصائية';

  @override
  String get journalStatLabel => 'الإحصائية';

  @override
  String get journalStatHome => 'المضيف';

  @override
  String get journalStatAway => 'الضيف';

  @override
  String get journalStatPossession => 'الاستحواذ';

  @override
  String get journalStatShots => 'التسديدات';

  @override
  String get journalStatShotsOnTarget => 'التسديدات على المرمى';

  @override
  String get journalStatCorners => 'الركنيات';

  @override
  String get journalStatBigChances => 'اللحظات الكبرى';

  @override
  String get journalSummaryAction => 'لخّص مباراتي';

  @override
  String get journalSummaryTitle => 'مباراتك باختصار';

  @override
  String get journalSummaryOpinion => 'الخلاصة';

  @override
  String get journalSummaryBestPlayer => 'أفضل لاعب';

  @override
  String get journalSummaryFavouriteMoment => 'اللحظة المفضّلة';

  @override
  String get journalSummaryTactical => 'ملاحظة تكتيكية';

  @override
  String get journalSummaryDisappointment => 'أكبر خيبة';

  @override
  String get journalSummaryFinalRating => 'التقييم النهائي';

  @override
  String get journalSummaryEmpty =>
      'اكتب المزيد قليلًا ليجد الملخّص ما يبني عليه.';

  @override
  String get journalSummaryAppend => 'أضِف إلى ملاحظاتي';

  @override
  String get journalSummaryNote =>
      'مبني على ما كتبته. ملاحظاتك لا تُستبدل أبدًا.';

  @override
  String get journalSectionRewatch => 'إعادة المشاهدة';

  @override
  String journalWatchedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شاهدتها $count مرة',
      few: 'شاهدتها $count مرات',
      two: 'شاهدتها مرتين',
      one: 'شاهدتها مرة',
      zero: 'لم تُسجَّل بعد',
    );
    return '$_temp0';
  }

  @override
  String get journalFirstWatched => 'أول مشاهدة';

  @override
  String get journalLastWatched => 'آخر مشاهدة';

  @override
  String get journalWatchAgain => 'شاهدتها مجددًا';

  @override
  String get journalBarNote => 'ملاحظة';

  @override
  String get journalBarMoment => 'لحظة';

  @override
  String get journalBarRate => 'تقييم';

  @override
  String get journalBarPredict => 'قراءة';

  @override
  String get journalHeaderTeam => 'يوميات الفريق';

  @override
  String get journalHeaderPlayer => 'يوميات اللاعب';

  @override
  String get journalRemove => 'إزالة';

  @override
  String get journalSave => 'حفظ';

  @override
  String get journalOptional => 'اختياري';

  @override
  String journalSemanticsRating(String label, String value) {
    return '$label، $value من 10';
  }

  @override
  String journalSemanticsReaction(String label, String state) {
    return '$label، $state';
  }

  @override
  String get journalStateSelected => 'محدد';

  @override
  String get journalStateNotSelected => 'غير محدد';

  @override
  String get journalPreviewOn => 'معاينة التنسيق';

  @override
  String get journalPreviewOff => 'العودة للتحرير';

  @override
  String get navJournal => 'اليوميات';

  @override
  String get journalIndexTitle => 'يومياتك';

  @override
  String journalIndexSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة مكتوبة',
      few: '$count مباريات مكتوبة',
      two: 'مباراتان مكتوبتان',
      one: 'مباراة واحدة مكتوبة',
      zero: 'لم تكتب شيئًا بعد',
    );
    return '$_temp0';
  }

  @override
  String get journalIndexEmptyTitle => 'حكايتك مع الكرة تبدأ من هنا.';

  @override
  String get journalIndexEmptyBody =>
      'افتح أي مباراة واضغط أيقونة اليوميات لتحفظ ما رأيته وما شعرت به وأين شاهدتها.';

  @override
  String get journalIndexEmptyAction => 'ابحث عن مباراة';

  @override
  String get journalIndexUnknownMatch => 'مباراة';

  @override
  String journalIndexUpdated(String date) {
    return 'آخر تحديث $date';
  }

  @override
  String get settingsSectionSupport => 'ادعم التطبيق';

  @override
  String get settingsRewardTitle => 'شاهد إعلانًا، وتصفّح بلا إعلانات';

  @override
  String settingsRewardBody(int minutes) {
    return 'فيديو قصير واحد يمنحك $minutes دقيقة دون مقاطعة.';
  }

  @override
  String get settingsRewardAction => 'مشاهدة';

  @override
  String settingsAdFreeActive(int minutes) {
    return 'بلا إعلانات لمدة $minutes دقيقة أخرى';
  }

  @override
  String get settingsAdFreeThanks => 'شكرًا لك — استمتع بالهدوء.';

  @override
  String get settingsRewardUnavailable =>
      'لا يوجد فيديو جاهز الآن. حاول بعد قليل.';

  @override
  String get journalTabWrite => 'اكتب';

  @override
  String get journalTabRate => 'قيّم';

  @override
  String get journalTabMoments => 'لحظات';

  @override
  String get journalTabAnalysis => 'تحليل';

  @override
  String journalProgress(int done, int total) {
    return '$done من $total أقسام';
  }

  @override
  String journalUpNext(String section) {
    return 'التالي: $section';
  }

  @override
  String get journalAllDone => 'اكتملت كل الأقسام. يومية كاملة.';

  @override
  String get journalDeleted => 'حُذفت اليومية';

  @override
  String get journalUndo => 'تراجع';

  @override
  String get journalSearchHint => 'ابحث في الفرق والبطولات والملاحظات';

  @override
  String get journalFilterAll => 'الكل';

  @override
  String get journalFilterRated => 'مقيّمة';

  @override
  String get journalFilterNotes => 'بملاحظات';

  @override
  String get journalFilterPredictions => 'توقعات';

  @override
  String get journalFilterTopRated => 'الأعلى تقييمًا';

  @override
  String get journalSortTooltip => 'ترتيب';

  @override
  String get journalSortRecent => 'آخر تعديل';

  @override
  String get journalSortMatchDate => 'تاريخ المباراة';

  @override
  String get journalSortRating => 'الأعلى تقييمًا';

  @override
  String get journalStatJournals => 'يوميات';

  @override
  String get journalStatAverage => 'متوسط التقييم';

  @override
  String get journalStatWords => 'كلمات';

  @override
  String get journalNoResultsTitle => 'لا توجد يوميات مطابقة';

  @override
  String get journalNoResultsBody => 'جرّب بحثًا آخر أو امسح عوامل التصفية.';

  @override
  String get journalClearFilters => 'مسح عوامل التصفية';

  @override
  String get journalByRating => 'حسب التقييم';

  @override
  String get journalSwipeDelete => 'حذف';

  @override
  String get journalMoodHint =>
      'اختر كل ما شعرت به. يتحدّث مزاجك أثناء الاختيار.';

  @override
  String journalMoodVibe(String vibe) {
    return 'مزاجك: $vibe';
  }

  @override
  String get journalMoodElectric => 'حماسي';

  @override
  String get journalMoodTense => 'متوتر';

  @override
  String get journalMoodContent => 'مرتاح';

  @override
  String get journalMoodFlat => 'فاتر';

  @override
  String get journalMoodElectricHint => 'طاقة عالية · شعور جيد';

  @override
  String get journalMoodTenseHint => 'طاقة عالية · شعور صعب';

  @override
  String get journalMoodContentHint => 'طاقة هادئة · شعور جيد';

  @override
  String get journalMoodFlatHint => 'طاقة هادئة · شعور صعب';

  @override
  String get journalReactionGood => 'الإيجابي';

  @override
  String get journalReactionBad => 'السلبي';

  @override
  String journalVerdict(String verdict) {
    return 'حكمك: $verdict';
  }

  @override
  String get journalVerdictClassic => 'كلاسيكية';

  @override
  String get journalVerdictGoodWatch => 'ممتعة';

  @override
  String get journalVerdictMixed => 'متقلبة';

  @override
  String get journalVerdictRough => 'صعبة';

  @override
  String get journalVerdictForgettable => 'تُنسى';

  @override
  String get journalStatVerdict => 'حكمك المعتاد';

  @override
  String get splashStepConfig => 'نجهّز كل شيء…';

  @override
  String get splashStepMatches => 'نحمّل مباريات اليوم…';

  @override
  String get splashStepReady => 'انطلاق!';

  @override
  String splashToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مباراة اليوم',
      few: '$count مباريات اليوم',
      two: 'مباراتان اليوم',
      one: 'مباراة واحدة اليوم',
    );
    return '$_temp0';
  }

  @override
  String splashLive(int count) {
    return '$count مباشر الآن';
  }

  @override
  String get splashReconnecting => 'نعيد الاتصال…';

  @override
  String get splashAutoRetry => 'سنتابع تلقائيًا فور عودة الاتصال.';

  @override
  String get errorQuotaTitle => 'بلغنا حد البيانات لهذا اليوم';

  @override
  String get errorQuotaBody =>
      'تبقى النتائج المحمّلة ظاهرة، وتعود البيانات الجديدة عند تجديد الحد.';

  @override
  String settingsFollowingSummary(int teams, int competitions) {
    return '$teams فرق · $competitions بطولات';
  }
}
