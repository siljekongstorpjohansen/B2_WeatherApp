# TEST_REPORT.md — B2 Weather App (Appendix A)

> What is tested, how, and the results. **Result columns are filled in by us after running the tests** — the AI wrote the test plan, never the results (`SPEC.md` §1).

## 1. How to run

| What | How | Network |
| ---- | --- | ------- |
| Unit tests (Swift Testing) | Xcode ⌘U, or `xcodebuild test -scheme WeatherApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:WeatherAppTests` | None — fixtures and fakes |
| UI tests (XCTest) | ⌘U runs them too (`WeatherAppUITests`) | Real APIs |
| Live API tests | See `README.md` → *Live API tests* (`TEST_RUNNER_LIVE_API_TESTS=1`) | Real APIs, opt-in |
| UX scenarios (§4) | By hand on the Simulator (W-25) | Real APIs |

## 2. Unit tests (W-23)

W-23 asks for passing tests for ≥ 2 of: parsing, error-state logic, data transformation. We cover all three.

| Category | Suite (file) | What it proves | Tests |
| -------- | ------------ | -------------- | ----- |
| Parsing | `ForecastParserTests` | Real Open-Meteo fixture → `Forecast`: 7 days, all hours, place time zone, wind km/h → m/s, extra day-detail fields optional, mismatched arrays rejected | 7 |
| Parsing | `GeocodingParserTests` | Real geocode.maps.co fixtures → `[Place]`: order kept, empty result, invalid coordinates skipped, name fallback (å/ä/ö) | 4 |
| Parsing / validation | `CoordinateValidatorTests` | Search text → place name or coordinates; all accepted formats; out-of-range and malformed input; "59.33° N, 18.07° E" | 8 (+ parameterised cases) |
| Error-state logic | `NetworkErrorTests` | `URLError`, `CancellationError`, `DecodingError` → the right `NetworkError` case | 4 |
| Error-state logic | `ForecastViewModelTests` (first part) | Loaded / failed states, retry, coordinates without `/search`, invalid coordinates without network, cache → `offlineSince`, **newer search wins (W-34)**, **previous forecast kept while loading (W-33)**, **offline banner and reload on return (W-17)** | 11 |
| Error-state logic | `LiveWeatherRepositoryCacheTests` | Fake network: fresh data is cached; offline **and timeout** return the saved forecast; **HTTP 200 with inconsistent data → `.decoding`, no cache** | 4 |
| Data transformation | `ForecastViewModelTests` (`ForecastDisplay` part) | 24 hours from "now", today's high/low, each day's 24 hours for the detail screen, °C → °F, wind unit conversion | 5 |
| Storage | `ForecastCacheTests`, `FavouritesStoreTests`, `SettingsStoreTests` | Save → load round trip; first launch and corrupt data never crash | 6 |
| Favourites | `FavouritesViewModelTests` | Toggle, match by coordinates not name, open count, delete — all saved | 4 |

| Date | Device | Unit tests passed / total | UI tests | Notes |
| ---- | ------ | ------------------------- | -------- | ----- |
| 2026-11-25 | iPhone 17 Simulator, iOS 27.2, Xcode 27.2 | 54 / 54 passed (+ 2 live API tests skipped, opt-in) | 2 / 2 passed (launch only) | 1 build warning: `DayDetailView.swift:146` |

## 3. Mutation tests (STYLE.md §7)

Each row: break one line on purpose, run all unit tests, check that a test fails, then restore the line. A mutation that no test catches shows a gap.

| ID | File:line | Mutation | Should be caught by | Result |
| -- | --------- | -------- | ------------------- | ------ |
| M1 | `CoordinateValidator.swift:34` | Latitude range `-90...90` → `-180...180` | `latitudeAbove90IsInvalid`, `searchWithInvalidCoordinatesFailsWithoutNetwork` |`✓` |
| M2 | `GeocodingParser.swift:44` | Latitude range `-90...90` → `-180...180` | `parserSkipsResultsWithInvalidCoordinates` | `✓`|
| M3 | `ForecastParser.swift:153` | Wind `speed / 3.6` → `speed` (no km/h → m/s) | `parserConvertsWindFromKilometresPerHourToMetresPerSecond` (+ 2 more) | `✓`|
| M4 | `ForecastParser.swift:90` | Mismatched daily arrays: `throw` → `return []` | `parserThrowsWhenDailyArraysHaveDifferentLengths` | ✓|
| M5 | `NetworkError.swift:23` | `isConnectionProblem` without `.timeout` | `timeoutReturnsTheSavedForecast` | ✓|
| M6 | `ForecastViewModel.swift:172` | Remove `guard !Task.isCancelled` (stale answers allowed) | `newerSearchWinsWhenOlderAnswerArrivesLater` | ✓|
| M7 | `FavouritesViewModel.swift:27` | `samePlaceTolerance` `0.01` → `0.0` | `placeMatchesByCoordinatesNotByName` |✓ |
| M8 | `ForecastViewModel.swift:143` | Remove `guard isOffline` (reload on first "online") | `firstOnlineUpdateDoesNotReload` | ✓|
| M9 | `ForecastDisplay.swift:185` | Fahrenheit without `+ 32` | `displayConvertsTemperaturesToFahrenheit` | ✓|
| M10 | `LiveWeatherRepository.swift:86` | Parse failure `throw .decoding` → `.unknown` | `inconsistentDataWithHTTP200ThrowsDecoding` |✓|

## 4. UX scenarios (W-24)

Run on the Simulator with the real APIs. "Wi-Fi off" = turn off the Mac's Wi-Fi (the Simulator uses the Mac's network).

| ID | Start state | Action | Expected | Result | IDs |
| -- | ----------- | ------ | -------- | ------ | --- |
| UX-01 | App installed, online | Open the app | Spinner, then Stockholm: current conditions, "Updated HH:mm", 24-hour strip from "Now", 7-day list | ✓ | W-01, W-02, W-12, W-13 |
| UX-02 | Forecast shown | Search `Göteborg` | Göteborg's forecast; name shows å/ä/ö correctly | ✓| W-11, W-14 |
| UX-03 | Forecast shown | Search `59.33, 18.07` | Forecast without place search; name from reverse lookup (e.g. "Stockholm") | ✓| W-14 |
| UX-04 | Forecast shown | Search `59,33; 18,07` (comma decimals) | Same place as UX-03 | ✓| W-14, W-15 |
| UX-05 | Forecast shown | Search `91, 0` | "Couldn't load the forecast" + "Latitude must be between -90 and 90." — no request sent | ✓| W-15, W-22 |
| UX-06 | Forecast shown | Search `59.33` (one number) | Format hint "Enter latitude and longitude, e.g. 59.33, 18.07." | ✓| W-15 |
| UX-07 | Forecast shown | Search `Xqzvbnm` | "No places match "Xqzvbnm"." + "Try again" | ✓| W-22, W-34 |
| UX-08 | Forecast shown | Submit an empty search field | Nothing happens; forecast stays | ✓| W-22 |
| UX-09 | Forecast shown | Search `Oslo`, then at once `Bergen` | Bergen's forecast stays; Oslo never replaces it | ✓| W-34 |
| UX-10 | Forecast shown | Tap a day in "7 days" | Day detail: hour by hour, feels like, precipitation, wind + gusts, UV, sunrise, sunset | ✓ | W-03, W-13 |
| UX-11 | Place not a favourite | Tap ☆ | Star fills; chip appears under the search field; place listed in Favourites | ✓ | W-04 |
| UX-12 | ≥ 1 favourite | Favourites tab → tap a place | Weather tab opens with that place; "Opened N times" goes up by 1 | ✓| W-05 |
| UX-13 | 1 favourite | Swipe the row left → Delete | Row removed; "No favourites yet — Tap the star next to a place to add it here." | ✓| W-05, W-33 |
| UX-14 | Favourites incl. Örebro, Arvika, Ålesund | Sort → A–Z | Order follows the phone's language (`localizedStandardCompare`): Swedish → Arvika, Ålesund, Örebro; English → Ålesund, Arvika, Örebro | ✓| W-05 |
| UX-15 | Forecast shown | Settings → Temperature °F | All temperatures change at once, no spinner (no new request) | ✓| W-06 |
| UX-16 | Forecast shown | Settings → Wind speed m/s, then mph | Wind on start screen and day detail in the chosen unit | ✓| W-06 |
| UX-17 | Any | Settings → Appearance Dark; close and reopen the app | Dark at once; still dark after reopening | ✓| W-06, W-16 |
| UX-18 | Forecast shown | Settings → Time format 12-hour | Hour labels and "Updated" use 12-hour time | ✓| W-06 |
| UX-19 | Favourites and settings changed | Quit the app (swipe up) and reopen | Favourites, sort order and settings kept | ✓| W-16 |
| UX-20 | Forecast shown, online | Wi-Fi off | Yellow banner "You're offline. Showing data from HH:mm." appears at once; data stays | ✓| W-17 |
| UX-21 | UX-20 (banner shown) | Wi-Fi on | Banner disappears; forecast reloads by itself | ✓| W-17 |
| UX-22 | Forecast for Stockholm cached, Wi-Fi off | Search `Oslo` | Cached Stockholm forecast with its own name + banner — no crash, no blank screen | ✓| W-17, W-22 |
| UX-23 | App deleted and reinstalled, Wi-Fi off | Open the app | "Couldn't load the forecast" + "You're offline. Check your connection and try again." + "Try again" | ✓| W-17, W-22 |
| UX-24 | UX-23 | Wi-Fi on → tap "Try again" | Forecast loads | ✓| W-22 |
| UX-25 | `Config/Secrets.xcconfig` key empty, clean build | Search `Göteborg`; then tap a favourite chip | Search: error state, no crash. Favourite: loads (by coordinates, no key needed) | ✓| W-11, W-22 |
| UX-26 | Forecast shown; refresh setting "15 min" | Leave the app > 15 min, return | Forecast reloads ("Updated" time changes) | ✓| W-06 |
| UX-27 | Network Link Conditioner "Very Bad Network" | Search `Malmö` | Spinner while waiting; then forecast, or timeout message / cached data — never a blank screen | ✓| W-34, W-22 |
| UX-28 | Forecast shown | Rotate iPhone to landscape (⌘→) on every tab | Two columns on Weather and Day detail; nothing cut off that can't be scrolled to | ✓ | W-18 |
| UX-29 | Forecast shown | iPad Pro 11", portrait and landscape, every tab | Two-column Weather and Settings; Favourites list keeps a readable width | ✓ | W-18 |
| UX-30 | Forecast shown | Settings app → Accessibility → Larger Text, largest size | Text grows and wraps; nothing overlaps | ✓| W-32 |

## 5. Devices (W-18, W-25)

| Device (Simulator) | iOS | Portrait | Landscape | Date |
| ------------------ | --- | -------- | --------- | ---- |
| iPhone 17 | 27.2 | ✓ | ✓ | 2026-11-25 |
| iPad Pro 11-inch (M5) | 27.2 | ✓ | ✓ | 2026-11-25 |
