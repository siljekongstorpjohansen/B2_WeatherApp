# B2_WeatherApp

iOS weather app (SwiftUI, iOS 17+). Search a city or coordinates, see current conditions, the next 24 hours and 7 days, open a day for details, keep favourites, and keep working offline with the last forecast. CM2023 Lab B:2 — requirements in `SPEC.md`, tests in `docs/TEST_REPORT.md`.

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
2. The ViewModel cancels the previous search, sets `state = .loading` and asks `CoordinateValidator` whether the text is a place name or coordinates.
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

## Setup

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
4. **Check that git ignores it:** `git status` must **not** list `Secrets.xcconfig`.
5. **Build and run** in Xcode (⌘R). The start screen shows Stockholm's real weather; the favourite chips show their own cities.

**Troubleshooting**

| Problem | Fix |
| ------- | --- |
| Every search shows "Couldn't load the forecast" | The key is missing or mistyped. Check step 3, then **Product › Clean Build Folder** (⇧⌘K) and build again. |
| `Secrets.xcconfig` is red in Xcode | The file doesn't exist yet — do step 2. |
| Error after tapping many cities quickly | The free plan allows about 1 search per second. Wait a moment and tap **Try again**. |

**Live API tests** (optional, use the real services):
```
TEST_RUNNER_LIVE_API_TESTS=1 xcodebuild test -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:WeatherAppTests/LiveWeatherRepositoryTests
```
