import Foundation

/// Summary of one day in the 7-day forecast (W-03, W-12).
///
/// `Hashable` + `Identifiable` so views can use it directly in `List` and `NavigationLink(value:)`.
nonisolated struct DayForecast: Hashable, Identifiable, Sendable, Codable {
    /// Start of the day in the place's local time zone.
    let date: Date
    let condition: WeatherCondition
    let maxTemperatureCelsius: Double
    let minTemperatureCelsius: Double
    let precipitationMillimetres: Double
    /// Stored in m/s (Swedish convention); km/h is a display choice (W-06).
    let maxWindSpeedMetresPerSecond: Double

    // W-03: extras for the day detail screen. `nil` when Open-Meteo didn't send them (SPEC.md §8).
    var sunrise: Date? = nil
    var sunset: Date? = nil
    var apparentMaxTemperatureCelsius: Double? = nil
    var apparentMinTemperatureCelsius: Double? = nil
    /// 0–100, highest chance of precipitation during the day.
    var precipitationProbabilityMaxPercent: Int? = nil
    var uvIndexMax: Double? = nil
    /// Degrees the wind comes *from*: 0 = north, 90 = east.
    var dominantWindDirectionDegrees: Int? = nil
    /// Stored in m/s like `maxWindSpeedMetresPerSecond`.
    var maxWindGustMetresPerSecond: Double? = nil

    /// One forecast per day, so the date is unique.
    var id: Date { date }
}
