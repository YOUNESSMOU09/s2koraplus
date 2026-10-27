/// Localised country names.
///
/// The API returns English, hyphenated country names (`Saudi-Arabia`). In `en`
/// we simply de-hyphenate them; in `ar` we look them up here. Team and
/// competition names are NOT translated — the API returns Latin script only,
/// and transliterating them would invent data (documented limitation, §9).
///
/// Stored as one packed `Name:Arabic` string parsed once on first use, rather
/// than a large map literal.
library;

import 'package:marma/core/utils/country_flag.dart';

const String _kPackedArabicCountries =
    'Algeria:الجزائر;Argentina:الأرجنتين;Australia:أستراليا;Austria:النمسا;'
    'Bahrain:البحرين;Bangladesh:بنغلاديش;Belgium:بلجيكا;Bolivia:بوليفيا;'
    'Brazil:البرازيل;Cameroon:الكاميرون;Canada:كندا;Chile:تشيلي;China:الصين;'
    'Colombia:كولومبيا;Congo-DR:الكونغو الديمقراطية;Costa-Rica:كوستاريكا;'
    'Croatia:كرواتيا;Czech-Republic:التشيك;Denmark:الدنمارك;Ecuador:الإكوادور;'
    'Egypt:مصر;England:إنجلترا;Ethiopia:إثيوبيا;Finland:فنلندا;France:فرنسا;'
    'Germany:ألمانيا;Ghana:غانا;Greece:اليونان;Honduras:هندوراس;Hungary:المجر;'
    'India:الهند;Indonesia:إندونيسيا;Iran:إيران;Iraq:العراق;Ireland:إيرلندا;'
    'Italy:إيطاليا;Ivory-Coast:ساحل العاج;Japan:اليابان;Jordan:الأردن;'
    'Kenya:كينيا;Kuwait:الكويت;Lebanon:لبنان;Libya:ليبيا;Malaysia:ماليزيا;'
    'Mali:مالي;Mauritania:موريتانيا;Mexico:المكسيك;Morocco:المغرب;'
    'Netherlands:هولندا;Nigeria:نيجيريا;Northern-Ireland:إيرلندا الشمالية;'
    'Norway:النرويج;Oman:عُمان;Palestine:فلسطين;Panama:بنما;Paraguay:باراغواي;'
    'Peru:بيرو;Poland:بولندا;Portugal:البرتغال;Qatar:قطر;Romania:رومانيا;'
    'Russia:روسيا;Saudi-Arabia:السعودية;Scotland:إسكتلندا;Senegal:السنغال;'
    'Serbia:صربيا;South-Africa:جنوب أفريقيا;South-Korea:كوريا الجنوبية;'
    'Spain:إسبانيا;Sudan:السودان;Sweden:السويد;Switzerland:سويسرا;Syria:سوريا;'
    'Tanzania:تنزانيا;Thailand:تايلاند;Tunisia:تونس;Turkey:تركيا;'
    'USA:الولايات المتحدة;Ukraine:أوكرانيا;United-Arab-Emirates:الإمارات;'
    'Uruguay:أوروغواي;Uzbekistan:أوزبكستان;Venezuela:فنزويلا;Vietnam:فيتنام;'
    'Wales:ويلز;World:العالم;Yemen:اليمن;Zambia:زامبيا';

/// Second block, added at QA (step 5) after measuring which countries actually
/// appear in the live three-day window. Every country below was present in a
/// real `/yesterday`, `/today` or `/tomorrow` payload and was falling back to
/// the English name in Arabic. Kept as a separate literal so the original
/// generated block stays untouched.
const String _kPackedArabicExtra =
    'Slovakia:سلوفاكيا;Bulgaria:بلغاريا;Belarus:بيلاروسيا;'
    'Estonia:إستونيا;Iceland:أيسلندا;Latvia:لاتفيا;Malawi:مالاوي;'
    'Armenia:أرمينيا;Lithuania:ليتوانيا;Georgia:جورجيا;Slovenia:سلوفينيا;'
    'Kazakhstan:كازاخستان;Luxembourg:لوكسمبورغ;Moldova:مولدوفا;'
    'Guatemala:غواتيمالا;El-Salvador:السلفادور;Nicaragua:نيكاراغوا;'
    'Faroe-Islands:جزر فارو;Macedonia:مقدونيا;Bosnia:البوسنة;'
    'Israel:إسرائيل;Montenegro:الجبل الأسود;Liechtenstein:ليختنشتاين;'
    'Kyrgyzstan:قيرغيزستان;'
    // Countries the GOAL API serves that the previous provider did not.
    'Angola:أنغولا;Aruba:أروبا;Azerbaijan:أذربيجان;Botswana:بوتسوانا;'
    'Gibraltar:جبل طارق;Jamaica:جامايكا;Rwanda:رواندا;San-Marino:سان مارينو;'
    'Tajikistan:طاجيكستان;Uganda:أوغندا;Albania:ألبانيا;Cyprus:قبرص;'
    'Liberia:ليبيريا;Malta:مالطا;Mongolia:منغوليا;Singapore:سنغافورة;'
    'Suriname:سورينام';

Map<String, String>? _arabicCache;

Map<String, String> get _arabicNames {
  final Map<String, String>? cached = _arabicCache;
  if (cached != null) return cached;
  final Map<String, String> parsed = <String, String>{};
  for (final String block in <String>[
    _kPackedArabicCountries,
    _kPackedArabicExtra,
  ]) {
    for (final String pair in block.split(';')) {
      final int i = pair.indexOf(':');
      if (i <= 0) continue;
      parsed[pair.substring(0, i)] = pair.substring(i + 1);
    }
  }
  return _arabicCache = parsed;
}

/// Display name for a RAW (hyphenated) API country, in the active language.
/// Falls back silently to the de-hyphenated English name.
String localisedCountryName(String? rawCountry, String languageCode) {
  if (rawCountry == null || rawCountry.isEmpty) return '';
  if (languageCode == 'ar') {
    final String? arabic = _arabicNames[rawCountry];
    if (arabic != null) return arabic;
  }
  return countryDisplayName(rawCountry);
}
