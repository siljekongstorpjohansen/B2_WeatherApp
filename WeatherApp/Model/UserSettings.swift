import Foundation

/// The user's preferences from the Settings screen (SPEC.md §6, W-06).
/// Plain values only; `SettingsStore` will persist them later (plan step 8).
struct UserSettings: Equatable, Codable {
    var temperatureUnit: TemperatureUnit = .celsius
    var windSpeedUnit: WindSpeedUnit = .kilometresPerHour
    var appearance: Appearance = .system
    var timeFormat: TimeFormat = .twentyFourHour
    var refreshInterval: RefreshInterval = .thirtyMinutes

    enum TemperatureUnit: String, CaseIterable, Codable, Identifiable {
        case celsius, fahrenheit
        var id: Self { self }

        var title: String {
            switch self {
            case .celsius: "°C"
            case .fahrenheit: "°F"
            }
        }
    }

    enum WindSpeedUnit: String, CaseIterable, Codable, Identifiable {
        case kilometresPerHour, metresPerSecond, milesPerHour
        var id: Self { self }

        var title: String {
            switch self {
            case .kilometresPerHour: "km/h"
            case .metresPerSecond: "m/s"
            case .milesPerHour: "mph"
            }
        }
    }

    enum Appearance: String, CaseIterable, Codable, Identifiable {
        case system, light, dark
        var id: Self { self }

        var title: String {
            switch self {
            case .system: "System"
            case .light: "Light"
            case .dark: "Dark"
            }
        }
    }

    enum TimeFormat: String, CaseIterable, Codable, Identifiable {
        case twentyFourHour, twelveHour
        var id: Self { self }

        var title: String {
            switch self {
            case .twentyFourHour: "24-hour"
            case .twelveHour: "12-hour"
            }
        }
    }

    /// How old the cached forecast may get before it is refreshed on open (SPEC.md §7 #4).
    enum RefreshInterval: Int, CaseIterable, Codable, Identifiable {
        case fifteenMinutes = 15
        case thirtyMinutes = 30
        case sixtyMinutes = 60
        /// Never refresh automatically; only pull-to-refresh or a new search.
        case manual = 0

        var id: Self { self }

        /// `nil` for manual, so callers can't accidentally treat it as "0 minutes".
        var minutes: Int? {
            self == .manual ? nil : rawValue
        }

        var title: String {
            switch self {
            case .manual: "Manual only"
            default: "\(rawValue) min"
            }
        }
    }
}
