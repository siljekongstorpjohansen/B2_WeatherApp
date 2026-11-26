# B2_WeatherApp

iOS weather app (SwiftUI, iOS 17+). Search a city or coordinates, see current conditions, the next 24 hours and 7 days, open a day for details, keep favourites, and keep working offline with the last forecast.

CM2023 Lab B:2 · pair project · **Appendix B** of the hand-in (how the code is structured).

| Hand-in document | File |
| ---------------- | ---- |
| Reflection report | `docs/REFLECTION.md` |
| Appendix A — tests and UX scenarios | `docs/TEST_REPORT.md` + `WeatherAppTests/` |
| Appendix B — code structure | `README.md` (this file) |
| Appendix C — requirements, AI meta-instructions, update log | `SPEC.md` |
| Appendix D — AI process log | `docs/LLM_PROCESS.md` |

## Features

| Screen | What it does | IDs |
| ------ | ------------ | --- |
| Weather (start) | One search field for a city or `lat, lon` · current conditions · next 24 hours · scrollable 7-day list · ★ to save the place · favourite chips | W-01, W-02, W-12–W-15, W-20 |
| Day detail | Tap a day: hour by hour, feels like, precipitation, wind + gusts + direction, UV, sunrise/sunset | W-03, W-13 |
| Favourites | Saved places, sortable (most viewed · A–Z · recently added), swipe to delete, tap to open | W-04, W-05 |
| Settings | °C/°F, km/h · m/s · mph, appearance, 12/24-hour time, refresh when older than 15/30/60 min or manual | W-06 |
| Offline | Latest forecast saved on disk; shown with a "You're offline" banner when the network is gone | W-16, W-17 |

All screens work in portrait and landscape on iPhone and iPad (W-18).

## Architecture

MVVM + Repository, Apple SDK only (W-30, W-31). Each layer has one job and only talks to the layer below it.

```
 View  ──intent──▶  ViewModel  ──▶  WeatherRepository  ──▶  Services (HTTP)  ──▶  Open-Meteo, geocode.maps.co
   ▲                    │    ▲              │       └──────▶  Parsers: DTO → Model
   └── observed state ──┘    │              └──────────────▶  ForecastCache (file on disk)
                             └── ConnectivityMonitor (online / offline)
```

### Layers

| Layer | Folder | Main types | Job | Must not |
| ----- | ------ | ---------- | --- | -------- |
| App | `App/` | `WeatherApp` | Creates the ViewModels and injects the real repository, stores and connectivity stream — the only place that picks real vs. fake | Hold logic |
| View | `View/`, `Design/` | `ContentView` (tabs), `SearchView`, `DayDetailView`, `FavouritesView`, `SettingsView`, `Components/` | Draws ViewModel state, sends user intents, owns navigation (`NavigationStack`, `TabView`) | Call services, parse JSON |
| ViewModel | `ViewModel/` | `ForecastViewModel`, `FavouritesViewModel`, `SettingsViewModel`, `ForecastDisplay`, `CoordinateValidator` | Screen state (`idle / loading / loaded / failed`), cancels stale searches, turns errors into messages, `Forecast` → screen data in the chosen units | Know URLs, JSON or DTOs; navigate |
| Repository | `Data/` | `WeatherRepository` (protocol), `LiveWeatherRepository`, `FakeWeatherRepository` | One entry point for ViewModels; chooses network vs. cache; one error type (`NetworkError`) | Know views |
| Network | `Data/Network/` | `ForecastService`, `GeocodingService`, `NetworkError`, `ConnectivityMonitor` | HTTP requests off the main actor; classify every failure | Pass DTOs past the repository |
| Parsing | `Data/DTO/`, `Data/Parsing/` | `OpenMeteoResponse`, `GeocodingResult`, `ForecastParser`, `GeocodingParser` | DTOs mirror the JSON; parsers turn them into models — pure and synchronous, so they are unit tested with saved JSON | Do I/O |
| Storage | `Data/Storage/` | `ForecastCache`, `FavouritesStore`, `SettingsStore` | Latest forecast as a JSON file in Application Support; favourites and settings as JSON in `UserDefaults` | Crash on missing or corrupt data |
| Model | `Model/` | `Place`, `Forecast`, `DayForecast`, `HourForecast`, `WeatherCondition`, `Favourite`, `UserSettings` | Plain app data, in °C and m/s; WMO code → text + SF Symbol in one place | Contain API keys or JSON names |

### Data flow: search → screen

1. `SearchView.submitSearch()` → `ForecastViewModel.search("Göteborg")`.
2. The ViewModel cancels the previous search, sets `state = .loading(previous:)` (the forecast already on screen stays visible, dimmed under a spinner) and asks `CoordinateValidator` whether the text is a place name or coordinates.
3. Place name → `WeatherRepository.searchPlaces` → `GeocodingService` (geocode.maps.co) → `GeocodingParser` → `[Place]`. Coordinates skip this step.
4. `WeatherRepository.forecast(for:)` → `ForecastService` (Open-Meteo) → `ForecastParser` → `Forecast`, saved in `ForecastCache`.
5. The ViewModel builds a `ForecastDisplay` (units, "Now", "Today") and sets `state = .loaded(display)`.
6. The view is `@Observable`-driven, so SwiftUI redraws `SearchView` with the new state. A newer search that started meanwhile wins; the late answer is dropped.

### Errors and offline (W-17, W-22)

- Every failure becomes one `NetworkError` case: `offline`, `timeout`, `cancelled`, `httpStatus(code:reason:)`, `decoding`, `unknown`.
- Offline or timeout → the repository returns the last saved forecast with its time; the screen shows a yellow "You're offline" banner.
- `ConnectivityMonitor` (`NWPathMonitor`) shows that banner as soon as the connection drops and reloads when it returns. It never blocks a request.
- Anything else, or offline on first launch → "Couldn't load the forecast" with a message for that case and a **Try again** button. No error ends in a crash or a blank screen.

### Concurrency (W-21)

The app target defaults to the main actor. Services, parsers and the repository are `nonisolated`, and their entry points are `@concurrent`, so requests, JSON decoding and parsing run off the main thread. ViewModels are `@MainActor`.

### Where things are decided

| Question | Where |
| -------- | ----- |
| Why this design? | `SPEC.md` §8 (decision log) |
| Which requirement is where? | `SPEC.md` §6 (components) and §9 (oral exam map) |
| How is it tested? | `docs/TEST_REPORT.md`, `WeatherAppTests/` (one file per tested type) |
| Coding rules | `STYLE.md` |

## Project structure

One primary type per file, named after the type. Main files and their job:

```
WeatherApp/
├── App/WeatherApp.swift            Entry point: builds repository, stores, ViewModels; injects them
├── Model/
│   ├── Place, Forecast, DayForecast, HourForecast   App data in °C and m/s
│   ├── WeatherCondition            WMO code → text + SF Symbol, in one place
│   └── Favourite, FavouriteSortOrder, UserSettings   Saved user data + favourite sorting
├── Data/
│   ├── WeatherRepository.swift     Protocol the ViewModels use
│   ├── LiveWeatherRepository.swift Services + parsers + cache fallback (real app)
│   ├── FakeWeatherRepository.swift Canned results/errors (tests, previews)
│   ├── LoadedForecast.swift        Forecast + cache time (nil = fresh)
│   ├── DTO/                        OpenMeteoResponse, OpenMeteoErrorResponse, GeocodingResult,
│   │                               ReverseGeocodingResult — Decodable mirrors of the JSON
│   ├── Parsing/                    ForecastParser, GeocodingParser — DTO → Model, pure
│   ├── Network/                    ForecastService, GeocodingService (HTTP), NetworkError,
│   │                               ConnectivityMonitor (NWPathMonitor)
│   └── Storage/                    ForecastCache (file), FavouritesStore, SettingsStore (UserDefaults)
├── ViewModel/
│   ├── ForecastViewModel           Search → state; cancels stale searches; offline + refresh
│   ├── ForecastDisplay             Forecast → screen data in the chosen units
│   ├── CoordinateValidator         Text → place name / coordinates / invalid
│   └── FavouritesViewModel, SettingsViewModel   Lists and settings, saved on every change
├── View/
│   ├── ContentView                 Tab bar: Weather · Favourites · Settings
│   ├── Search/                     SearchView (state → screen), SearchScreenLayout, ForecastView
│   ├── Detail/                     DayDetailView, DetailTileView
│   ├── Favourites/                 FavouritesView, FavouriteRowView
│   ├── Settings/                   SettingsView
│   ├── Components/                 Current conditions, hourly strip, 7-day list, chips, search field,
│   │                               offline banner, message state, loading overlay
│   └── SampleData                  Fixed values for previews
└── Design/                         Spacing, Typography, Palette (colour tokens), TimeFormatting (12/24 h)
Config/                             WeatherApp.xcconfig, Info.plist, Secrets.example.xcconfig (key template)
WeatherAppTests/                    Unit tests, one file per tested type; Fixtures/ = saved API JSON
WeatherAppUITests/                  XCTest launch tests
docs/                               TEST_REPORT.md, LLM_PROCESS.md, REFLECTION.md
```

## Setup

**Requirements:** a Mac with Xcode 27, iOS 17.0+ (Simulator, e.g. iPhone 17, or a device). No third-party packages.

The city search uses **geocode.maps.co**, which needs an API key. The key is kept on each Mac and **never** goes into git (`SPEC.md` §8, 2026-11-24). The weather data (Open-Meteo) needs no key.

1. **Get a key:** ask a team member to send it privately (never in a PR, issue, commit or shared document), or sign up for a free key at [geocode.maps.co](https://geocode.maps.co).
2. **Create your private settings file** from the template, in the project folder:
   ```
   cp Config/Secrets.example.xcconfig Config/Secrets.xcconfig
   ```
3. **Open `Config/Secrets.xcconfig`** and paste the key after `=`, without quotes:
   ```
   GEOCODING_API_KEY = paste-the-key-here
   ```
   To run on a real iPhone, also fill in `DEVELOPMENT_TEAM =` with your own Apple team ID. The Simulator doesn't need it.
4. **Check that git ignores it:** `git status` must **not** list `Secrets.xcconfig`.
5. **Build and run** in Xcode (⌘R). The start screen shows Stockholm's real weather; the favourite chips show their own cities.

**Troubleshooting**

| Problem | Fix |
| ------- | --- |
| Every search shows "Couldn't load the forecast" | The key is missing or mistyped. Check step 3, then **Product › Clean Build Folder** (⇧⌘K) and build again. |
| `Secrets.xcconfig` is red in Xcode | The file doesn't exist yet — do step 2. |
| Error after tapping many cities quickly | The free plan allows about 1 search per second. Wait a moment and tap **Try again**. |

## Testing

Test plan, mutation tests and UX scenarios: `docs/TEST_REPORT.md` (Appendix A).

| What | How | Network |
| ---- | --- | ------- |
| Unit tests (Swift Testing) | Xcode ⌘U, or `xcodebuild test -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:WeatherAppTests` | None — saved fixtures and `FakeWeatherRepository` |
| UI tests (XCTest) | ⌘U runs them too (`WeatherAppUITests`) | Real APIs |
| Live API tests (opt-in) | `TEST_RUNNER_LIVE_API_TESTS=1 xcodebuild test -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:WeatherAppTests/LiveWeatherRepositoryTests` | Real APIs |

## Known limitations

- The free geocode.maps.co plan allows about 1 search per second; faster searches get HTTP 429 → error state with **Try again**.
- "No results" is shown as the error state ("No places match …") rather than a separate message under the search field (SPEC §6).
