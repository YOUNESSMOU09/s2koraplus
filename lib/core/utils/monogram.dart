/// Team-name -> monogram derivation (C1: the only source of team identity).
///
/// There are no club crests anywhere in this app, so the monogram carries real
/// informational weight. It must be stable, predictable and never empty.
library;

/// Tokens that carry no identity and are dropped before picking initials.
/// Order matters only for readability; lookup is a set.
///
/// `FF` is present although §8.4's written list omits it: the same section's
/// worked example requires `"Lindo FF"` -> `LI`, which is only reachable if
/// `FF` is a stop token. It is the same class of Nordic club suffix as `FK`,
/// `IF`, `BK` and `SK`, all of which the list does include.
const Set<String> kMonogramStopTokens = <String>{
  'FC', 'CF', 'AFC', 'SC', 'AC', 'CD', 'SV', 'FK', 'FF', 'IF', 'BK', 'SK',
  'W', 'WOMEN', 'U17', 'U18', 'U19', 'U20', 'U21', 'U23',
  'II', 'B', 'RESERVE', 'RES',
};

final RegExp _separators = RegExp(r"[\s\-_/.,()]+");
final RegExp _letters = RegExp(r'[A-Za-zÀ-ɏ؀-ۿ0-9]');

/// Derives a 1–2 character monogram from a team name.
///
/// * `"Manchester United"` -> `MU`
/// * `"Lindo FF"` -> `LI`   (only one identity token remains)
/// * `"Viking FK W"` -> `VI`
/// * `"KPV-j"` -> `KP`
String teamMonogram(String rawName) {
  final String name = rawName.trim();
  if (name.isEmpty) return '?';

  final List<String> rawTokens = name
      .split(_separators)
      .where((String t) => t.isNotEmpty)
      .where((String t) => _letters.hasMatch(t))
      .toList(growable: false);
  if (rawTokens.isEmpty) return _firstTwo(name);

  // Single-character fragments carry no identity when a real token exists —
  // this is what makes `"KPV-j"` resolve to `KP` rather than `KJ` (§8.4).
  final List<String> substantial =
      rawTokens.where((String t) => t.length > 1).toList(growable: false);
  final List<String> tokens = substantial.isEmpty ? rawTokens : substantial;

  final List<String> identity = tokens
      .where((String t) => !kMonogramStopTokens.contains(t.toUpperCase()))
      .toList(growable: false);
  final List<String> use = identity.isEmpty ? tokens : identity;

  if (use.length >= 2) {
    return '${_firstLetter(use[0])}${_firstLetter(use[1])}';
  }
  return _firstTwo(use.first);
}

String _firstLetter(String token) {
  for (final int rune in token.runes) {
    final String ch = String.fromCharCode(rune);
    if (_letters.hasMatch(ch)) return ch.toUpperCase();
  }
  return token.isEmpty ? '?' : token[0].toUpperCase();
}

String _firstTwo(String token) {
  final List<String> chars = <String>[];
  for (final int rune in token.runes) {
    final String ch = String.fromCharCode(rune);
    if (_letters.hasMatch(ch)) chars.add(ch.toUpperCase());
    if (chars.length == 2) break;
  }
  if (chars.isEmpty) return '?';
  return chars.join();
}

/// Deterministic palette index for a team, derived from the API's stable
/// `team.id` (never the name, which can change spelling between seasons).
///
/// FNV-1a over the id's code units, kept inside 32 bits — `String.hashCode` is
/// NOT stable across runs, so it cannot be used for a colour that must be the
/// same on every device and in every session.
int teamPaletteIndex(String teamId, {int paletteLength = 12}) {
  int hash = 0x811c9dc5;
  for (final int unit in teamId.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return hash % paletteLength;
}
