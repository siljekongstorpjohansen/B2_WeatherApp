import Foundation

/// Turns the decoded Open-Meteo response into our `Forecast` model (W-19).
///
/// Pure and synchronous — no network, no disk — so it can be tested with a saved fixture (W-23).
nonisolated struct ForecastParser {

    /// Why parsing can fail even when the HTTP request succeeded (oral Q4).
    nonisolated enum ParseError: Error, Equatable {
        case unknownTimeZone(String)
        case invalidDate(String)
        case mismatchedArrayLengths(section: String)
    }

    /// Builds a `Forecast` for `place` from a decoded Open-Meteo response.
    /// - Throws: `ParseError` if the time zone, a date or the array lengths are wrong.
    func parse(_ response: OpenMeteoResponse, for place: Place) throws -> Forecast {
        // Open-Meteo times have no offset; they are local to `timezone` (CONTEXT.md §5).
        guard let timeZone = TimeZone(identifier: response.timezone) else {
            throw ParseError.unknownTimeZone(response.timezone)
        }
        let dateTimeFormatter = makeFormatter(format: "yyyy-MM-dd'T'HH:mm", timeZone: timeZone)
        let dateFormatter = makeFormatter(format: "yyyy-MM-dd", timeZone: timeZone)

        let current = try parseCurrent(response.current, using: dateTimeFormatter)
        let hours = try parseHours(response.hourly, using: dateTimeFormatter)
        let days = try parseDays(response.daily, using: dateFormatter)

        return Forecast(place: place, timeZone: timeZone, current: current, hours: hours, days: days)
    }

    // MARK: - Sections

    private func parseCurrent(
        _ current: OpenMeteoResponse.Current,
        using formatter: DateFormatter
    ) throws -> Forecast.Current {
        let time = try date(from: current.time, using: formatter)
        return Forecast.Current(
            time: time,
            temperatureCelsius: current.temperature2m,
            condition: WeatherCondition(wmoCode: current.weatherCode),
            windSpeedMetresPerSecond: metresPerSecond(fromKilometresPerHour: current.windSpeed10m)
        )
    }

    private func parseHours(
        _ hourly: OpenMeteoResponse.Hourly,
        using formatter: DateFormatter
    ) throws -> [HourForecast] {
        // Parallel arrays: index i must mean the same hour in every array,
        // so a short array would crash (index out of range) or shift values to the wrong hour.
        let count = hourly.time.count
        guard hourly.temperature2m.count == count,
              hourly.weatherCode.count == count,
              hourly.precipitationProbability.count == count
        else {
            throw ParseError.mismatchedArrayLengths(section: "hourly")
        }

        var hours: [HourForecast] = []
        for index in 0..<count {
            let time = try date(from: hourly.time[index], using: formatter)
            hours.append(HourForecast(
                time: time,
                temperatureCelsius: hourly.temperature2m[index],
                condition: WeatherCondition(wmoCode: hourly.weatherCode[index]),
                precipitationProbabilityPercent: hourly.precipitationProbability[index]
            ))
        }
        return hours
    }

    private func parseDays(
        _ daily: OpenMeteoResponse.Daily,
        using formatter: DateFormatter
    ) throws -> [DayForecast] {
        // Same parallel-array check as `parseHours`.
        let count = daily.time.count
        guard daily.weatherCode.count == count,
              daily.temperature2mMax.count == count,
              daily.temperature2mMin.count == count,
              daily.precipitationSum.count == count,
              daily.windSpeed10mMax.count == count
        else {
            throw ParseError.mismatchedArrayLengths(section: "daily")
        }

        var days: [DayForecast] = []
        for index in 0..<count {
            let date = try date(from: daily.time[index], using: formatter)
            days.append(DayForecast(
                date: date,
                condition: WeatherCondition(wmoCode: daily.weatherCode[index]),
                maxTemperatureCelsius: daily.temperature2mMax[index],
                minTemperatureCelsius: daily.temperature2mMin[index],
                precipitationMillimetres: daily.precipitationSum[index],
                maxWindSpeedMetresPerSecond: metresPerSecond(fromKilometresPerHour: daily.windSpeed10mMax[index])
            ))
        }
        return days
    }

    // MARK: - Helpers

    private func makeFormatter(format: String, timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        // Fixed locale + calendar so the user's region or 12/24-hour setting can't change parsing.
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }

    private func date(from text: String, using formatter: DateFormatter) throws -> Date {
        guard let date = formatter.date(from: text) else {
            throw ParseError.invalidDate(text)
        }
        return date
    }

    /// Open-Meteo sends km/h (API default); the model stores m/s (SPEC.md §8). 1 m/s = 3.6 km/h.
    private func metresPerSecond(fromKilometresPerHour speed: Double) -> Double {
        speed / 3.6
    }
}
