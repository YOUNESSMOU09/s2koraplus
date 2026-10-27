# Marma

**A bright, gambling-free football scoreboard for the current three days.**
Every match being played yesterday, today and tomorrow — across 900+
competitions, in English or Arabic — with live minutes and goals, and nothing
else: no betting odds, no news feed, no video, no account.

* Bundle ID: `com.koorapulse.app` · Flutter package: `marma`
* Min iOS: 15.0 · Flutter 3.44 / Dart 3.12 · Material 3
* Implements `../02_project.md` (the single source of truth). Anything not in
  that document is out of scope.

---

## Run it

```bash
flutter pub get
flutter gen-l10n              # only needed if you edit lib/l10n/*.arb
flutter run -d <ios-simulator-id>
```

Quality gates:

```bash
flutter analyze               # must be 0 issues
flutter test                  # must be all green
```

No `.env`, no Firebase config, no `build_runner`. The GOAL API key is built in
(see Backend below — and its security note).

---

## Architecture

```
lib/
  app/          AppEnv, GoRouter, MaterialApp.router
  core/         failures, formatting, monogram, country flags, bidi, search normalisation
  data/         dio client · hand-written DTOs · isolate parsing · prefs + file cache · repositories
  domain/       immutable entities · repository interfaces · pure services
  presentation/ theme tokens · Riverpod providers · widgets · screens
  l10n/         app_en.arb, app_ar.arb, generated delegates, country names
```

`presentation → domain ← data`. `domain` imports no Flutter widget library and
nothing from `data`. Everything under `data/parsing/` is top-level functions
over plain data so it can cross an isolate boundary.

**State:** Riverpod 2 with hand-written providers — no `riverpod_generator`, no
`build_runner`. **Serialisation:** hand-written `fromJson`/`toJson` — no
`json_serializable`. Both are deliberate: the provider graph is small, and the
API needs null-tolerance and field-*dropping* that codegen would fight.

### Backend — the GOAL API

`https://api.goal-api.com/v1` via the `goal_api` package (one shared `GoalApi`,
wrapped by `data/remote/goal_source.dart`). Overridable with
`--dart-define=MARMA_API_BASE=…`; the key with `--dart-define=MARMA_API_KEY=…`.

> **Security, known and not fixed:** the API key ships inside the app binary,
> so it is effectively public — anyone can extract it and spend the plan's
> quota. The fix is a small proxy the app calls instead of GOAL directly.

What is called, and when:

| Data | Endpoint | When | Cached |
|---|---|---|---|
| A day | `/fixtures/date/{YYYY-MM-DD}`, paged 100/page, capped at 12 pages | today at launch; yesterday/tomorrow when their tab opens | file, TTL 10 min / 6 h / 1 h, refresh floored at 2–10 min |
| Live | `/fixtures/live` (1 request) | every 60 s while Live or Following is on screen | file; 20 s floor; 5 min gap once < 50 requests remain |
| Competition catalog | `/leagues?isActive=true` (~11 requests) | only when search opens | 7 days |
| Standings | `/standings/{leagueId}` | on demand (`standingsProvider`) | 6 h |
| Squad | `/teams/{id}/players` | on demand (`squadProvider`) | 24 h |
| Status | `/public/status` (no key) | About screen | — |

Budget: the plan is treated as **1000 requests/day** (the API's own
`X-RateLimit-Limit` header reported 1,000,000/day on 2026-10-27). A cold start
costs about 5 requests; an hour on the Live tab about 60.

Shape notes, all verified against production on 2026-10-27:

* Ids are string cuids. Every model id is a `String`.
* Scores and counts are strings (`"0"`, `"43"`); null means not played.
* `matchStatus` is an enum; `goalStatus()` maps it onto the short codes the UI
  already used (`SCHEDULED`→`NS`, `LIVE`+`FIRST_HALF`→`1H`, `AFTER_PEN`→`PEN`…).
* `kickoffUtc` **is real UTC**: on 20/20 live matches the reported minute only
  fits that reading. It is *not* a Europe/Berlin wall clock.
* REST carries the live minute (`matchElapsed`/`matchExtra`/`matchMinute`), so
  no WebSocket is needed for it.
* Standings have no goal-difference field (computed GF − GA) and are sorted
  client-side by `overallLeaguePosition`.
* `/teams/{id}/players` includes coaching staff with nothing marking them;
  rows with no position, number, age or birthdate are dropped as staff.
* Country names are mapped onto the flag / Arabic-name keys (`Korea Republic`
  → `South-Korea`, `intl` / `eurocups` → `World`…); all 101 countries in three
  real days resolve.

### Performance

A busy day is ~500 rows / ~90 KB gzipped (captures in `test/qa/live_capture/`).

* The SDK decodes JSON; `Isolate.run` maps, groups, sorts and builds the search
  index off the UI thread.
* `CustomScrollView` + `SliverList.builder`; no eagerly built lists.
* `MatchRow` watches `resolvedFixtureProvider(id)`, so a poll that changes one
  score rebuilds one row.
* Badges and league logos come from the data (`core/utils/crest_url.dart`
  records them by id) and are disk-cached by `cached_network_image`; the
  monogram or emoji flag shows until they load, and offline.

### The `/live` timer

A pending `Timer` firing after teardown crashed a previous app in this studio.
`LivePoller` therefore only runs while the app is **foreground** *and* the Live
or Following branch is on screen, cancels in `ref.onDispose`, guards every async
continuation with a `_disposed` flag, and never starts under a headless test.

### Offline

Parsed buckets are persisted to
`<ApplicationSupport>/marma_cache_v1/{today,yesterday,tomorrow,live}.json`
(atomic write, corrupt file = cache miss, never a crash) and painted on cold
start before any network call. Revalidation is conditional (`If-None-Match`);
a `304` updates only the freshness stamp. Every list surface carries an
"Updated N min ago" chip and a designed offline / empty / error state.
**The app demos with the backend switched off.**

---

## Design system — "Pitch"

A bright, modern sports scoreboard: white cards with a soft shadow on a cool
grey canvas, one strong blue accent, red for live, club crests front and
centre. Light is the hero theme; dark mode is deep navy with hairline borders
instead of shadows. Match rows are centred — home · score · away — and the
match detail opens on a blue gradient hero card.

* `presentation/theme/app_colors.dart` — explicit light + dark palettes and a
  high-contrast variant, exposed as a `ThemeExtension`; `colors.card()` is the
  one card decoration.
* `app_typography.dart` — **Sora** (display) × **IBM Plex Sans Arabic** (body,
  both locales) × **IBM Plex Mono** (every aligning numeral). Fonts are
  **bundled** under `assets/google_fonts/` and
  `GoogleFonts.config.allowRuntimeFetching = false` is set in `main()` before
  `runApp`, so the app never fetches a font.
* Team and league crests load from `media.goal-api.com`, using the URLs the
  data carries (recorded by id in `core/utils/crest_url.dart`), and are
  disk-cached. A monogram + a hue derived from `team.id` (or the country's
  emoji flag, for leagues) draws while a crest loads and whenever it fails.
  Country flags stay Unicode emoji.
* Motion goes through `AppMotion.enabled(context)`, which is false under Reduce
  Motion and under test — infinite animations never leave a controller pending.

### RTL

`EdgeInsetsDirectional` / `AlignmentDirectional` / `PositionedDirectional`
throughout; no `EdgeInsets.only(left:)`. The scoreline is three widgets, never
the string `"2 - 1"`. Latin team and competition names are wrapped in a
first-strong isolate (`core/utils/bidi.dart`) so trailing punctuation does not
migrate in an Arabic paragraph. Minute badges and clock times are forced LTR.

---

## Localisation

`flutter gen-l10n` from `lib/l10n/app_en.arb` and `app_ar.arb` — 207 strings
each, no hard-coded English in any widget. Country names are localised
(`lib/l10n/country_names.dart`); **team and competition names are not
translated** — the API returns Latin script only and transliterating it would
invent data. Numerals are Latin in both locales (`AppFormat`), because IBM Plex
Mono carries no Arabic-Indic figures and every major Arabic football app uses
Latin score digits.

---

## Privacy

No account, no login, no user identifier, no analytics, no ads in v1. Favourites,
settings, journals and cached scores live only in app-private storage and are
deleted with the app. The app sends no notifications and asks for no
notification permission; there is no push infrastructure and no device token.
The only score requests go to the GOAL API, with no user-identifying data
(the API key is the same on every install).

`AnalyticsSink`/`NoopAnalytics` and a single `AdSlot` (currently
`SizedBox.shrink()`, reserved at the bottom of `/matches` only) exist as seams
for pipeline step 6. Wiring either changes the privacy nutrition label.

---

## Development seams

`--dart-define=MARMA_DEV_ROUTE=/live` forces the router's initial location and
treats the splash and onboarding gates as satisfied. It is empty in every real
build. It exists only because the iOS Simulator exposes no scripted tap API, so
QA screenshots of inner routes cannot otherwise be captured.

`--dart-define=MARMA_TEST=true` (or `AppEnv.forceTestMode = true`) disables the
5 s splash hold and all animation.

---

## Assets

* `assets/google_fonts/` — the eight bundled `.ttf` faces.
* `assets/branding/splash_mark*.png` — generated floodlight mark for
  `flutter_native_splash`.
* `assets/icon/icon.png` — **placeholder**. Pipeline step 10 replaces it with
  the final artwork and re-runs `dart run flutter_launcher_icons`.

Regenerate native chrome after changing either:

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

---

## Attribution

> Data provided by GOAL API (goal-api.com).

> Marma is not affiliated with, endorsed by, or connected to any football club,
> league, federation or governing body. Scores may be delayed and are unofficial.
