# SPEC.md — B2 Weather App (Lab B:2)

> Living requirements document and AI control file. Read at the start of **every** AI session and updated at the end of every session (see §10).

---

## 1. AI meta-instructions

> **To the AI assistant: read this section before doing anything else.**

1. Read `SPEC.md` and `STYLE.md` first. Where they conflict with the student's request, **point out the conflict** — the student decides.
2. The student's goal is to **learn and be able to explain every line** at the oral exam. Act as tutor and reviewer for **Core** code (see §5 code tiers). Follow the hint ladder in `STYLE.md` — never jump to a full solution for Core code unless the student explicitly asks after the earlier steps.
3. **Never** tick a requirement in §3 as done unless the student has explained it back in their own words.
4. **Never** write test results, `docs/TEST_REPORT.md` results, `docs/LLM_PROCESS.md`, or `docs/REFLECTION.md`. You may suggest reflection questions; you may not answer them.
5. **Spec before code:** before implementing a component, make sure it has an entry in §6 (purpose, inputs/outputs, edge cases, test ideas, requirement IDs). If it is missing, draft it and ask the student to review it first.
6. Do **not** add new tests, dependencies, files or features without the student's approval. Use only the Apple platform SDK — **no third-party packages**.
7. All code, comments and documentation in **English**, even if the student writes in another language.
8. Link every code change to one or more requirement IDs (`W-xx`) and, where relevant, oral exam questions (§8).
9. The final submission must call the **real APIs** (Open-Meteo, geocode.maps.co), not test servers.
10. **Remind the student of the end-of-session ritual (§10) at the end of every session.**

---

## 2. Project facts

| Course | Lab | Platform | Language / UI | Grade target |
| ------ | --- | -------- | ------------- | ------------ |
| HI1033 | B:2 — Native Weather App | iOS (iPhone + iPad) | Swift / SwiftUI, Xcode | A / VG |

| Item | Choice |
| ---- | ------ |
| Forecast API | Open-Meteo — `https://api.open-meteo.com/v1/forecast` ([docs](https://open-meteo.com/en/docs)) |
| Geocoding API | geocode.maps.co — `https://geocode.maps.co/search?q={place}` |
| Networking | `URLSession` + `async/await` (in repository layer, not the ViewModel) |
| JSON | `Codable` into dedicated DTO structs, mapped to own domain model |
| Persistence | `UserDefaults` / file cache for last forecast; favourites + settings (final choice in §7) |
| Connectivity | `NWPathMonitor` (Network framework) |
| Architecture | MVVM + Repository |
| Testing | XCTest / Swift Testing, run on Xcode Simulator (iPhone + iPad) |

**Related files**

| File | Purpose | Required |
| ---- | ------- | -------- |
| `SPEC.md` | This file — requirements + AI control | Yes (Appendix C) |
| `STYLE.md` | Coding philosophy, naming, AI role, hint ladder | Recommended |
| `CONTEXT.md` | Course-specific constraints | Recommended |
| `README.md` | Architecture overview: main files, responsibilities, how layers connect | Yes (Appendix B) |
| `docs/LLM_PROCESS.md` | Log of AI sessions, who-wrote-what table — **written by students** | Yes (Appendix D) |
| `docs/TEST_REPORT.md` | Unit tests, results, mutation tests, 20 UX scenarios | Yes (Appendix A) |
| `docs/REFLECTION.md` | Students' own reflection — **AI must not write this** | Yes (report) |

---

## 3. Requirements checklist

Status: ☐ not started · ◐ in progress · ☑ done (student can explain it)

### 3.1 Basic requirements (screens & features)

| ID | Requirement | Status |
| -- | ----------- | ------ |
| W-01 | App displays the weather forecast for the location the user requests | ☐ |
| W-02 | **Search / home screen**: user enters a city name or coordinates; shows current conditions and a 7-day forecast summary | ☐ |
| W-03 | **Detail screen**: full forecast for a selected day — temperature, weather condition, and additional data (wind, precipitation, etc.) | ☐ |
| W-04 | User can mark places as **favourites** | ☐ |
| W-05 | Dedicated **favourites quick-access view** | ☐ |
| W-06 | **Settings screen**: configure data refresh rate and other UI preferences (e.g. units) | ☐ |

### 3.2 Detailed requirements

| ID | Requirement | Status |
| -- | ----------- | ------ |
| W-10 | Forecast data fetched from Open-Meteo | ☐ |
| W-11 | Place name resolved to coordinates via geocoding API (geocode.maps.co) | ☐ |
| W-12 | For each of the next 7 days: temperature + visual weather condition (icon / colour / text) | ☐ |
| W-13 | Data grouped: **hourly detail for today**, **daily overview** for remaining days | ☐ |
| W-14 | Input accepts city name **or** coordinates | ☐ |
| W-15 | Coordinate input accepts only valid floating-point values (lat −90…90, lon −180…180) | ☐ |
| W-16 | Parsed data stored locally; shown when the network is unavailable | ☐ |
| W-17 | Offline: no crash, meaningful message, last successfully fetched data displayed if available | ☐ |
| W-18 | Correct layout in portrait **and** landscape (iPhone and iPad) | ☐ |
| W-19 | Separate class/struct for parsing JSON into the internal data model | ☐ |
| W-20 | Forecast data displayed in a scrollable list | ☐ |
| W-21 | All network requests run off the main thread | ☐ |
| W-22 | All errors handled: a failed request never causes a crash or a silent blank screen | ☐ |
| W-23 | Tests for at least two of: JSON parsing, error-state logic, data transformation — runnable and passing | ☐ |
| W-24 | Test report documents ≥ 20 distinct UX scenarios (start state, action, expected result) | ☐ |
| W-25 | Testing performed on Xcode Simulator or physical device (not browser preview) | ☐ |
| W-26 | AI usage documented (§11) | ☐ |
| W-27 | Final build uses the real APIs, not the KTH proxy | ☐ |

### 3.3 Higher-level requirements (craft)

| ID | Requirement | Status |
| -- | ----------- | ------ |
| W-30 | **Structured code**: networking, data transformation, state management and UI are distinct layers; deliberate naming; abstractions earn their place | ☐ |
| W-31 | Architecture is visible from `SPEC.md` / `README.md` before opening Xcode | ☐ |
| W-32 | **Designed UI**: clear hierarchy, consistent spacing, consistent visual language | ☐ |
| W-33 | Loading, empty and error states are designed, not defaults | ☐ |
| W-34 | Edge cases handled; app behaves correctly under real conditions (slow network, rapid searches, no results) | ☐ |
| W-35 | Oral exam questions mapped to code locations (§8) | ☐ |
| W-36 | `SPEC.md` reflects the actual development process (update log §12 kept every session) | ☐ |

### 3.4 Submission deliverables

| ID | Deliverable | Status |
| -- | ----------- | ------ |
| W-40 | Reflection report (~½ page): one surprise, one thing to do differently — **students write** | ☐ |
| W-41 | Appendix A — `docs/TEST_REPORT.md` + test files | ☐ |
| W-42 | Appendix B — `README.md` (architecture) | ☐ |
| W-43 | Appendix C — `SPEC.md` (this file) | ☐ |
| W-44 | Appendix D — `docs/LLM_PROCESS.md` | ☐ |
| W-45 | Submitted at least one day before the presentation | ☐ |

---

## 4. Architecture overview (draft — to be confirmed by students)

```
 View (SwiftUI)            ViewModel (@Observable, @MainActor)      Repository / Services            Model
 ───────────────           ──────────────────────────────────      ─────────────────────            ─────
 SearchView        ──▶     ForecastViewModel        ──▶            WeatherRepository        ──▶     Forecast, DayForecast,
 DayDetailView             FavouritesViewModel                       ├─ ForecastService (HTTP)        HourForecast, Place,
 FavouritesView            SettingsViewModel                         ├─ GeocodingService (HTTP)       WeatherCondition
 SettingsView                                                        ├─ ForecastParser (DTO→Model)
                    ◀──  observed state (ViewState)  ◀──            ├─ ForecastCache (persistence)
                                                                     └─ ConnectivityMonitor
```

- **View** renders state and forwards user intents. No networking, no parsing.
- **ViewModel** owns screen state (`idle / loading / loaded / failed`, plus cached data), calls the repository, cancels stale requests.
- **Repository** decides network vs. cache, hides HTTP and persistence details from the ViewModel.
- **Parser** maps API DTOs (`Codable`) into the domain model — the UI never sees raw API types.
- **Navigation** is owned by the View layer (`NavigationStack`), not by ViewModels.

---

## 5. Code tiers (who writes what)

| Tier | What | Who writes | AI's role |
| ---- | ---- | ---------- | --------- |
| Core | Parsing (DTO → model), data grouping (hourly today / daily rest), ViewModel state machine, error classification, cache-fallback logic, coordinate validation | Students | Tutor and reviewer only — hint ladder |
| Support | Repository wiring, services, navigation, persistence plumbing, unit tests | Shared | May draft small pieces; students read and can explain every part |
| Boilerplate | SwiftUI layout, icons/colours, Xcode project setup | AI | Writes directly, explains key parts |

---

## 6. Component specs (spec before code)

> Each entry: purpose, inputs/outputs, edge cases, test ideas, requirement IDs. Fill in **before** coding. Entries below are initial drafts.

### GeocodingService
- **Purpose:** Convert a place name into a list of candidate `Place`s (name, lat, lon).
- **Input:** query string. **Output:** `[Place]` or a typed error.
- **Edge cases:** empty/whitespace query, no results, special characters (å, ä, ö) needing URL encoding, HTTP 401/429 (key/rate limit), timeout.
- **Test ideas:** parse sample JSON; empty array → "no results" state.
- **Requirements:** W-11, W-14, W-22

### ForecastService
- **Purpose:** Fetch Open-Meteo forecast JSON for given coordinates.
- **Input:** latitude, longitude. **Output:** raw `Data` / DTO or typed error.
- **Edge cases:** timeout, no connection, HTTP 4xx/5xx, HTTP 200 with malformed/missing fields.
- **Requirements:** W-10, W-21, W-22

### ForecastParser
- **Purpose:** Map Open-Meteo DTO into domain `Forecast` (current, hourly today, 7 daily).
- **Input:** DTO (or `Data`). **Output:** `Forecast` or parsing error.
- **Edge cases:** mismatched array lengths in `hourly`/`daily`, missing optional fields, unknown WMO weather code, time zone handling.
- **Test ideas:** valid fixture → 7 days; missing field → error; unknown code → fallback condition.
- **Requirements:** W-12, W-13, W-19, W-23

### ForecastCache
- **Purpose:** Persist last successful forecast per place with fetch timestamp.
- **Edge cases:** no cache on first launch, corrupt cache, stale cache (older than refresh rate).
- **Requirements:** W-16, W-17

### CoordinateValidator
- **Purpose:** Decide whether input is coordinates or a place name; validate floats and ranges.
- **Edge cases:** comma as decimal separator, out-of-range values, extra whitespace, a single number.
- **Test ideas:** `"59.33, 18.06"` valid; `"91, 0"` invalid; `"abc"` → place name.
- **Requirements:** W-14, W-15

### ForecastViewModel
- **Purpose:** Screen state for search/home and detail; orchestrates search → geocode → fetch → display.
- **Edge cases:** rapid successive searches (cancel previous `Task`), offline with/without cache, refresh while loaded.
- **Requirements:** W-02, W-03, W-17, W-22, W-34

### FavouritesStore / SettingsStore
- **Purpose:** Persist favourite places and user preferences (refresh rate, units).
- **Requirements:** W-04, W-05, W-06

---

## 7. Open questions

| # | Question | Status |
| - | -------- | ------ |
| Q1 | geocode.maps.co now requires a free API key — how do we store it without committing it (e.g. `.xcconfig` excluded from git)? | Open |
| Q2 | Persistence: `UserDefaults` + JSON vs. SwiftData for cached forecasts and favourites? | Open |
| Q3 | Which "other UI preferences" go on the settings screen (units °C/°F, wind units, theme)? | Open |
| Q4 | Refresh-rate semantics: auto-refresh on a timer while visible, or refresh-on-open when cache is older than N minutes? | Open |
| Q5 | Minimum iOS deployment target (affects `@Observable`, Swift Testing, SwiftData)? | Open |
| Q6 | Which Open-Meteo hourly/daily fields to request — and which to deliberately ignore (oral Q3)? | Open |

---

## 8. Decision log

| Date | Decision | Alternatives considered | Reason | Req IDs |
| ---- | -------- | ----------------------- | ------ | ------- |
| 2026-11-13 | Platform: iOS, Swift/SwiftUI | Android (Kotlin/Compose), React Native | _students fill in_ | — |
| 2026-11-13 | APIs: Open-Meteo + geocode.maps.co | SMHI + SMHI autocomplete | _students fill in_ | W-10, W-11 |
| 2026-11-13 | Architecture: MVVM + Repository, no third-party packages | — | Course recommendation; testable layers | W-30 |

---

## 9. Oral exam map

> Fill in as each component is completed. Opening question is always **Q26**.

| # | Question (short) | Req IDs | Code location | Test name |
| - | ---------------- | ------- | ------------- | --------- |
| 1 | Function that makes the API request — where, what does it return? | W-10 | | |
| 2 | How is JSON parsed into the model? | W-19 | | |
| 3 | Which API fields are used / ignored, and why? | W-12, W-13 | | |
| 4 | HTTP 200 but a field is missing? | W-22 | | |
| 5 | Trace data flow: "search" → forecast on screen | W-01, W-30 | | |
| 6 | Caching: what is stored, when refreshed? | W-16, W-06 | | |
| 7 | Where does weather data live at runtime? | W-30 | | |
| 8 | What happens to displayed data on a new search? | W-02 | | |
| 9 | How does the UI know new data arrived? | W-30 | | |
| 10 | State preserved when leaving/returning to app? | W-16 | | |
| 11 | Where is loading state managed; avoiding stale data in flight? | W-33 | | |
| 12 | Two rapid searches — race condition? | W-34 | | |
| 13 | Display on network timeout? | W-17, W-22 | | |
| 14 | Network error vs. API error (404/500) — where distinguished? | W-22 | | |
| 15 | No internet, first launch? | W-17 | | |
| 16 | No internet, second launch with cached data? | W-16, W-17 | | |
| 17 | Where is error state declared; how does it reach the UI? | W-22, W-33 | | |
| 18 | Hardest error case — show code | W-22 | | |
| 19 | MVVM layers in the code | W-30 | | |
| 20 | Why is the network call not in the View? | W-30 | | |
| 21 | Where is testable logic separated from UI? | W-23, W-30 | | |
| 22 | How does navigation work; why doesn't the ViewModel navigate? | W-02, W-03 | | |
| 23 | One requirement ID → implementing code | W-35 | | |
| 24 | Architecture changes to add hourly forecast support | W-13, W-30 | | |
| 25 | A function the AI helped write — explain line by line | W-26 | | |
| 26 | **AI meta-instructions + one requirement → code** | W-26, W-35 | `SPEC.md` §1 | |
| 27 | Where did you push back on the AI? | W-26 | `docs/LLM_PROCESS.md` | |
| 28 | How was AI code verified? Show a test | W-23 | | |
| 29 | Most effective prompt | W-26 | `docs/LLM_PROCESS.md` | |
| 30 | What would you do differently? | W-40 | `docs/REFLECTION.md` | |

---

## 10. End-of-session ritual

Run after **every** AI session:

1. Summarise the session: what was coded, tested or designed (1–2 sentences) → §12.
2. Update the plan table (§13).
3. Tick completed requirements in §3 — **only** if the students can explain them.
4. Update the decision log (§8) with new architectural choices.
5. Update the oral exam map (§9) with code locations and test names.
6. Students write a log entry in `docs/LLM_PROCESS.md`: date, what was done, approximate time.
7. Students write running notes in `docs/REFLECTION.md`: what was hard, what is understood better now.

---

## 11. AI usage

| Item | Details |
| ---- | ------- |
| Tools | Claude Code (Claude Opus 5.5) — _add others if used_ |
| Context files loaded each session | `SPEC.md`, `STYLE.md`, `CONTEXT.md` |
| AI-assisted parts | Initial `SPEC.md` draft (2026-11-13) — _keep updated per component_ |
| Representative prompts | See `docs/LLM_PROCESS.md` |

**Session start prompt (copy–paste):**

```
Read SPEC.md and STYLE.md before anything else. We follow the coding approach
in STYLE.md: our goal is to learn, we write Core code ourselves, and you act as
tutor and reviewer. Today we want to work on: ______. Ask us what we have tried
first. Run the end-of-session ritual in SPEC.md §10 at the end.
```

---

## 12. Update log (end of session)

| Date | Session summary | Req IDs touched |
| ---- | --------------- | --------------- |
| 2026-11-13 | Created initial `SPEC.md` from the lab instructions; chose iOS + Open-Meteo + geocode.maps.co; target A/VG. | — |

---

## 13. Plan and status

| Step | Work | Req IDs | Status |
| ---- | ---- | ------- | ------ |
| 1 | Inspect Open-Meteo and geocode.maps.co JSON (browser/Postman); save sample fixtures | W-10, W-11 | ☐ |
| 2 | Write `STYLE.md` and `CONTEXT.md`; review §6 component specs | W-30, W-31 | ☐ |
| 3 | Create Xcode project, folder structure per §4 | W-30 | ☐ |
| 4 | Domain model + `ForecastParser` + parser tests | W-19, W-23 | ☐ |
| 5 | Services + repository (network, cache, connectivity) | W-10, W-11, W-16, W-21 | ☐ |
| 6 | ViewModels with explicit state + error-state tests | W-22, W-23, W-34 | ☐ |
| 7 | Search/home + detail screens | W-02, W-03, W-12, W-13, W-20 | ☐ |
| 8 | Favourites + settings | W-04, W-05, W-06 | ☐ |
| 9 | Designed loading/empty/error states; portrait/landscape; iPhone + iPad | W-18, W-32, W-33 | ☐ |
| 10 | Test report incl. 20 UX scenarios + mutation tests; README; final docs | W-24, W-41–W-45 | ☐ |

---

## 14. Done

- [ ] All requirements ticked (§3)
- [ ] Tests pass on simulator
- [ ] Mutation tests documented
- [ ] Docs complete (README, TEST_REPORT, LLM_PROCESS, REFLECTION)
