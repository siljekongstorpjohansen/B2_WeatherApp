/// Weather condition mapped from a WMO weather code (W-12).
///
/// This is the only place that knows WMO codes, display text and SF Symbols (STYLE.md §6).
nonisolated enum WeatherCondition: Hashable, Sendable, Codable, CustomStringConvertible {
    case clear
    case mainlyClear
    case partlyCloudy
    case overcast
    case fog
    case drizzle(Intensity)
    case freezingDrizzle(Intensity)
    case rain(Intensity)
    case freezingRain(Intensity)
    case snow(Intensity)
    case snowGrains
    case rainShowers(Intensity)
    case snowShowers(Intensity)
    case thunderstorm
    case thunderstormWithHail
    case unknown

    /// How strong the precipitation is, as given by the WMO code.
    nonisolated enum Intensity: Hashable, Sendable, Codable {
        case light
        case moderate
        case heavy

        func describe(_ precipitation: String) -> String {
            switch self {
            case .light: "Light \(precipitation)"
            case .moderate: "Moderate \(precipitation)"
            case .heavy: "Heavy \(precipitation)"
            }
        }
    }

    /// Maps a WMO code (Open-Meteo `weather_code`) to a condition.
    /// Unknown codes become `.unknown` so one unexpected value never breaks a whole forecast.
    init(wmoCode: Int) {
        switch wmoCode {
        case 0: self = .clear
        case 1: self = .mainlyClear
        case 2: self = .partlyCloudy
        case 3: self = .overcast
        case 45, 48: self = .fog
        case 51: self = .drizzle(.light)
        case 53: self = .drizzle(.moderate)
        case 55: self = .drizzle(.heavy)
        case 56: self = .freezingDrizzle(.light)
        case 57: self = .freezingDrizzle(.heavy)
        case 61: self = .rain(.light)
        case 63: self = .rain(.moderate)
        case 65: self = .rain(.heavy)
        case 66: self = .freezingRain(.light)
        case 67: self = .freezingRain(.heavy)
        case 71: self = .snow(.light)
        case 73: self = .snow(.moderate)
        case 75: self = .snow(.heavy)
        case 77: self = .snowGrains
        case 80: self = .rainShowers(.light)
        case 81: self = .rainShowers(.moderate)
        case 82: self = .rainShowers(.heavy)
        case 85: self = .snowShowers(.light)
        case 86: self = .snowShowers(.heavy)
        case 95: self = .thunderstorm
        case 96, 99: self = .thunderstormWithHail
        default: self = .unknown
        }
    }

    /// Short English text for the UI, e.g. "Light rain".
    var description: String {
        switch self {
        case .clear: "Clear sky"
        case .mainlyClear: "Mainly clear"
        case .partlyCloudy: "Partly cloudy"
        case .overcast: "Overcast"
        case .fog: "Fog"
        case .drizzle(let intensity): intensity.describe("drizzle")
        case .freezingDrizzle(let intensity): intensity.describe("freezing drizzle")
        case .rain(let intensity): intensity.describe("rain")
        case .freezingRain(let intensity): intensity.describe("freezing rain")
        case .snow(let intensity): intensity.describe("snow")
        case .snowGrains: "Snow grains"
        case .rainShowers(let intensity): intensity.describe("rain showers")
        case .snowShowers(let intensity): intensity.describe("snow showers")
        case .thunderstorm: "Thunderstorm"
        case .thunderstormWithHail: "Thunderstorm with hail"
        case .unknown: "Unknown"
        }
    }

    /// SF Symbol name for this condition.
    /// Outlined cloud variants: with `.multicolor`, the `.fill` clouds are white and disappear
    /// on light backgrounds (matches the UI branch).
    var symbolName: String {
        switch self {
        case .clear: "sun.max.fill"
        case .mainlyClear, .partlyCloudy: "cloud.sun"
        case .overcast: "cloud"
        case .fog: "cloud.fog"
        case .drizzle: "cloud.drizzle"
        case .freezingDrizzle, .freezingRain: "cloud.sleet"
        case .rain(.heavy), .rainShowers(.heavy): "cloud.heavyrain"
        case .rain, .rainShowers: "cloud.rain"
        case .snow, .snowShowers: "cloud.snow"
        case .snowGrains: "snowflake"
        case .thunderstorm: "cloud.bolt.rain"
        case .thunderstormWithHail: "cloud.hail"
        case .unknown: "questionmark.circle"
        }
    }
}
