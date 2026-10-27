// GENERATED DATA — do not hand-edit the packed table below.
//
// Source: the live `/api/football/leagues` payload (997 competitions), probed
// 2026-08-09. See ../../../../API_CONTRACT.md. Regenerate from that payload if
// the backend's country vocabulary ever changes.
//
// Why a packed string instead of a map literal: 156 entries as a Dart map is a
// large source block; packed it is a fraction of the size and parses once,
// lazily, on first lookup.
//
// Keys are the API's RAW country names, which are HYPHENATED
// ("Saudi-Arabia", "Costa-Rica", "Congo-DR"). Never render a key directly —
// use [countryDisplayName] for anything user-visible. See API_CONTRACT.md
// Addendum, Trap A.

/// `Name:CC` pairs separated by `;`. Codes are ISO 3166-1 alpha-2, except the
/// four UK subdivisions, which the API reports as ISO 3166-2 (`GB-ENG` etc).
///
/// `Palestine:PS` and `Yemen:YE` were added by hand: `country_names.dart`
/// carries Arabic names for both, but neither appears in the backend's current
/// `/leagues` country vocabulary, so the generator never emitted a code for
/// them. Nothing renders them today — this is insurance, not a live fix. If
/// API-Football widens coverage they will show their own flag rather than the
/// unknown globe, which matters because this is a MENA-lean app and the atlas
/// makes the flag primary content. Pinned by `test/core/country_test.dart`.
const String _kPackedCountryCodes =
    'Albania:AL;Algeria:DZ;Andorra:AD;Angola:AO;Antigua-And-Barbuda:AG;Argentina:AR;'
    'Armenia:AM;Aruba:AW;Australia:AU;Austria:AT;Azerbaijan:AZ;Bahrain:BH;Bangladesh:BD;'
    'Belarus:BY;Belgium:BE;Belize:BZ;Benin:BJ;Bhutan:BT;Bolivia:BO;Bosnia:BA;Botswana:BW;'
    'Brazil:BR;Bulgaria:BG;Burkina-Faso:BF;Burundi:BI;Cambodia:KH;Cameroon:CM;Canada:CA;'
    'Chile:CL;China:CN;Chinese-Taipei:TW;Colombia:CO;Congo:CD;Congo-DR:CG;Costa-Rica:CR;'
    'Croatia:HR;Cuba:CU;Cyprus:CY;Czech-Republic:CZ;Denmark:DK;Dominican-Republic:DO;'
    'Ecuador:EC;Egypt:EG;El-Salvador:SV;England:GB-ENG;Estonia:EE;Eswatini:SZ;Ethiopia:ET;'
    'Faroe-Islands:FO;Fiji:FJ;Finland:FI;France:FR;Gabon:GA;Gambia:GM;Georgia:GE;Germany:DE;'
    'Ghana:GH;Gibraltar:GI;Greece:GR;Grenada:GD;Guatemala:GT;Guinea:GN;Haiti:HT;Honduras:HN;'
    'Hong-Kong:HK;Hungary:HU;Iceland:IS;India:IN;Indonesia:ID;Iran:IR;Iraq:IQ;Ireland:IE;'
    'Israel:IL;Italy:IT;Ivory-Coast:CI;Jamaica:JM;Japan:JP;Jordan:JO;Kazakhstan:KZ;Kenya:KE;'
    'Kosovo:XK;Kuwait:KW;Kyrgyzstan:KG;Laos:LA;Latvia:LV;Lebanon:LB;Lesotho:LS;Liberia:LR;'
    'Libya:LY;Liechtenstein:LI;Lithuania:LT;Luxembourg:LU;Macao:MO;Macedonia:MK;Malawi:MW;'
    'Malaysia:MY;Mali:ML;Malta:MT;Mauritania:MR;Mexico:MX;Moldova:MD;Mongolia:MN;'
    'Montenegro:ME;Morocco:MA;Myanmar:MM;Netherlands:NL;New-Zealand:NZ;Nicaragua:NI;'
    'Nigeria:NG;Northern-Ireland:GB-NIR;Norway:NO;Oman:OM;Palestine:PS;Panama:PA;'
    'Paraguay:PY;Peru:PE;'
    'Philippines:PH;Poland:PL;Portugal:PT;Qatar:QA;Romania:RO;Russia:RU;Rwanda:RW;'
    'San-Marino:SM;Saudi-Arabia:SA;Scotland:GB-SCT;Senegal:SN;Serbia:RS;Singapore:SG;'
    'Slovakia:SK;Slovenia:SI;South-Africa:ZA;South-Korea:KR;Spain:ES;Sudan:SD;Suriname:SR;'
    'Sweden:SE;Switzerland:CH;Syria:SY;Tajikistan:TJ;Tanzania:TZ;Thailand:TH;'
    'Trinidad-And-Tobago:TT;Tunisia:TN;Turkey:TR;Turkmenistan:TM;USA:US;Uganda:UG;Ukraine:UA;'
    'United-Arab-Emirates:AE;Uruguay:UY;Uzbekistan:UZ;Venezuela:VE;Vietnam:VN;Wales:GB-WLS;'
    'Yemen:YE;Zambia:ZM;Zimbabwe:ZW';

/// Corrections for known-wrong codes in the upstream API-Football data.
///
/// Verified 2026-08-09 against the live `/leagues` payload: the two Congos are
/// swapped at the source — it reports "Congo" as `CD` (which is DR Congo's
/// code) and "Congo-DR" as `CG` (the Republic of Congo's). Left uncorrected,
/// both countries render the other's flag.
const Map<String, String> _kCodeCorrections = {
  'Congo': 'CG',
  'Congo-DR': 'CD',
};

Map<String, String>? _codeCache;

Map<String, String> get _codes {
  final cached = _codeCache;
  if (cached != null) return cached;
  final map = <String, String>{};
  for (final entry in _kPackedCountryCodes.split(';')) {
    final i = entry.indexOf(':');
    if (i > 0) map[entry.substring(0, i)] = entry.substring(i + 1);
  }
  return _codeCache = map;
}

/// Globe fallback for international competitions (Champions League, AFCON,
/// World Cup qualifiers, club friendlies). The API reports these as country
/// "World" with a null code — 98 of 997 competitions.
const String kWorldFlag = '\u{1F30D}';

/// Shown when a country is present but unmapped. Never leave a blank tile.
const String kUnknownFlag = '\u{1F310}';

String _regionalIndicator(String cc) => String.fromCharCodes([
      0x1F1E6 + cc.codeUnitAt(0) - 0x41,
      0x1F1E6 + cc.codeUnitAt(1) - 0x41,
    ]);

/// Tag-sequence flag, e.g. `gbeng` -> the England flag.
String _subdivisionFlag(String subtag) => String.fromCharCodes([
      0x1F3F4,
      ...subtag.runes.map((r) => 0xE0000 + r),
      0xE007F,
    ]);

/// Emoji flag for a RAW (hyphenated) API country name.
///
/// Zero network requests, zero SVG, zero trademark exposure — this is the
/// replacement for the API's `.svg` flag URLs, which `cached_network_image`
/// cannot render anyway (API_CONTRACT.md, R8).
String countryFlagEmoji(String? rawCountry) {
  if (rawCountry == null || rawCountry.isEmpty) return kUnknownFlag;
  if (rawCountry == 'World') return kWorldFlag;

  final code = _kCodeCorrections[rawCountry] ?? _codes[rawCountry];
  if (code == null) return kUnknownFlag;

  // Northern Ireland has no reliably-rendering emoji flag on iOS, so it falls
  // back to the Union Flag rather than showing tofu.
  if (code == 'GB-NIR') return _regionalIndicator('GB');

  if (code.length == 2) return _regionalIndicator(code);
  if (code.startsWith('GB-')) {
    return _subdivisionFlag(code.toLowerCase().replaceAll('-', ''));
  }
  return kUnknownFlag;
}

/// Human-readable country name.
///
/// The API returns hyphenated names; rendering them raw ships "Saudi-Arabia"
/// and "Costa-Rica" into the UI. Always use this for display, and keep the raw
/// value as the lookup/join key.
String countryDisplayName(String? rawCountry) =>
    (rawCountry == null || rawCountry.isEmpty)
        ? ''
        : rawCountry.replaceAll('-', ' ');
