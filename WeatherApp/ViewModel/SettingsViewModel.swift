import Foundation
import Observation

/// The user's settings for the Settings tab and the rest of the app (W-06).
///
/// Every change is saved straight away through `SettingsStore` — there is no Save button (SPEC.md §6).
@Observable
@MainActor
final class SettingsViewModel {
    var settings: UserSettings {
        didSet { store.save(settings) }
    }

    private let store: SettingsStore

    /// - Parameter store: `SettingsStore()` in the app; tests pass one with their own `UserDefaults` suite.
    init(store: SettingsStore) {
        self.store = store
        settings = store.load()
    }
}
