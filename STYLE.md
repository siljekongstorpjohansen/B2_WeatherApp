# STYLE.md — B2 Weather App

> How I write code and work with the AI. `SPEC.md` = what to build · `STYLE.md` = how · `CONTEXT.md` = course rules. The AI reads all three at session start.

## 1. Coding philosophy

1. **I can explain every line** — otherwise it isn't done, no matter who wrote it.
2. **Readable over clever.** Plain `if`/`switch` and named values over dense chains.
3. **One job per layer** (§4). A type that knows about two layers is in the wrong place.
4. **Abstractions earn their place.** A protocol only when there are two implementations (real + test fake). No "Manager"/"Helper"/"Utils".
5. **Spec before code** — a component needs an entry in `SPEC.md` §6 first.
6. **Apple SDK only**, everything in **English**.

## 2. AI role

### 2.1 Code tiers

| Tier | What | Who writes | AI's role |
| ---- | ---- | ---------- | --------- |
| **Core** | `ForecastParser`, hourly/daily grouping, ViewModel state, error classification, cache fallback, `CoordinateValidator` | **AI**, after my approval | Tutor + writer: proposes, writes after my OK, explains every part as I go through it |
| **Support** | Repository, services, storage, `ConnectivityMonitor`, navigation, unit tests | Shared | Drafts one small piece at a time; I read and can explain it |
| **Boilerplate** | SwiftUI layout, styling, icons, previews, project setup, fixtures | AI | Writes directly, explains key parts |

Unsure which tier? **Ask before writing.**

### 2.2 Hint ladder (on request)

Used only when I ask for it. One step at a time; stop as soon as I can continue:

1. **Concept** — plain words + small example
2. **Questions** — what must it guarantee, what can go wrong?
3. **Pseudocode** — steps, no Swift
4. **Skeleton** — signature + `// TODO`s
5. **Review** — I write it; AI points out problems without fixing
6. **Full solution** — only if I ask after 1–5; I then rewrite it from memory

### 2.3 Explain-back

After every Core or Support piece, the AI asks one of: *"Walk me through it with input ___"* · *"Which test fails if this line is removed?"* · *"Which oral exam question (`SPEC.md` §9) does this answer?"* — If I can't answer, it's not done.

### 2.4 The AI must not

- Tick requirements, write test results, `LLM_PROCESS.md` or `REFLECTION.md`
- Add tests, files, dependencies or features I haven't approved
- Silently rewrite my code — suggest and explain; I decide
- Change the architecture without a proposed entry in `SPEC.md` §8

## 3. Project structure

```
WeatherApp/
├── App/         WeatherApp.swift — entry point, dependency setup
├── Model/       Forecast, DayForecast, HourForecast, Place, WeatherCondition
├── Data/
│   ├── DTO/     OpenMeteoResponse, GeocodingResult (Codable mirrors of the JSON)
│   ├── Parsing/ ForecastParser, GeocodingParser
│   ├── Network/ ForecastService, GeocodingService, HTTPClient, NetworkError
│   ├── Storage/ ForecastCache, FavouritesStore, SettingsStore
│   └── WeatherRepository.swift
├── ViewModel/   ForecastViewModel, FavouritesViewModel, SettingsViewModel
├── View/        Search/, Detail/, Favourites/, Settings/, Components/
└── Design/      Spacing, typography, colour tokens
WeatherAppTests/
├── Fixtures/    Saved JSON from the real APIs
└── *Tests.swift One file per tested type
```

One primary type per file, named after the type.

## 4. Layer rules (MVVM + Repository)

| Layer | May use | Must not |
| ----- | ------- | -------- |
| View | ViewModel, Model, Design | Call services, parse JSON, hold logic |
| ViewModel | Repository (protocol), Model | Know URLs/JSON/DTOs, navigate |
| Repository | Services, Parsers, Storage | Know Views/ViewModels |
| Service | `URLSession`, DTOs | Pass DTOs past the repository |
| Parser | DTO, Model | Do I/O (pure, synchronous → easy to test) |
| Model | Foundation | Contain API-specific keys |

- **Flow:** View intent → ViewModel → Repository → Service → Parser → Model → ViewModel state → View.
- **Navigation** belongs to Views (`NavigationStack`); ViewModels expose data, not routes.
- **Dependency injection** through initialisers; tests pass a fake repository. No singletons except the app entry point.

## 5. Swift conventions

**Naming**
- Swift API Design Guidelines. Names describe the role: `dailyForecasts`, `fetchForecast(for:)` — not `array`, `getData()`.
- Booleans read as statements: `isLoading`, `hasCachedData`, `isFavourite`.
- Meaningful suffixes: `…View`, `…ViewModel`, `…Service`, `…Repository`, `…Store`, `…Parser`, `…DTO`/`…Response`.
- Units in names when ambiguous: `temperatureCelsius`, `refreshIntervalMinutes`.
- Always British **favourite**, never "favorite".

**Types and state**
- `struct`/`enum` first; `final class` only for ViewModels and stores. `private` and `let` by default.
- ViewModels are `@Observable` + `@MainActor`, with screen state as an `enum`, e.g. `idle / loading / loaded / failed` (exact shape is Core — AI proposes, I approve).
- No `!` or `try!` outside tests and previews.

**Concurrency**
- `async/await` only. Network and disk work off the main actor.
- A new search cancels the previous `Task`; ignore results from outdated requests.

**Errors**
- Services throw a typed `NetworkError` (offline, timeout, HTTP status, decoding).
- Repository decides cache fallback; ViewModel maps errors to a user-facing message + retry.
- No empty `catch`. No error ends in a blank screen.

**Comments**
- Explain *why*, not *what*. `///` on non-private functions in `Data/` and `ViewModel/`.
- Tag requirement IDs where useful: `// W-17: show cached forecast when offline`. No commented-out code.

## 6. UI style

- **Tokens** in `Design/`: spacing 4 · 8 · 12 · 16 · 24 · 32, Dynamic Type styles, semantic colours. No magic numbers in views.
- **Hierarchy:** current temperature + condition → 7-day list → details (wind, precipitation).
- **SF Symbols** for conditions, mapped from WMO codes in one place (`WeatherCondition`).
- **Four designed states** per async screen: loading · loaded · empty · error (with retry). Offline shows cached data + "last updated …".
- Portrait + landscape, iPhone + iPad. Dark Mode, Dynamic Type, accessibility labels on icons.
- `#Preview` for every view, including loading and error states.

## 7. Testing

- Swift Testing for unit tests, XCTest for UI tests (`SPEC.md` §8, 2026-11-20).
- Behaviour-based names: `parserReturnsSevenDaysForValidResponse`. Arrange / Act / Assert, one behaviour per test.
- Parser tests use real saved JSON from `Fixtures/`; ViewModel tests use a fake repository — no real network.
- Each key test gets a **mutation test** (break the code, confirm the test fails), recorded in `docs/TEST_REPORT.md`.

## 8. Git

- Small commits, imperative subject ≤ 72 chars, with IDs: `Add ForecastParser daily mapping (W-13, W-19)`.
- Never commit API keys — they go in `Secrets.xcconfig` (in `.gitignore`).
- Build and tests pass before every push.
