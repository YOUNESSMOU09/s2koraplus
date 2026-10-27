/// Crest image URLs, keyed by GOAL id.
///
/// GOAL ids are opaque cuids, so a crest URL cannot be derived from an id the
/// way the old provider's could. Instead every parsed fixture records its
/// team badges and league logo here, and widgets that only hold an id (team
/// badges, followed teams, journal headers) look the URL up. An id this
/// process has not seen yet simply has no crest, and the monogram or emoji
/// flag shows instead — exactly the offline fallback the widgets already have.
library;

final Map<String, String> _teamCrests = <String, String>{};
final Map<String, String> _leagueLogos = <String, String>{};

/// Records URLs as data arrives. Empty or non-http values are ignored.
void recordCrests({String? teamId, String? teamLogo, String? leagueId, String? leagueLogo}) {
  if (teamId != null && _usable(teamLogo)) _teamCrests[teamId] = teamLogo!;
  if (leagueId != null && _usable(leagueLogo)) _leagueLogos[leagueId] = leagueLogo!;
}

bool _usable(String? url) => url != null && url.startsWith('http');

String? teamCrestUrl(String teamId) => _teamCrests[teamId];

String? leagueCrestUrl(String leagueId) => _leagueLogos[leagueId];

/// Test-only reset.
void clearCrestsForTest() {
  _teamCrests.clear();
  _leagueLogos.clear();
}
