/// Bidirectional-text helpers for API strings.
///
/// Team, competition, venue and referee names arrive from the API in Latin
/// script and are never translated (§9). Dropped raw into an Arabic (RTL)
/// paragraph, their trailing punctuation is reordered by the bidi algorithm —
/// `"San Martin S.J."` renders as `".San Martin S.J"`.
///
/// Wrapping them in a FIRST STRONG ISOLATE (U+2068 … U+2069) makes the run take
/// its direction from its own first strong character and keeps neutrals
/// attached to it, while still letting the surrounding paragraph place the run
/// at the logical start. This is the standard fix and costs two code points.
library;

const String _fsi = '\u2068';
const String _pdi = '\u2069';

/// Isolates a foreign-script string for safe embedding in either direction.
String bidiIsolate(String? text) {
  if (text == null || text.isEmpty) return '';
  return '$_fsi$text$_pdi';
}
