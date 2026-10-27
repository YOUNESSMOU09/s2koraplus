/// Search normalisation: Latin diacritic folding + Arabic orthographic folding.
///
/// Used to build the isolate-side search haystacks and to normalise the user's
/// query, so "Malmo" finds "Malmö" and "الاهلي" finds "الأهلي".
library;

const Map<String, String> _latinFolds = <String, String>{
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a', 'ă': 'a', 'ą': 'a',
  'ç': 'c', 'ć': 'c', 'č': 'c', 'ĉ': 'c', 'ċ': 'c',
  'ď': 'd', 'đ': 'd', 'ð': 'd',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ĕ': 'e', 'ė': 'e', 'ę': 'e', 'ě': 'e',
  'ĝ': 'g', 'ğ': 'g', 'ġ': 'g', 'ģ': 'g',
  'ĥ': 'h', 'ħ': 'h',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'ĭ': 'i', 'į': 'i', 'ı': 'i',
  'ĵ': 'j', 'ķ': 'k',
  'ĺ': 'l', 'ļ': 'l', 'ľ': 'l', 'ł': 'l',
  'ñ': 'n', 'ń': 'n', 'ņ': 'n', 'ň': 'n', 'ŋ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o', 'ŏ': 'o', 'ő': 'o',
  'ŕ': 'r', 'ŗ': 'r', 'ř': 'r',
  'ś': 's', 'ŝ': 's', 'ş': 's', 'š': 's', 'ș': 's',
  'ţ': 't', 'ť': 't', 'ŧ': 't', 'ț': 't',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ũ': 'u', 'ū': 'u', 'ŭ': 'u', 'ů': 'u', 'ű': 'u', 'ų': 'u',
  'ŵ': 'w', 'ý': 'y', 'ÿ': 'y', 'ŷ': 'y',
  'ź': 'z', 'ż': 'z', 'ž': 'z',
  'æ': 'ae', 'œ': 'oe', 'ß': 'ss', 'þ': 'th',
};

const Map<String, String> _arabicFolds = <String, String>{
  'أ': 'ا', // alef with hamza above -> alef
  'إ': 'ا', // alef with hamza below -> alef
  'آ': 'ا', // alef with madda -> alef
  'ٱ': 'ا', // alef wasla -> alef
  'ى': 'ي', // alef maksura -> yeh
  'ة': 'ه', // teh marbuta -> heh
  'ؤ': 'و', // waw with hamza -> waw
  'ئ': 'ي', // yeh with hamza -> yeh
  'ـ': '', // tatweel -> removed
};

/// Arabic combining marks (harakat) — stripped entirely.
final RegExp _arabicDiacritics = RegExp('[ً-ٰٟۖ-ۭ]');
final RegExp _nonSearchable = RegExp(r'[^\p{L}\p{N}| ]', unicode: true);
final RegExp _collapseSpace = RegExp(r'\s+');

/// Folds a string into its searchable form. Idempotent.
String normaliseForSearch(String input) {
  if (input.isEmpty) return '';
  final String lower = input.toLowerCase().replaceAll(_arabicDiacritics, '');
  final StringBuffer out = StringBuffer();
  for (final int rune in lower.runes) {
    final String ch = String.fromCharCode(rune);
    final String? latin = _latinFolds[ch];
    if (latin != null) {
      out.write(latin);
      continue;
    }
    final String? arabic = _arabicFolds[ch];
    if (arabic != null) {
      out.write(arabic);
      continue;
    }
    out.write(ch);
  }
  return out
      .toString()
      .replaceAll('-', ' ')
      .replaceAll(_nonSearchable, ' ')
      .replaceAll(_collapseSpace, ' ')
      .trim();
}
