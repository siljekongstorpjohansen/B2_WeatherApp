import Foundation

/// The forecast in exactly the shape the UI branch's views take (SPEC.md §8, W-12, W-13).
///
/// `Conditions`, `Hour` and `Day` mirror `CurrentConditionsView.Conditions`, `HourlyStripView.Hour`
/// and `DailyForecastListView.Day` field by field, so a view only copies values across.
/// Pure — `now` is passed in — so tests can fix the clock (W-23).
/// Temperatures and wind are already in the units chosen in Settings; the model stays °C and m/s (SPEC.md §8).
nonisolated struct ForecastDisplay: Equatable, Sendable {
    /// The place shown, so the ★ can save its coordinates (W-04).
    let place: Place
    /// The place's time zone, for every time label (SPEC.md §8).
    let timeZone: TimeZone
    let conditions: Conditions
    let hours: [Hour]
    let days: [Day]
    /// One per day, for `DayDetailView` (W-03).
    let dayDetails: [DayDetail]

    nonisolated struct Conditions: Equatable, Sendable {
        let placeName: String
        let temperature: Double
        let conditionText: String
        let symbolName: String
        let high: Double
        let low: Double
        let windSpeed: Double
        let windSpeedUnit: UserSettings.WindSpeedUnit
        /// For the raised "°C" / "°F" next to the large temperature (SPEC.md §6).
        let temperatureUnit: UserSettings.TemperatureUnit
        let updatedAt: Date
    }

    nonisolated struct Hour: Equatable, Identifiable, Sendable {
        let time: Date
        let isNow: Bool
        let symbolName: String
        let conditionText: String
        let temperature: Double

        var id: Date { time }
    }

    nonisolated struct Day: Equatable, Identifiable, Sendable {
        let date: Date
        let isToday: Bool
        let symbolName: String
        let conditionText: String
        let low: Double
        let high: Double

        var id: Date { date }
    }

    /// Everything `DayDetailView` shows for one day, in the chosen display units (W-03).
    /// Optional values are the extras Open-Meteo may leave out; the view shows "—".
    nonisolated struct DayDetail: Equatable, Identifiable, Sendable {
        let date: Date
        /// The place's time zone, so sunrise and sunset show local time there.
        let timeZone: TimeZone
        let symbolName: String
        let conditionText: String
        let high: Double
        let low: Double
        /// That day's hours (00–23 in the place's time zone).
        let hours: [Hour]
        let precipitationMillimetres: Double
        let precipitationProbabilityPercent: Int?
        let maxWindSpeed: Double
        let maxWindGust: Double?
        let windSpeedUnit: UserSettings.WindSpeedUnit
        /// Degrees the wind comes from: 0 = north, 90 = east.
        let windDirectionDegrees: Int?
        let feelsLikeHigh: Double?
        let feelsLikeLow: Double?
        let uvIndex: Double?
        let sunrise: Date?
        let sunset: Date?

        var id: Date { date }
    }

    /// How many hours the hourly strip shows (Silje's SPEC: "next 24 h").
    static let hourCount = 24

    /// - Parameters:
    ///   - forecast: the parsed forecast.
    ///   - now: the current time. Built right after a fetch, so it is also "Updated …".
    ///   - updatedAt: when the data was fetched, if not `now` — the cache time when offline (W-17).
    ///   - temperatureUnit, windSpeedUnit: from Settings (W-06); the defaults match the API.
    init(
        forecast: Forecast,
        now: Date,
        updatedAt: Date? = nil,
        temperatureUnit: UserSettings.TemperatureUnit = .celsius,
        windSpeedUnit: UserSettings.WindSpeedUnit = .kilometresPerHour
    ) {
        // Every number goes through one of these, so no value can skip the conversion (W-06).
        let temperature = { (celsius: Double) in Self.convert(celsius, to: temperatureUnit) }
        let wind = { (metresPerSecond: Double) in Self.convert(metresPerSecond, to: windSpeedUnit) }

        place = forecast.place
        timeZone = forecast.timeZone
        // Compare dates in the place's time zone: 00:30 in Stockholm is still "yesterday" in London.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = forecast.timeZone

        // Hours: start at the hour that contains `now` (08:45 → the 08:00 hour), then take 24.
        let currentHourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let upcomingHours = forecast.hours.filter { $0.time >= currentHourStart }.prefix(Self.hourCount)
        hours = upcomingHours.map { hour in
            Self.makeHour(hour, isNow: hour.time == currentHourStart, temperature: temperature)
        }

        days = forecast.days.map { day in
            Day(
                date: day.date,
                isToday: calendar.isDate(day.date, inSameDayAs: now),
                symbolName: day.condition.symbolName,
                conditionText: day.condition.description,
                low: temperature(day.minTemperatureCelsius),
                high: temperature(day.maxTemperatureCelsius)
            )
        }

        // W-03: one detail per day, with the hours that fall on that day in the place's time zone.
        dayDetails = forecast.days.map { day in
            let hoursOfDay = forecast.hours.filter { calendar.isDate($0.time, inSameDayAs: day.date) }
            return DayDetail(
                date: day.date,
                timeZone: forecast.timeZone,
                symbolName: day.condition.symbolName,
                conditionText: day.condition.description,
                high: temperature(day.maxTemperatureCelsius),
                low: temperature(day.minTemperatureCelsius),
                hours: hoursOfDay.map { Self.makeHour($0, isNow: false, temperature: temperature) },
                precipitationMillimetres: day.precipitationMillimetres,
                precipitationProbabilityPercent: day.precipitationProbabilityMaxPercent,
                maxWindSpeed: wind(day.maxWindSpeedMetresPerSecond),
                maxWindGust: day.maxWindGustMetresPerSecond.map(wind),
                windSpeedUnit: windSpeedUnit,
                windDirectionDegrees: day.dominantWindDirectionDegrees,
                feelsLikeHigh: day.apparentMaxTemperatureCelsius.map(temperature),
                feelsLikeLow: day.apparentMinTemperatureCelsius.map(temperature),
                uvIndex: day.uvIndexMax,
                sunrise: day.sunrise,
                sunset: day.sunset
            )
        }

        // High/low come from today's daily values. If no day is today (old data after midnight),
        // show the current temperature rather than another day's range.
        let today = forecast.days.first { calendar.isDate($0.date, inSameDayAs: now) }
        let current = forecast.current
        conditions = Conditions(
            placeName: forecast.place.name,
            temperature: temperature(current.temperatureCelsius),
            conditionText: current.condition.description,
            symbolName: current.condition.symbolName,
            high: temperature(today?.maxTemperatureCelsius ?? current.temperatureCelsius),
            low: temperature(today?.minTemperatureCelsius ?? current.temperatureCelsius),
            windSpeed: wind(current.windSpeedMetresPerSecond),
            windSpeedUnit: windSpeedUnit,
            temperatureUnit: temperatureUnit,
            updatedAt: updatedAt ?? now
        )
    }

    /// One model hour → the strip's `Hour`. Shared by the start screen and the day detail screen.
    private static func makeHour(_ hour: HourForecast, isNow: Bool, temperature: (Double) -> Double) -> Hour {
        Hour(
            time: hour.time,
            isNow: isNow,
            symbolName: hour.condition.symbolName,
            conditionText: hour.condition.description,
            temperature: temperature(hour.temperatureCelsius)
        )
    }

    // MARK: - Unit conversion (W-06)

    static func convert(_ celsius: Double, to unit: UserSettings.TemperatureUnit) -> Double {
        switch unit {
        case .celsius: celsius
        case .fahrenheit: celsius * 9 / 5 + 32
        }
    }

    /// The model stores m/s (SPEC.md §8). 1 m/s = 3.6 km/h ≈ 2.237 mph.
    static func convert(_ metresPerSecond: Double, to unit: UserSettings.WindSpeedUnit) -> Double {
        switch unit {
        case .kilometresPerHour: metresPerSecond * 3.6
        case .metresPerSecond: metresPerSecond
        case .milesPerHour: metresPerSecond * 3600 / 1609.344
        }
    }
}
