import Foundation

/// Saves the user's settings as JSON in `UserDefaults` (SPEC.md §8, W-06).
///
/// `UserDefaults` is injected so tests use their own suite and never touch the app's data.
struct SettingsStore {
    private let defaults: UserDefaults
    private let settingsKey = "userSettings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// The saved settings; the defaults on first launch or if the saved data can't be read.
    func load() -> UserSettings {
        guard let data = defaults.data(forKey: settingsKey) else {
            return UserSettings()
        }
        // Corrupt data must not crash the app: fall back to the defaults (W-22).
        return (try? JSONDecoder().decode(UserSettings.self, from: data)) ?? UserSettings()
    }

    func save(_ settings: UserSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return  // Can't happen for these plain types; nothing sensible to save.
        }
        defaults.set(data, forKey: settingsKey)
    }
}
