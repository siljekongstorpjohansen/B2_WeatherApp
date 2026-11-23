/// Decodable mirror of the Open-Meteo forecast JSON (W-19). Never leaves the Data layer.
///
/// Only the fields we use are declared; `Decodable` skips the rest (`*_units`, `elevation`, …).
/// Times stay `String`: Open-Meteo sends `2026-11-23T08:45` (no seconds, no offset) in `timezone`,
/// and turning that into a `Date` is the parser's job. Wind speeds are km/h (API default).
nonisolated struct OpenMeteoResponse: Decodable, Sendable {
    let timezone: String
    let current: Current
    let hourly: Hourly
    let daily: Daily

    nonisolated struct Current: Decodable, Sendable {
        let time: String
        let temperature2m: Double
        let weatherCode: Int
        let windSpeed10m: Double

        nonisolated enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
            case windSpeed10m = "wind_speed_10m"
        }
    }

    /// Parallel arrays (168 entries = 7 days × 24 h): index `i` in every array belongs to `time[i]`.
    nonisolated struct Hourly: Decodable, Sendable {
        let time: [String]
        let temperature2m: [Double]
        let weatherCode: [Int]
        let precipitationProbability: [Int]

        nonisolated enum CodingKeys: String, CodingKey {
            case time
            case temperature2m = "temperature_2m"
            case weatherCode = "weather_code"
            case precipitationProbability = "precipitation_probability"
        }
    }

    /// Parallel arrays: index `i` in every array belongs to `time[i]`.
    nonisolated struct Daily: Decodable, Sendable {
        let time: [String]
        let weatherCode: [Int]
        let temperature2mMax: [Double]
        let temperature2mMin: [Double]
        let precipitationSum: [Double]
        let windSpeed10mMax: [Double]

        nonisolated enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case precipitationSum = "precipitation_sum"
            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }
}
