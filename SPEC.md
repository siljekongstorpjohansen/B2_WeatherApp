# SPEC.md — B2 Weather App

> Living requirements document + AI control file. Read at the start of every AI session; update at the end (§10).

## 1. AI meta-instructions

> **AI: read this first.**

- Read `SPEC.md`, `STYLE.md` and `CONTEXT.md` first. If they conflict with my request, point it out — I decide.
- I must be able to explain every line. Follow the code tiers in `STYLE.md` §2: propose first, write code only after my OK, explain every part, then ask one explain-back question. Hint ladder only when I ask.
- **Never** tick requirements, write test results, `docs/LLM_PROCESS.md` or `docs/REFLECTION.md`.
- After each finished step (not after every prompt), remind whoever is working to log it in `docs/LLM_PROCESS.md`, and list the raw facts in chat: task given, what the AI produced, what was kept/changed, AI mistakes. The human writes the entry.
- Spec before code: a component needs an entry in §6 before it is implemented.
- No new tests, files, dependencies or features without my approval. Apple SDK only.
- All code, comments and docs in English. Link changes to requirement IDs (`W-xx`).
- Final build uses the real APIs, not test servers.
- **Remind me of the end-of-session ritual (§10) when the session ends.**

## 2. Project facts

| | |
| - | - |
| Course / Lab | CM2023 · Lab B:2 — Native Weather App · grade target **A / VG** |
| Platform | iOS (iPhone + iPad) · Swift / SwiftUI · Xcode |
| APIs | Forecast: [Open-Meteo](https://open-meteo.com/en/docs) · Geocoding: `geocode.maps.co/search?q={place}` |
| Stack | `URLSession` async/await · `Codable` DTOs · `NWPathMonitor` · local cache (see Q2) · MVVM + Repository |
| Docs | `README.md` (B) · `SPEC.md` (C) · `docs/TEST_REPORT.md` (A) · `docs/LLM_PROCESS.md` (D) · `docs/REFLECTION.md` |

## 3. Requirements

☐ not started · ◐ in progress · ☑ done (and I can explain it)

| ID | Requirement | ✓ |
| -- | ----------- | - |
| **Basic** | | |
| W-01 | Show forecast for the location the user requests | ☐ |
| W-02 | Search/home screen: city or coordinates → current conditions + 7-day summary | ☐ |
| W-03 | Detail screen for a selected day: temp, condition, wind, precipitation, … | ☐ |
| W-04 | Mark places as favourites | ☐ |
| W-05 | Favourites quick-access view | ☐ |
| W-06 | Settings screen: refresh rate + UI preferences | ☐ |
| **Detailed** | | |
| W-10 | Forecast data from Open-Meteo | ☐ |
| W-11 | Place name → coordinates via geocode.maps.co | ☐ |
| W-12 | Next 7 days: temperature + visual condition (icon/colour/text) | ☐ |
| W-13 | Hourly detail for today, daily overview for remaining days | ☐ |
| W-14 | Input accepts city name **or** coordinates | ☐ |
| W-15 | Coordinates accept only valid floats (lat ±90, lon ±180) | ☐ |
| W-16 | Parsed data stored locally | ☐ |
| W-17 | Offline: no crash, clear message, show last fetched data | ☐ |
| W-18 | Works in portrait and landscape | ☐ |
| W-19 | Separate type for parsing JSON into the model | ☐ |
| W-20 | Forecast shown in a scrollable list | ☐ |
| W-21 | Network requests off the main thread | ☐ |
| W-22 | All errors handled — no crash, no blank screen | ☐ |
| W-23 | Passing tests for ≥ 2 of: parsing, error-state logic, data transformation | ☐ |
| W-24 | ≥ 20 UX scenarios in test report (start state, action, expected) | ☐ |
| W-25 | Tested on Simulator or device (not browser) | ☐ |
| W-26 | AI usage documented (§11) | ☐ |
| W-27 | Final build uses real APIs | ☐ |
| **Higher (A/VG)** | | |
| W-30 | Distinct layers: networking, transformation, state, UI; deliberate naming | ☐ |
| W-31 | Architecture understandable from docs before opening Xcode | ☐ |
| W-32 | Designed UI: clear hierarchy, consistent spacing and visual language | ☐ |
| W-33 | Designed loading, empty and error states | ☐ |
| W-34 | Edge cases: slow network, rapid searches, no results | ☐ |
| W-35 | Oral exam questions mapped to code (§9) | ☐ |
| W-36 | Update log kept every session (§12) | ☐ |
| **Submission** | | |
| W-40 | Reflection report (~½ page) — written by me | ☐ |
| W-41 | Appendices A–D complete | ☐ |
| W-42 | Submitted ≥ 1 day before presentation | ☐ |

## 4. Architecture

```
View  ──intent──▶  ViewModel  ──▶  WeatherRepository  ──▶  Services (HTTP) / Cache
  ▲                    │                   │
  └──── observed state ┘                   └──▶  Parser: DTO → Model
```

- **View** — renders state, owns navigation. No networking or parsing.
- **ViewModel** — screen state (idle / loading / loaded / failed), cancels stale requests.
- **Repository** — chooses network vs. cache; hides HTTP and storage.
- **Parser** — DTO → domain model; the UI never sees API types.

Folder layout and layer rules: `STYLE.md` §3–4.

## 5. Plan

| # | Step | IDs | ✓ |
| - | ---- | --- | - |
| 1 | Inspect API JSON, save fixtures | W-10, W-11 | ☐ |
| 2 | `STYLE.md`, `CONTEXT.md`, review §6 | W-30 | ☐ |
| 3 | Xcode project + folder structure | W-30 | ☐ |
| 3b | skeleton: real Open-Meteo 7-day forecast for fixed Stockholm through all layers except the UI | W-10, W-12, W-19, W-21, W-30 | ☐ |
| 4 | Model + `ForecastParser` + tests | W-19, W-23 | ☐ |
| 5 | Services, repository, cache, connectivity | W-10, W-11, W-16, W-21 | ☐ |
| 6 | ViewModels + error-state tests | W-22, W-23, W-34 | ☐ |
| 7 | Search + detail screens | W-02, W-03, W-12, W-13, W-20 | ☐ |
| 8 | Favourites + settings | W-04–W-06 | ☐ |
| 9 | UI states, orientation, iPad | W-18, W-32, W-33 | ☐ |
| 10 | Test report, README, final docs | W-24, W-40–W-42 | ☐ |

## 6. Component specs (draft — fill in before coding)

| Component | Purpose | Edge cases | IDs |
| --------- | ------- | ---------- | --- |
| `GeocodingService` | Place name → `[Place]` | Empty query, no results, å/ä/ö, 401/429, timeout | W-11, W-14 |
| `ForecastService` | Fetch Open-Meteo JSON for lat/lon → `OpenMeteoResponse`; runs off the main actor (`@concurrent`); throws only `NetworkError` | Offline, timeout, 4xx/5xx, 200 with bad JSON | W-10, W-21 |
| `NetworkError` | Classify every request failure: offline, timeout, cancelled, HTTP status (+ API `reason`), decoding, unknown | `URLError` codes, `CancellationError`, HTTP 400 body | W-22, W-34 |
| `ForecastParser` | DTO → `Forecast` (current, hourly today, 7 days) | Mismatched array lengths, missing fields, unknown weather code, time zones | W-13, W-19 |
| `ForecastCache` | Store last forecast + timestamp | First launch, corrupt data, stale data | W-16, W-17 |
| `CoordinateValidator` | Coordinates or place name? Validate range | Comma decimals, out of range, single number | W-14, W-15 |
| `ForecastViewModel` | Search → geocode → fetch → state. **Interface for views:** `state: State` (`.idle` · `.loading` · `.loaded(ForecastDisplay)` · `.failed(message: String)`), `init(repository:now:)`, `func search(_ query: String) async` (cancels the previous search) | Rapid searches, offline ± cache, refresh, no results (→ `.failed` for now) | W-02, W-17, W-22, W-34 |
| `ForecastDisplay` | Pure `Forecast` → screen data: `conditions` / `hours` / `days` mirror `CurrentConditionsView.Conditions`, `HourlyStripView.Hour`, `DailyForecastListView.Day` field by field; next 24 h from the current hour (`isNow`), `isToday` in the place's time zone, today's high/low, wind m/s → km/h | No day matches today (old data), fewer than 24 hours left | W-12, W-13, W-23 |
| `FavouritesStore` / `SettingsStore` | Persist favourites and preferences | — | W-04–W-06 |
| `Place` | Name + latitude/longitude | Non-ASCII names (å/ä/ö) | W-01, W-14 |
| `Forecast` / `DayForecast` / `HourForecast` | Place, time zone, current conditions, all hours (time, °C, condition, precipitation %), 7 days (date, min/max °C, condition, precipitation, max wind m/s) | Fewer than 7 days; local dates | W-12, W-13, W-19 |
| `WeatherCondition` | WMO code → text + SF Symbol (outlined variants), in one place | Unknown code → `.unknown` | W-12 |
| `OpenMeteoResponse` / `OpenMeteoErrorResponse` | Decodable mirror of the Open-Meteo JSON (`current`, `hourly`, `daily`) / HTTP 400 body `{error, reason}` | snake_case keys, missing fields, `null` | W-19, W-22 |
| `WeatherRepository` · `LiveWeatherRepository` · `FakeWeatherRepository` | One entry point for ViewModels: `searchPlaces(matching:)`, `forecast(for:)`, both `throws(NetworkError)`. Live = service + parser, off the main actor (search fixed to Stockholm until API key); Fake = canned results/errors for tests and previews | `ParseError` → `.decoding`; network errors pass through (no cache yet) | W-22, W-23, W-30 |
| `FavouritesViewModel` / `SettingsViewModel` | Empty placeholders | — | W-04–W-06 |

### Screen: `SearchView` (start screen) — W-02, W-04, W-05, W-12–W-15, W-17, W-18, W-20, W-33

Layout, top to bottom:

1. **Search field** — one field for city or `lat, lon` (placeholder `City or 59.33, 18.07`); `CoordinateValidator` decides which.
2. **Favourite chips** — horizontal row, tap to switch place.
3. **Current conditions** — place name + ★ toggle, large temperature, condition icon/text, high/low, wind, "Updated HH:mm".
4. **Today** — horizontal hourly strip (next 24 h from `hourly`).
5. **7 days** — scrollable list: day, icon, min–max bar, chevron → `DayDetailView`.
6. **Tab bar** — Weather · Favourites · Settings.

| State | What the user sees |
| ----- | ------------------ |
| First launch | Search field + "Find your weather — search for a city or enter coordinates." |
| Loading | Previous data dimmed + spinner (never a blank screen) |
| Loaded | Full layout above |
| Offline, cached | Yellow banner "You're offline. Showing data from HH:mm." above cached forecast |
| Error, no cache | "Couldn't load the forecast" + "Try again" button |
| No search results | "No places found for '…'" under the search field |

Landscape / iPad: current conditions on the left, hourly + 7-day list on the right.

**Test ideas:** valid fixture → 7 days · missing field → error · `"59.33, 18.06"` valid · `"91, 0"` invalid · empty geocode result → "no results" state.

## 7. Open questions

1. Where to keep the geocode.maps.co API key out of git (`.xcconfig` in `.gitignore`?)
2. Persistence: `UserDefaults` + JSON or SwiftData?
3. Which UI preferences in settings (units, theme, …)?
4. Refresh rate: timer while visible, or refresh on open when cache is older than N min?
5. ~~Minimum iOS version?~~ → **iOS 17.0** (§8, 2026-11-20)
6. Which Open-Meteo fields to use — and which to ignore (oral Q3)?
7. Move the repo out of iCloud-synced `~/Documents`? (iCloud offloads `.git` files → push fails)

## 8. Decision log

| Date | Decision | Alternatives | Reason | IDs |
| ---- | -------- | ------------ | ------ | --- |
| 2026-11-13 | iOS, Swift/SwiftUI | Android, React Native | Choosen because both team members have iphone and Mac | — |
| 2026-11-13 | Open-Meteo + geocode.maps.co | SMHI | Get more data to work  | W-10, W-11 |
| 2026-11-13 | MVVM + Repository, no packages | — | Course recommendation; testable layers | W-30 |
| 2026-11-20 | Minimum iOS 17.0 | iOS 27.2 (Xcode default) | Lowest version with `@Observable` (`STYLE.md` §5); runs on more devices | W-25 |
| 2026-11-20 | Swift Testing for unit tests, XCTest for UI tests | XCTest only | Xcode default; clearer `#expect` syntax; settles `STYLE.md` §7 | W-23 |
| 2026-11-20 | Xcode project at repo root (no extra `WeatherApp/` level) | Xcode's default nested folder | Matches `STYLE.md` §3; shorter paths | W-30, W-31 |
| 2026-11-20 | Empty layer folders tracked with `.gitkeep`, excluded from build (`EXCLUDED_SOURCE_FILE_NAMES`) | No placeholders | Both of us get the full layout from git; Xcode 27 synced folders otherwise copy `.gitkeep` into the app and the build fails | W-30 |
| 2026-11-20 | App entry struct named `WeatherApp` (same as module) | `WeatherAppApp` (Xcode default) | Matches `STYLE.md` §3; trade-off: `WeatherApp.X` module qualification no longer works | W-30 |
| 2026-11-20 | `docs/LLM_PROCESS.md` written by us; AI only reminds + lists facts | AI drafts, we approve | Lab PDF p. 8: "The AI must NEVER write this file" | W-26 |
| 2026-11-23 | Core tier: AI writes after my approval and explains part by part; hint ladder only on request | I write Core myself via the hint ladder | Streamlines production and mirrors how an LLM is used in a real production setting; learning still happens when AI-generated code is reviewed, approved and guided by the developer | W-26 |
| 2026-11-23 | Skeleton first | Finish each layer fully before the next | Proves the architecture end to end early; every later step plugs into working code | W-30 |
| 2026-11-23 | Wind speed stored in m/s; km/h only as a display setting (W-06) | km/h (Open-Meteo default) | m/s is the Swedish convention | W-06, W-12 |
| 2026-11-23 | `WeatherCondition` keeps WMO intensity (light / moderate / heavy) | One case per type, no intensity | Easy to add now; more precise text and icons | W-12 |
| 2026-11-23 | Request Open-Meteo default units (km/h); parser converts wind to m/s | Request `wind_speed_unit=ms` | Live request matches the shared fixture; conversion is a testable data transformation | W-12, W-23 |
| 2026-11-23 | Hourly data included in the skeleton | Add hourly later | UI branch already shows an hourly strip; same zip pattern as daily | W-13 |
| 2026-11-23 | ViewModel exposes display structs in `ViewModel/` that mirror the UI branch's view types field by field | ViewModel returns the view types directly | Keeps dependencies one-way (View → ViewModel); tests need no SwiftUI types | W-30 |
| 2026-11-23 | Outlined SF Symbols for clouds | `.fill` variants | `.fill` clouds disappear on light backgrounds with `.multicolor` (UI branch) | W-32 |
| 2026-11-23 | Full `NetworkError` classification now, via typed throws | Let `URLError`/`DecodingError` pass through until later | Callers handle one known set of cases; compiler enforces it | W-22 |
| 2026-11-23 | `ForecastService.fetchForecast` is `@concurrent` | Plain `async` (runs on the caller's actor) | With approachable concurrency, plain `async` would decode JSON on the main actor | W-21 |
| 2026-11-23 | Fixed Stockholm as search result until the API key is set up | Real geocoding now | geocode.maps.co needs a key kept out of git (§7 #1); unblocks the forecast path | W-11 |
| 2026-11-23 | Repository throws only `NetworkError`; `ParseError` becomes `.decoding` | Untyped `throws` (ViewModel checks both types) | One error type for the ViewModel; bad data means the same to the user either way | W-22 |
| 2026-11-23 | Real API proven by an opt-in live test (`LiveWeatherRepositoryTests`, runs only with `LIVE_API_TESTS=1`) | Temporary console print in `WeatherApp.swift` | No app file touched (no conflict with the UI branch); repeatable before submission; normal runs stay offline | W-10, W-27 |
| 2026-11-23 | Start screen = search + current + hourly + 7-day on one screen, tab bar for Favourites/Settings (§6) | Separate search screen before forecast | _fill in_ | W-02, W-05, W-33 |
| 2026-11-23 | Personal signing settings (`DEVELOPMENT_TEAM`, bundle ID) stay local, not committed | Commit one person's settings | Committing one person's team ID breaks signing for the other | W-25 |

## 9. Oral exam map

Opening question is always **Q26**. Fill in code location + test as components are done.

| Q | Topic | IDs | Code / test |
| - | ----- | --- | ----------- |
| 1 | Function making the API request | W-10 | |
| 2 | JSON parsing code | W-19 | |
| 3 | Fields used / ignored | W-12 | |
| 4 | HTTP 200 but missing field | W-22 | |
| 5 | Data flow: search → screen | W-01 | |
| 6 | Caching: what, when refreshed | W-16 | |
| 7 | Where data lives at runtime | W-30 | |
| 8 | Displayed data on new search | W-02 | |
| 9 | How UI learns of new data | W-30 | |
| 10 | State kept after leaving app | W-16 | |
| 11 | Loading state, no stale data | W-33 | |
| 12 | Rapid searches / race condition | W-34 | |
| 13 | Network timeout | W-22 | |
| 14 | Network vs. API error | W-22 | |
| 15 | Offline, first launch | W-17 | |
| 16 | Offline, with cache | W-17 | |
| 17 | Error state → UI | W-33 | |
| 18 | Hardest error case | W-22 | |
| 19 | MVVM layers | W-30 | |
| 20 | Why no network call in View | W-30 | |
| 21 | Testable logic vs. UI | W-23 | |
| 22 | Navigation; why not in ViewModel | W-30 | |
| 23 | Requirement ID → code | W-35 | |
| 24 | Adding hourly forecast support | W-13 | |
| 25 | AI-written function, line by line | W-26 | |
| 26 | **AI meta-instructions + one requirement** | W-26 | `SPEC.md` §1 |
| 27 | Pushing back on the AI | W-26 | `docs/LLM_PROCESS.md` |
| 28 | Verifying AI code with a test | W-23 | |
| 29 | Most effective prompt | W-26 | `docs/LLM_PROCESS.md` |
| 30 | What I'd do differently | W-40 | `docs/REFLECTION.md` |

## 10. End-of-session ritual

1. One-line summary in the update log (§12).
2. Update plan (§5), decision log (§8) and oral exam map (§9).
3. Tick requirements in §3 — only those I can explain.
4. Log the session in `docs/LLM_PROCESS.md` and add notes to `docs/REFLECTION.md` (I write both).

## 11. AI usage

- **Tools:** Claude Code (Claude Opus 5.5)
- **Context loaded each session:** `CLAUDE.md`, which imports `SPEC.md`, `STYLE.md`, `CONTEXT.md` and `README.md`
- **AI-assisted so far:** first drafts of `SPEC.md`, `STYLE.md` and `CONTEXT.md`; Xcode project setup; start-screen UI boilerplate (`Design/`, `View/`); skeleton (`Model/`, `Data/`, `ViewModel/`) and its tests
- **Code:** written by the AI after my approval, explained part by part (`STYLE.md` §2.1)
- **Prompts and who-wrote-what:** see `docs/LLM_PROCESS.md`

Session start prompt:
```
Today I want to work on: ______. Follow SPEC.md §1 and STYLE.md §2: propose first,
write after my OK, explain every part, then ask me one explain-back question.
Run the end-of-session ritual (SPEC.md §10) at the end.
```

## 12. Update log

| Date | Summary | IDs |
| ---- | ------- | --- |
| 2026-11-13 | Created `SPEC.md` and `STYLE.md`; chose iOS + Open-Meteo + geocode.maps.co | — |
| 2026-11-16 | Made `SPEC.md` and `STYLE.md` shorter; created `CONTEXT.md` | — |
| 2026-11-20 | Created Xcode project (iOS 17.0, SwiftUI, Swift Testing); flattened layout to match `STYLE.md` §3; added `.gitignore`, layer folders with `.gitkeep`, `docs/`; build + tests pass on iPhone 17 simulator | W-30 |
| 2026-11-23 | Re-saved Open-Meteo fixtures; designed start screen and added its spec (§6); built start-screen UI with sample data (`Design/` tokens, `View/Components/`, `View/Search/`) on branch `UI`; build passes; pushed to `origin/UI` (push first failed because iCloud had offloaded repo files) | W-10, W-02, W-32, W-33 |
| 2026-11-23 | Skeleton (no views): real Open-Meteo forecast for fixed Stockholm through Model, DTO, parser, service, repository and ViewModel; 14 unit tests pass, opt-in live API test passes | W-10, W-12, W-19, W-21, W-22, W-23, W-30 |
