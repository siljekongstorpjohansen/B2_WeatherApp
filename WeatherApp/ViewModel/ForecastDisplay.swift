import Foundation

/// The forecast in exactly the shape the UI branch's views take (SPEC.md §8, W-12, W-13).
///
/// `Conditions`, `Hour` and `Day` mirror `CurrentConditionsView.Conditions`, `HourlyStripView.Hour`
/// and `DailyForecastListView.Day` field by field, so a view only copies values across.
/// Pure — `now` is passed in — so tests can fix the clock (W-23).
nonisolated struct ForecastDisplay: Equatable, Sendable {
    let conditions: Conditions
    let hours: [Hour]
    let days: [Day]

    nonisolated struct Conditions: Equatable, Sendable {
        let placeName: String
        let temperature: Double
        let conditionText: String
        let symbolName: String
        let high: Double
        let low: Double
        let windSpeedKilometresPerHour: Double
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

    /// How many hours the hourly strip shows (Silje's SPEC: "next 24 h").
    static let hourCount = 24

    /// - Parameters:
    ///   - forecast: the parsed forecast.
    ///   - now: the current time. Built right after a fetch, so it is also "Updated …".
    init(forecast: Forecast, now: Date) {
        // Compare dates in the place's time zone: 00:30 in Stockholm is still "yesterday" in London.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = forecast.timeZone

        // Hours: start at the hour that contains `now` (08:45 → the 08:00 hour), then take 24.
        let currentHourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        let upcomingHours = forecast.hours.filter { $0.time >= currentHourStart }.prefix(Self.hourCount)
        hours = upcomingHours.map { hour in
            Hour(
                time: hour.time,
                isNow: hour.time == currentHourStart,
                symbolName: hour.condition.symbolName,
                conditionText: hour.condition.description,
                temperature: hour.temperatureCelsius
            )
        }

        days = forecast.days.map { day in
            Day(
                date: day.date,
                isToday: calendar.isDate(day.date, inSameDayAs: now),
                symbolName: day.condition.symbolName,
                conditionText: day.condition.description,
                low: day.minTemperatureCelsius,
                high: day.maxTemperatureCelsius
            )
        }

        // High/low come from today's daily values. If no day is today (old data after midnight),
        // show the current temperature rather than another day's range.
        let today = forecast.days.first { calendar.isDate($0.date, inSameDayAs: now) }
        let current = forecast.current
        conditions = Conditions(
            placeName: forecast.place.name,
            temperature: current.temperatureCelsius,
            conditionText: current.condition.description,
            symbolName: current.condition.symbolName,
            high: today?.maxTemperatureCelsius ?? current.temperatureCelsius,
            low: today?.minTemperatureCelsius ?? current.temperatureCelsius,
            // The model stores m/s (SPEC.md §8); Silje's view field is km/h until settings pick a unit (W-06).
            windSpeedKilometresPerHour: current.windSpeedMetresPerSecond * 3.6,
            updatedAt: now
        )
    }
}
