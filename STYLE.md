# STYLE.md — B2 Weather App

> How we write code and how we work with the AI. `SPEC.md` says **what** to build; this file says **how**.
> The AI reads this file together with `SPEC.md` at the start of every session.

---

## 1. Coding philosophy

1. **I must be able to explain every line.** If I can't explain it, it's not done, no matter who wrote it.
2. **Readable over clever.** A colleague should understand a file without asking me. Prefer plain `if`/`switch` and named intermediate values over dense chains.
3. **Each layer has one job.** Networking, parsing/transformation, state and UI stay separate (see §4). If a type needs to know about two layers, it's in the wrong place.
4. **Abstractions earn their place.** Add a protocol only if there are two implementations (e.g. real service + test fake). No generic "Manager"/"Helper"/"Utils" types.
5. **Spec before code.** Every component gets an entry in `SPEC.md` §6 before it's implemented.
6. **Platform SDK only.** No third-party packages (SwiftUI, Foundation, Network, XCTest/Swift Testing, SwiftData if chosen).
7. **English everywhere:** code, comments, commit messages, docs.

---

## 2. AI role

### 2.1 Code tiers

| Tier | What (in this project) | Who writes | AI's role |
| ---- | ---------------------- | ---------- | --------- |
| **Core** | `ForecastParser` (DTO → model), grouping hourly-today / daily-rest, ViewModel state machine, error classification (network vs. API vs. decoding), cache-fallback logic, `CoordinateValidator` | **Me** | Tutor and reviewer only. Follows the hint ladder (§2.2). Never writes a full solution unprompted. |
| **Support** | Repository wiring, `ForecastService` / `GeocodingService`, persistence plumbing, `ConnectivityMonitor`, navigation, unit tests | Shared | May draft small pieces (one function at a time). I read, change and can explain every part. |
| **Boilerplate** | SwiftUI layout, styling, icons, previews, Xcode project setup, fixtures | AI | Writes directly, explains the key parts. |

If the AI is unsure which tier something belongs to, it **asks** before writing.

### 2.2 Hint ladder (Core code)

When I'm stuck, go **one step at a time** and stop as soon as I can continue:

1. **Concept** — explain the idea in plain words with a small example.
2. **Questions** — ask what the function must guarantee and what could go wrong.
3. **Pseudocode** — outline the steps, no Swift.
4. **Skeleton** — function signature and `// TODO` comments only.
5. **Review** — I write it; the AI reviews and points out problems **without fixing them**.
6. **Full solution** — only if I ask after steps 1–5. I then close it and rewrite it from memory.

### 2.3 Teach-back (after every Core or Support piece)

The AI asks me at least one of:

- "Walk me through this function with this input: ___."
- "What happens if this line is removed? Which test fails?"
- "Which oral exam question in `SPEC.md` §9 does this answer?"

If I can't answer, the piece is not done.

### 2.4 What the AI must not do

- Tick requirements, write test results, `docs/LLM_PROCESS.md` or `docs/REFLECTION.md`.
- Add tests, files, dependencies or features I haven't approved.
- Silently rewrite code I wrote. Suggest changes and explain why; I decide.
- Change the architecture (§4) without first proposing it as a decision-log entry in `SPEC.md` §8.

---

## 3. Project structure

```
WeatherApp/
├── App/            WeatherApp.swift (entry point, dependency setup)
├── Model/          Domain types: Forecast, DayForecast, HourForecast, Place, WeatherCondition
├── Data/
│   ├── DTO/        Codable mirrors of API JSON (OpenMeteoResponse, GeocodingResult)
│   ├── Parsing/    ForecastParser, GeocodingParser
│   ├── Network/    ForecastService, GeocodingService, HTTPClient, NetworkError
│   ├── Storage/    ForecastCache, FavouritesStore, SettingsStore
│   └── WeatherRepository.swift
├── ViewModel/      ForecastViewModel, FavouritesViewModel, SettingsViewModel
├── View/
│   ├── Search/     SearchView + subviews
│   ├── Detail/     DayDetailView + subviews
│   ├── Favourites/
│   ├── Settings/
│   └── Components/ Reusable views (WeatherIconView, ErrorStateView, LoadingView)
└── Design/         Spacing, Typography, color tokens
WeatherAppTests/
├── Fixtures/       Saved JSON responses from the real APIs
└── *Tests.swift    One test file per tested type
```

One primary type per file; the file is named after the type.

---

## 4. Architecture rules (MVVM + Repository)

| Layer | May depend on | Must not |
| ----- | ------------- | -------- |
| **View** | ViewModel, Model, Design | Call services, parse JSON, hold business logic, `import Network` |
| **ViewModel** | Repository (via protocol), Model | `import SwiftUI` for logic, know about URLs/JSON/DTOs, navigate |
| **Repository** | Services, Parsers, Storage | Know about Views or ViewModels |
| **Service** | `URLSession`, DTOs | Return DTOs past the repository; touch UI state |
| **Parser** | DTO, Model | Do I/O; it's pure and synchronous, so easy to test |
| **Model** | Foundation only | Contain `Codable` API-specific keys |

- **Data flow:** View intent → ViewModel → Repository → Service → Parser → Model → ViewModel state → View re-renders.
- **DTOs never reach the UI.** API changes stay inside `Data/`.
- **Navigation is owned by Views** (`NavigationStack` + value-based `navigationDestination`). ViewModels expose data, not routes.
- **Dependency injection via initialisers.** The ViewModel receives a `WeatherRepositoryProtocol`; tests pass a fake. No singletons except the app's composition root.

---

## 5. Swift conventions

### 5.1 Naming

- Types `UpperCamelCase`, everything else `lowerCamelCase`. Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- Names describe the role, not the type: `dailyForecasts`, not `array`; `fetchForecast(for place:)`, not `getData()`.
- Booleans read as assertions: `isLoading`, `hasCachedData`, `isFavourite`.
- Suffixes with meaning: `…View`, `…ViewModel`, `…Service`, `…Repository`, `…Store`, `…Parser`, `…DTO` (or `…Response` for API roots).
- Units in names where ambiguous: `temperatureCelsius`, `windSpeedMetresPerSecond`, `refreshIntervalMinutes`.
- British spelling of **favourite** is used consistently (matches the lab text); don't mix with "favorite".

### 5.2 Types and state

- Prefer `struct` and `enum`; use `final class` only for reference semantics (ViewModels, stores).
- ViewModels: `@Observable` + `@MainActor`. Screen state as an `enum`, so impossible states can't exist:

  ```swift
  enum LoadState<Value> {
      case idle
      case loading(previous: Value?)
      case loaded(Value, isStale: Bool)
      case failed(UserFacingError, cached: Value?)
  }
  ```
  (Shape is a starting proposal — final design is Core code and mine to decide.)
- `private` by default; widen access only when needed. `let` over `var`.
- No force unwraps (`!`) or `try!` outside tests and previews.

### 5.3 Concurrency

- `async/await` only; no completion handlers, no `DispatchQueue.main.async` in new code.
- Network and disk work happens off the main actor (services are not `@MainActor`).
- A new search **cancels** the previous `Task`; check `Task.isCancelled` / ignore results that don't match the latest request.

### 5.4 Error handling

- Services throw a typed error (`NetworkError`: `.offline`, `.timeout`, `.httpStatus(Int)`, `.decoding(...)`, …).
- The repository decides cache fallback; the ViewModel maps errors to a `UserFacingError` with a message and an optional retry action.
- Never swallow errors with an empty `catch`. Every `catch` either recovers, maps, or logs + shows state.
- No error ends in a blank screen: every failure state has a designed view (`ErrorStateView`).

### 5.5 Comments

- Comment **why**, not what. Doc comments (`///`) on public functions in `Data/` and `ViewModel/`.
- Link requirement IDs where it helps tracing: `// W-17: fall back to cached forecast when offline`.
- No commented-out code in commits.

---

## 6. UI style

- **Design tokens** in `Design/`: spacing scale (4, 8, 12, 16, 24, 32), type styles (based on Dynamic Type: `.largeTitle` for current temp, `.headline` for day names, `.subheadline` for secondary data), and semantic colours. No magic numbers in views.
- **Hierarchy:** current temperature + condition is the most prominent element; 7-day list second; extra details (wind, precipitation) secondary.
- **SF Symbols** for weather conditions, mapped once from WMO codes in a single place (`WeatherCondition`).
- **Every async screen has four designed states:** loading, loaded, empty (e.g. no search results / no favourites), error (with retry). Show cached data with a "last updated …" note when offline.
- Layouts adapt to portrait/landscape and iPhone/iPad (`ViewThatFits`, size classes); test both.
- Support Dark Mode and Dynamic Type; add accessibility labels to icons ("Light rain, 12 degrees").
- Every view has a `#Preview` with sample data, including loading and error states.

---

## 7. Testing

- Framework: Swift Testing (`@Test`) or XCTest — pick one and stick to it (see `SPEC.md` §7 Q5).
- Test names describe behaviour: `parserReturnsSevenDaysForValidResponse`, `offlineWithCacheShowsCachedForecast`.
- Arrange / Act / Assert, one behaviour per test.
- Parser tests use **real saved JSON** in `WeatherAppTests/Fixtures/`.
- ViewModel tests use a fake repository; no real network in unit tests.
- Every key test gets a **mutation test**: break the production code on purpose, confirm the test fails, record it in `docs/TEST_REPORT.md`.
- No new tests without my approval (see §2.4).

---

## 8. Git

- Small commits, one logical change each. Imperative subject ≤ 72 chars, with requirement ID when relevant: `Add ForecastParser daily mapping (W-13, W-19)`.
- Never commit API keys. Secrets go in `Secrets.xcconfig`, which is in `.gitignore`.
- The app builds and tests pass before every push.
