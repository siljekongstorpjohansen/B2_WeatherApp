import Foundation

/// Everything the app shows for one place: current conditions, hourly values and the next 7 days
/// (W-02, W-12, W-13).
nonisolated struct Forecast: Equatable, Sendable, Codable {
    let place: Place
    /// The place's own time zone (from Open-Meteo), so "today" means today *there*, not on the device.
    let timeZone: TimeZone
    let current: Current
    /// Every hour Open-Meteo returns (all 7 days); picking "the next 24 h" is the ViewModel's job.
    let hours: [HourForecast]
    let days: [DayForecast]

    /// Conditions right now.
    nonisolated struct Current: Equatable, Sendable, Codable {
        let time: Date
        let temperatureCelsius: Double
        let condition: WeatherCondition
        /// Stored in m/s (Swedish convention); km/h is a display choice (W-06).
        let windSpeedMetresPerSecond: Double
    }
}
