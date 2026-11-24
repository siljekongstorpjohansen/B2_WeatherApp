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
        let forecast = try await LiveWeatherRepository().forecast(for: .stockholm)

        let display = ForecastDisplay(forecast: forecast, now: Date())

        #expect(forecast.timeZone.identifier == "Europe/Stockholm")
        #expect(forecast.days.count == 7)
        #expect(display.hours.count == ForecastDisplay.hourCount)
        #expect(display.days.first?.isToday == true)
        // Visible proof in the test log that the values are live, not the fixture.
        print("Live Open-Meteo:", display.conditions)
    }
}

private let liveAPITestsEnabled = ProcessInfo.processInfo.environment["LIVE_API_TESTS"] == "1"
