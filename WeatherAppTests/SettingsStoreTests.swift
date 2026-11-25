import Foundation
import Testing
@testable import WeatherApp

/// `SettingsStore` with its own `UserDefaults` suite (W-06, W-16, W-22).
@MainActor
struct SettingsStoreTests {

    @Test func savedSettingsAreLoadedAgain() {
        let store = SettingsStore(defaults: makeTestDefaults())
        var settings = UserSettings()
        settings.temperatureUnit = .fahrenheit
        settings.windSpeedUnit = .milesPerHour
        settings.refreshInterval = .manual

        store.save(settings)

        #expect(store.load() == settings)
    }

    @Test func corruptDataGivesDefaultSettingsInsteadOfCrashing() {
        let defaults = makeTestDefaults()
        defaults.set(Data("not json".utf8), forKey: "userSettings")

        let settings = SettingsStore(defaults: defaults).load()

        #expect(settings == UserSettings())
    }
}
