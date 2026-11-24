import Foundation

/// Summary of one day in the 7-day forecast (W-03, W-12).
///
/// `Hashable` + `Identifiable` so views can use it directly in `List` and `NavigationLink(value:)`.
nonisolated struct DayForecast: Hashable, Identifiable, Sendable {
    /// Start of the day in the place's local time zone.
    let date: Date
    let condition: WeatherCondition
    let maxTemperatureCelsius: Double
    let minTemperatureCelsius: Double
    let precipitationMillimetres: Double
    /// Stored in m/s (Swedish convention); km/h is a display choice (W-06).
    let maxWindSpeedMetresPerSecond: Double

    /// One forecast per day, so the date is unique.
    var id: Date { date }
}
