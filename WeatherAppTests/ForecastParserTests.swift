import Foundation
import Testing
@testable import WeatherApp

/// `ForecastParser` with the saved Open-Meteo fixture for Stockholm — no network (W-19, W-23).
struct ForecastParserTests {

    @Test func parserReturnsSevenDaysForValidResponse() throws {
        let response = try loadFixtureResponse()

        let forecast = try ForecastParser().parse(response, for: .stockholm)

        #expect(forecast.days.count == 7)
        #expect(forecast.days[0].date == stockholmDate(year: 2026, month: 11, day: 23))
        #expect(forecast.days[0].condition == .drizzle(.moderate))
    }

    @Test func parserReturnsAllHoursForValidResponse() throws {
        let response = try loadFixtureResponse()

        let forecast = try ForecastParser().parse(response, for: .stockholm)

        #expect(forecast.hours.count == 168)
    }

    @Test func parserConvertsWindFromKilometresPerHourToMetresPerSecond() throws {
        let response = try loadFixtureResponse()  // current wind: 21.2 km/h

        let forecast = try ForecastParser().parse(response, for: .stockholm)

        #expect(abs(forecast.current.windSpeedMetresPerSecond - 5.89) < 0.01)
    }

    @Test func parserReadsTimesInPlaceTimeZone() throws {
        let response = try loadFixtureResponse()  // current time: "2026-11-23T08:45"

        let forecast = try ForecastParser().parse(response, for: .stockholm)

        #expect(forecast.current.time == stockholmDate(year: 2026, month: 11, day: 23, hour: 8, minute: 45))
    }

    @Test func parserThrowsWhenDailyArraysHaveDifferentLengths() throws {
        let valid = try loadFixtureResponse()
        let broken = OpenMeteoResponse(
            timezone: valid.timezone,
            current: valid.current,
            hourly: valid.hourly,
            daily: OpenMeteoResponse.Daily(
                time: valid.daily.time,
                weatherCode: valid.daily.weatherCode,
                temperature2mMax: Array(valid.daily.temperature2mMax.dropLast()),  // 6 instead of 7
                temperature2mMin: valid.daily.temperature2mMin,
                precipitationSum: valid.daily.precipitationSum,
                windSpeed10mMax: valid.daily.windSpeed10mMax
            )
        )

        #expect(throws: ForecastParser.ParseError.mismatchedArrayLengths(section: "daily")) {
            try ForecastParser().parse(broken, for: .stockholm)
        }
    }

    // MARK: - Helpers

    private func loadFixtureResponse() throws -> OpenMeteoResponse {
        let url = try #require(
            Bundle(for: BundleToken.self).url(forResource: "open-meteo-forecast-stockholm", withExtension: "json")
        )
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
    }

    /// An exact moment in Stockholm time, independent of the device's time zone.
    private func stockholmDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Stockholm")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
}

/// Lets `Bundle(for:)` find the test bundle, where Xcode copies `Fixtures/`.
private final class BundleToken {}
