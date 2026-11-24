import Foundation
import Testing
@testable import WeatherApp

/// `ForecastViewModel` with a fake repository, and `ForecastDisplay` with the saved fixture —
/// no network (W-22, W-23).
@MainActor
struct ForecastViewModelTests {

    // MARK: - ForecastViewModel (error-state logic)

    @Test func searchShowsLoadedForecastFromRepository() async throws {
        let forecast = try loadFixtureForecast()
        let repository = FakeWeatherRepository(forecastResult: .success(forecast))
        let viewModel = ForecastViewModel(repository: repository, now: { Self.fixtureNow })

        await viewModel.search("Stockholm")

        guard case .loaded(let display) = viewModel.state else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(display.days.count == 7)
    }

    @Test func searchShowsFailedStateWhenOffline() async {
        let repository = FakeWeatherRepository(forecastResult: .failure(.offline))
        let viewModel = ForecastViewModel(repository: repository, now: { Self.fixtureNow })

        await viewModel.search("Stockholm")

        let isFailed = if case .failed = viewModel.state { true } else { false }
        #expect(isFailed)
    }

    @Test func retryRepeatsLastSearchAfterFailure() async throws {
        let forecast = try loadFixtureForecast()
        let repository = SequenceRepository(forecastResults: [.failure(.offline), .success(forecast)])
        let viewModel = ForecastViewModel(repository: repository, now: { Self.fixtureNow })
        await viewModel.search("Stockholm")
        let failedFirst = if case .failed = viewModel.state { true } else { false }

        await viewModel.retry()

        #expect(failedFirst)
        let isLoaded = if case .loaded = viewModel.state { true } else { false }
        #expect(isLoaded)
    }

    // MARK: - ForecastDisplay (data transformation)

    @Test func displayStartsHoursAtCurrentHourAndShowsTwentyFour() throws {
        let forecast = try loadFixtureForecast()  // hourly starts 2026-11-23 00:00

        let display = ForecastDisplay(forecast: forecast, now: Self.fixtureNow)  // 08:45

        #expect(display.hours.count == 24)
        #expect(display.hours[0].time == stockholmDate(year: 2026, month: 11, day: 23, hour: 8))
        #expect(display.hours[0].isNow)
    }

    @Test func displayMarksTodayAndUsesItsHighAndLow() throws {
        let forecast = try loadFixtureForecast()  // daily[0]: 2026-11-23, max 2.8, min 1.3

        let display = ForecastDisplay(forecast: forecast, now: Self.fixtureNow)

        #expect(display.days[0].isToday)
        #expect(!display.days[1].isToday)
        #expect(display.conditions.high == 2.8)
        #expect(display.conditions.low == 1.3)
    }

    // MARK: - Helpers

    /// The fixture's `current.time`: 2026-11-23 08:45 in Stockholm.
    private static let fixtureNow: Date = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        return calendar.date(from: DateComponents(year: 2026, month: 11, day: 23, hour: 8, minute: 45))!
    }()

    private func loadFixtureForecast() throws -> Forecast {
        let url = try #require(
            Bundle(for: BundleToken.self).url(forResource: "open-meteo-forecast-stockholm", withExtension: "json")
        )
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        return try ForecastParser().parse(response, for: .stockholm)
    }

    private func stockholmDate(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}

/// Lets `Bundle(for:)` find the test bundle, where Xcode copies `Fixtures/`.
private final class BundleToken {}

/// Gives one forecast result per call, in order — so a test can fail first and succeed on retry.
/// An `actor` because it changes its own list from async calls.
private actor SequenceRepository: WeatherRepository {
    private var forecastResults: [Result<Forecast, NetworkError>]

    init(forecastResults: [Result<Forecast, NetworkError>]) {
        self.forecastResults = forecastResults
    }

    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place] {
        [.stockholm]
    }

    func forecast(for place: Place) async throws(NetworkError) -> Forecast {
        guard !forecastResults.isEmpty else { throw .unknown }
        return try forecastResults.removeFirst().get()
    }
}
