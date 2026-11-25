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

        // W-03: extras for the day detail screen. Optional arrays with a `nil` default, so the saved
        // fixture (which doesn't have them) still decodes and tests can build a `Daily` without them.
        // Optional elements because Open-Meteo can send `null` for single days (e.g. UV far ahead).
        var sunrise: [String?]? = nil
        var sunset: [String?]? = nil
        var apparentTemperatureMax: [Double?]? = nil
        var apparentTemperatureMin: [Double?]? = nil
        var precipitationProbabilityMax: [Int?]? = nil
        var uvIndexMax: [Double?]? = nil
        /// Degrees the wind comes from: 0 = north, 90 = east.
        var windDirection10mDominant: [Int?]? = nil
        /// km/h (API default), like `windSpeed10mMax`.
        var windGusts10mMax: [Double?]? = nil

        nonisolated enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperature2mMax = "temperature_2m_max"
            case temperature2mMin = "temperature_2m_min"
            case precipitationSum = "precipitation_sum"
            case windSpeed10mMax = "wind_speed_10m_max"
            case sunrise
            case sunset
            case apparentTemperatureMax = "apparent_temperature_max"
            case apparentTemperatureMin = "apparent_temperature_min"
            case precipitationProbabilityMax = "precipitation_probability_max"
            case uvIndexMax = "uv_index_max"
            case windDirection10mDominant = "wind_direction_10m_dominant"
            case windGusts10mMax = "wind_gusts_10m_max"
        }
    }
}
