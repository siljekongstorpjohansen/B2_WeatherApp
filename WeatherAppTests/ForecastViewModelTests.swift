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

    @Test func searchWithCoordinatesSkipsPlaceSearchAndUsesLookedUpName() async throws {
        let forecast = try loadFixtureForecast()
        // If the ViewModel called place search, it would get this error and fail.
        let repository = FakeWeatherRepository(
            placesResult: .failure(.unknown),
            forecastResult: .success(forecast),
            reverseName: "Lookup Town"
        )
        let viewModel = ForecastViewModel(repository: repository, now: { Self.fixtureNow })

        await viewModel.search("59.33, 18.07")

        guard case .loaded(let display) = viewModel.state else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(display.conditions.placeName == "Lookup Town")
    }

    @Test func searchWithInvalidCoordinatesFailsWithoutNetwork() async {
        // Every network answer is "offline"; the message must come from the validator instead.
        let repository = FakeWeatherRepository(placesResult: .failure(.offline), forecastResult: .failure(.offline))
        let viewModel = ForecastViewModel(repository: repository, now: { Self.fixtureNow })

        await viewModel.search("91, 0")

        #expect(viewModel.state == .failed(message: "Latitude must be between -90 and 90."))
    }

    @Test func cachedForecastSetsOfflineSinceAndShowsItsTime() async throws {
        let forecast = try loadFixtureForecast()
        let savedAt = Self.fixtureNow.addingTimeInterval(-3 * 60 * 60)  // saved 3 hours earlier
        let repository = FakeWeatherRepository(forecastResult: .success(forecast), cachedAt: savedAt)
        let viewModel = ForecastViewModel(repository: repository, now: { Self.fixtureNow })

        await viewModel.showForecast(for: .stockholm)

        #expect(viewModel.offlineSince == savedAt)
        guard case .loaded(let display) = viewModel.state else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
            return
        }
        #expect(display.conditions.updatedAt == savedAt)  // "Updated …" shows the data's age, not now
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

    @Test func displayGroupsEachDaysTwentyFourHoursForDayDetail() throws {
        let forecast = try loadFixtureForecast()  // 168 hours = 7 days × 24

        let display = ForecastDisplay(forecast: forecast, now: Self.fixtureNow)

        let secondDay = display.dayDetails[1]  // 2026-11-24
        #expect(display.dayDetails.count == 7)
        #expect(secondDay.hours.count == 24)
        #expect(secondDay.hours.first?.time == stockholmDate(year: 2026, month: 11, day: 24, hour: 0))
        #expect(secondDay.hours.last?.time == stockholmDate(year: 2026, month: 11, day: 24, hour: 23))
    }

    @Test func displayConvertsTemperaturesToFahrenheit() throws {
        let forecast = try loadFixtureForecast()  // today: max 2.8 °C, min 1.3 °C

        let display = ForecastDisplay(forecast: forecast, now: Self.fixtureNow, temperatureUnit: .fahrenheit)

        #expect(abs(display.conditions.high - 37.04) < 0.001)  // 2.8 × 9/5 + 32
        #expect(abs(display.conditions.low - 34.34) < 0.001)   // 1.3 × 9/5 + 32
    }

    @Test func displayConvertsWindToTheChosenUnit() throws {
        let forecast = try loadFixtureForecast()  // current wind 21.2 km/h in the JSON → 5.89 m/s in the model
        let metresPerSecond = forecast.current.windSpeedMetresPerSecond

        let inMetres = ForecastDisplay(forecast: forecast, now: Self.fixtureNow, windSpeedUnit: .metresPerSecond)
        let inMiles = ForecastDisplay(forecast: forecast, now: Self.fixtureNow, windSpeedUnit: .milesPerHour)

        #expect(inMetres.conditions.windSpeed == metresPerSecond)
        #expect(abs(inMiles.conditions.windSpeed - 13.17) < 0.01)  // 21.2 km/h ≈ 13.17 mph
        #expect(inMiles.conditions.windSpeedUnit == .milesPerHour)
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

    func forecast(for place: Place) async throws(NetworkError) -> LoadedForecast {
        guard !forecastResults.isEmpty else { throw .unknown }
        return LoadedForecast(forecast: try forecastResults.removeFirst().get(), cachedAt: nil)
    }

    func cachedForecast() async -> LoadedForecast? {
        nil
    }

    func placeName(latitude: Double, longitude: Double) async -> String? {
        nil
    }
}
