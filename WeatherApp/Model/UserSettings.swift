import Foundation

/// The user's preferences from the Settings screen (SPEC.md §6, W-06).
/// Plain values only; `SettingsStore` will persist them later (plan step 8).
nonisolated struct UserSettings: Equatable, Codable, Sendable {
    var temperatureUnit: TemperatureUnit = .celsius
    var windSpeedUnit: WindSpeedUnit = .kilometresPerHour
    var appearance: Appearance = .system
    var timeFormat: TimeFormat = .twentyFourHour
    var refreshInterval: RefreshInterval = .thirtyMinutes

    nonisolated enum TemperatureUnit: String, CaseIterable, Codable, Identifiable, Sendable, SettingOption {
        case celsius, fahrenheit
        var id: Self { self }

        var title: String {
            switch self {
            case .celsius: "°C"
            case .fahrenheit: "°F"
            }
        }

        /// For VoiceOver, e.g. "34 degrees Fahrenheit".
        var spokenName: String {
            switch self {
            case .celsius: "Celsius"
            case .fahrenheit: "Fahrenheit"
            }
        }
    }

    nonisolated enum WindSpeedUnit: String, CaseIterable, Codable, Identifiable, Sendable, SettingOption {
        case kilometresPerHour, metresPerSecond, milesPerHour
        var id: Self { self }

        var title: String {
            switch self {
            case .kilometresPerHour: "km/h"
            case .metresPerSecond: "m/s"
            case .milesPerHour: "mph"
            }
        }

        /// For VoiceOver, e.g. "kilometres per hour".
        var spokenName: String {
            switch self {
            case .kilometresPerHour: "kilometres per hour"
            case .metresPerSecond: "metres per second"
            case .milesPerHour: "miles per hour"
            }
        }
    }

    nonisolated enum Appearance: String, CaseIterable, Codable, Identifiable, Sendable, SettingOption {
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

    nonisolated enum TimeFormat: String, CaseIterable, Codable, Identifiable, Sendable, SettingOption {
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
    nonisolated enum RefreshInterval: Int, CaseIterable, Codable, Identifiable, Sendable, SettingOption {
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

/// A choice on the Settings screen: every option has a short title, e.g. "°C" or "24-hour".
/// Lets `SettingsView` build all its pickers with one function.
nonisolated protocol SettingOption {
    var title: String { get }
}
