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

    @Test func parserMapsExtraDailyFieldsForDayDetail() throws {
        let valid = try loadFixtureResponse()
        var daily = valid.daily
        let dayCount = daily.time.count
        daily.sunrise = Array(repeating: "2026-11-23T08:21", count: dayCount)
        daily.sunset = Array(repeating: "2026-11-23T14:53", count: dayCount)
        daily.apparentTemperatureMax = Array(repeating: -0.6, count: dayCount)
        daily.uvIndexMax = Array(repeating: 0.6, count: dayCount)
        daily.windDirection10mDominant = Array(repeating: 225, count: dayCount)
        daily.windGusts10mMax = Array(repeating: 36.0, count: dayCount)  // km/h
        let response = OpenMeteoResponse(timezone: valid.timezone, current: valid.current, hourly: valid.hourly, daily: daily)

        let day = try #require(try ForecastParser().parse(response, for: .stockholm).days.first)

        #expect(day.sunrise == stockholmDate(year: 2026, month: 11, day: 23, hour: 8, minute: 21))
        #expect(day.sunset == stockholmDate(year: 2026, month: 11, day: 23, hour: 14, minute: 53))
        #expect(day.apparentMaxTemperatureCelsius == -0.6)
        #expect(day.uvIndexMax == 0.6)
        #expect(day.dominantWindDirectionDegrees == 225)
        #expect(day.maxWindGustMetresPerSecond == 10.0)  // 36 km/h ÷ 3.6
    }

    @Test func parserLeavesExtrasNilWhenMissingOrShortWithoutFailing() throws {
        let valid = try loadFixtureResponse()  // the fixture has no extra fields at all
        var daily = valid.daily
        daily.uvIndexMax = [0.6]  // 1 value for 7 days: can't be matched to `time`
        let response = OpenMeteoResponse(timezone: valid.timezone, current: valid.current, hourly: valid.hourly, daily: daily)

        let forecast = try ForecastParser().parse(response, for: .stockholm)

        #expect(forecast.days.count == 7)
        #expect(forecast.days.allSatisfy { $0.uvIndexMax == nil && $0.sunrise == nil && $0.maxWindGustMetresPerSecond == nil })
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
