import Foundation

/// Fixed example values for previews and for running the UI before the data layer exists.
/// Numbers are based on the saved Open-Meteo fixture for Stockholm.
/// Symbols use the outlined cloud variants: with `.multicolor`, the `.fill` clouds are white
/// and disappear on light backgrounds.
enum SampleData {
    static let favouriteNames = ["Stockholm", "Oslo", "Bergen"]

    static var conditions: CurrentConditionsView.Conditions {
        CurrentConditionsView.Conditions(
            placeName: "Stockholm",
            temperature: 1.8,
            conditionText: "Drizzle",
            symbolName: "cloud.drizzle",
            high: 4.2,
            low: 0.3,
            windSpeedKilometresPerHour: 21.2,
            updatedAt: .now
        )
    }

    static var hours: [HourlyStripView.Hour] {
        let calendar = Calendar.current
        let startOfHour = calendar.dateInterval(of: .hour, for: .now)?.start ?? .now
        let samples: [(symbolName: String, conditionText: String, temperature: Double)] = [
            ("cloud.drizzle", "Drizzle", 1.8),
            ("cloud.drizzle", "Drizzle", 2.1),
            ("cloud", "Cloudy", 2.9),
            ("cloud", "Cloudy", 3.6),
            ("cloud.sun", "Partly cloudy", 4.2),
            ("sun.max.fill", "Clear", 3.8),
            ("cloud.sun", "Partly cloudy", 3.1),
            ("cloud", "Cloudy", 2.4),
            ("cloud", "Cloudy", 1.9),
            ("cloud.moon", "Partly cloudy", 1.2),
            ("moon.stars", "Clear", 0.8),
            ("moon.stars", "Clear", 0.5),
        ]
        return samples.enumerated().map { offset, sample in
            HourlyStripView.Hour(
                time: calendar.date(byAdding: .hour, value: offset, to: startOfHour) ?? startOfHour,
                isNow: offset == 0,
                symbolName: sample.symbolName,
                conditionText: sample.conditionText,
                temperature: sample.temperature
            )
        }
    }

    static var days: [DailyForecastListView.Day] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let samples: [(symbolName: String, conditionText: String, low: Double, high: Double)] = [
            ("cloud.drizzle", "Drizzle", 0.3, 4.2),
            ("cloud", "Cloudy", -1.2, 3.0),
            ("cloud.snow", "Snow", -3.4, 1.1),
            ("sun.max.fill", "Clear", -2.0, 2.4),
            ("cloud.sun", "Partly cloudy", -0.8, 3.5),
            ("cloud.rain", "Rain", 1.0, 5.6),
            ("cloud", "Cloudy", 0.4, 4.0),
        ]
        return samples.enumerated().map { offset, sample in
            DailyForecastListView.Day(
                date: calendar.date(byAdding: .day, value: offset, to: today) ?? today,
                isToday: offset == 0,
                symbolName: sample.symbolName,
                conditionText: sample.conditionText,
                low: sample.low,
                high: sample.high
            )
        }
    }
}
