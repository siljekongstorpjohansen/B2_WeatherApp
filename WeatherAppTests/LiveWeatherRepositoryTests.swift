import Foundation
import Testing
@testable import WeatherApp

/// Proves the real Open-Meteo API works through every layer except the UI (W-10, W-27).
///
/// Skipped by default so normal test runs never hit the network or the daily request limit.
/// Run with: `TEST_RUNNER_LIVE_API_TESTS=1 xcodebuild test …` (xcodebuild passes `TEST_RUNNER_*`
/// variables to the tests without the prefix).
struct LiveWeatherRepositoryTests {

    @Test(.enabled(if: liveAPITestsEnabled, "Set LIVE_API_TESTS=1 to call the real Open-Meteo API"))
    func liveForecastForStockholmGoesThroughAllLayers() async throws {
        let forecast = try await LiveWeatherRepository.configured().forecast(for: .stockholm)

        let display = ForecastDisplay(forecast: forecast, now: Date())

        #expect(forecast.timeZone.identifier == "Europe/Stockholm")
        #expect(forecast.days.count == 7)
        #expect(display.hours.count == ForecastDisplay.hourCount)
        #expect(display.days.first?.isToday == true)
        // Visible proof in the test log that the values are live, not the fixture.
        print("Live Open-Meteo:", display.conditions)
    }

    /// geocode.maps.co → Open-Meteo, the whole search path. Needs the key in `Config/Secrets.xcconfig`;
    /// without it the search throws `.httpStatus(code: 401, …)` (W-11).
    @Test(.enabled(if: liveAPITestsEnabled, "Set LIVE_API_TESTS=1 to call the real geocoding and forecast APIs"))
    func liveSearchForGoteborgFindsPlaceAndItsForecast() async throws {
        let repository = LiveWeatherRepository.configured()

        let places = try await repository.searchPlaces(matching: "Göteborg")
        let first = try #require(places.first)
        let forecast = try await repository.forecast(for: first)

        #expect(first.name.contains("Göteborg"))  // å/ä/ö survive the URL encoding and the parser
        #expect(abs(first.latitude - 57.7) < 0.5)
        #expect(abs(first.longitude - 12.0) < 0.5)
        #expect(forecast.days.count == 7)
        print("Live geocoding:", first, "→", forecast.timeZone.identifier)
    }
}

private let liveAPITestsEnabled = ProcessInfo.processInfo.environment["LIVE_API_TESTS"] == "1"
