# SPEC.md — B2 Weather App

> Living requirements document + AI control file. Read at the start of every AI session; update at the end (§10).

## 1. AI meta-instructions

> **AI: read this first.**

- Read `SPEC.md`, `STYLE.md` and `CONTEXT.md` first. If they conflict with my request, point it out — I decide.
- I must be able to explain every line. Follow the code tiers and hint ladder in `STYLE.md`; never write Core code unprompted.
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
| `ForecastService` | Fetch Open-Meteo JSON for lat/lon | Offline, timeout, 4xx/5xx, 200 with bad JSON | W-10, W-21 |
| `ForecastParser` | DTO → `Forecast` (current, hourly today, 7 days) | Mismatched array lengths, missing fields, unknown weather code, time zones | W-13, W-19 |
| `ForecastCache` | Store last forecast + timestamp | First launch, corrupt data, stale data | W-16, W-17 |
| `CoordinateValidator` | Coordinates or place name? Validate range | Comma decimals, out of range, single number | W-14, W-15 |
| `ForecastViewModel` | Search → geocode → fetch → state | Rapid searches, offline ± cache, refresh | W-02, W-17, W-34 |
| `FavouritesStore` / `SettingsStore` | Persist favourites and preferences | — | W-04–W-06 |

**Test ideas:** valid fixture → 7 days · missing field → error · `"59.33, 18.06"` valid · `"91, 0"` invalid · empty geocode result → "no results" state.

## 7. Open questions

1. Where to keep the geocode.maps.co API key out of git (`.xcconfig` in `.gitignore`?)
2. Persistence: `UserDefaults` + JSON or SwiftData?
3. Which UI preferences in settings (units, theme, …)?
4. Refresh rate: timer while visible, or refresh on open when cache is older than N min?
5. Minimum iOS version?
6. Which Open-Meteo fields to use — and which to ignore (oral Q3)?

## 8. Decision log

| Date | Decision | Alternatives | Reason | IDs |
| ---- | -------- | ------------ | ------ | --- |
| 2026-11-13 | iOS, Swift/SwiftUI | Android, React Native | Choosen because I have a mac and an Iphone, makes the testing process easier | — |
| 2026-11-13 | Open-Meteo + geocode.maps.co | SMHI | Get more data to work with and more rekevant because my hometown is not in Sweden | W-10, W-11 |
| 2026-11-13 | MVVM + Repository, no packages | — | Course recommendation; testable layers | W-30 |

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
- **Context loaded each session:** `SPEC.md`, `STYLE.md`, `CONTEXT.md`
- **AI-assisted so far:** first drafts of `SPEC.md`, `STYLE.md` and `CONTEXT.md`
- **Prompts and who-wrote-what:** see `docs/LLM_PROCESS.md`

Session start prompt:
```
Read SPEC.md, STYLE.md and CONTEXT.md first. I write Core code myself; you act as
tutor and reviewer (STYLE.md). Today I want to work on: ______.
Ask me what I have tried first. Run the end-of-session ritual (SPEC.md §10) at the end.
```

## 12. Update log

| Date | Summary | IDs |
| ---- | ------- | --- |
| 2026-11-13 | Created `SPEC.md` and `STYLE.md`; chose iOS + Open-Meteo + geocode.maps.co | — |
| 2026-11-16 | Made `SPEC.md` and `STYLE.md` shorter; created `CONTEXT.md` | — |
| 2026-11-20 | Created Xcode project (iOS 17.0, SwiftUI, Swift Testing); flattened layout to match `STYLE.md` §3; added `.gitignore`, layer folders with `.gitkeep`, `docs/`; build + tests pass on iPhone 17 simulator | W-30 |
