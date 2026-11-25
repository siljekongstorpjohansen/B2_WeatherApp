import Foundation

/// One hour of the forecast, used for the hourly strip (W-13).
nonisolated struct HourForecast: Hashable, Identifiable, Sendable, Codable {
    /// Start of the hour in the place's local time zone.
    let time: Date
    let temperatureCelsius: Double
    let condition: WeatherCondition
    /// 0–100.
    let precipitationProbabilityPercent: Int

    /// One forecast per hour, so the time is unique.
    var id: Date { time }
}
