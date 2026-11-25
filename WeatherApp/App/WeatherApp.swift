//
//  WeatherApp.swift
//  WeatherApp
//
//  Created by Loke Östangård on 2026-11-20.
//

import SwiftUI

@main
struct WeatherApp: App {
    /// The one place that picks the real data source; tests pass `FakeWeatherRepository` instead (STYLE.md §4).
    @State private var forecastViewModel = ForecastViewModel(
        repository: LiveWeatherRepository.configured(),
        connectivityUpdates: ConnectivityMonitor().updates()  // W-17: banner at once, reload when back online
    )
    /// Saved on this phone in `UserDefaults` (SPEC.md §8, W-04–W-06).
    @State private var favouritesViewModel = FavouritesViewModel(store: FavouritesStore())
    @State private var settingsViewModel = SettingsViewModel(store: SettingsStore())

    var body: some Scene {
        WindowGroup {
            ContentView(
                forecastViewModel: forecastViewModel,
                favouritesViewModel: favouritesViewModel,
                settingsViewModel: settingsViewModel
            )
        }
    }
}

nonisolated extension LiveWeatherRepository {
    /// The real repository with the geocoding key from Info.plist (`Config/Secrets.xcconfig`, SPEC.md §8).
    ///
    /// Lives in `App/` so the Data layer never reads Info.plist. A missing key becomes `""`:
    /// the app still runs, and searches fail with 401 → error state (W-11, W-22).
    static func configured() -> LiveWeatherRepository {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "GeocodingAPIKey") as? String ?? ""
        return LiveWeatherRepository(geocodingService: GeocodingService(apiKey: apiKey))
    }
}
