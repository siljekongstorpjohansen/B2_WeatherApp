//
//  ContentView.swift
//  WeatherApp
//
//  Created by Loke Östangård on 2026-11-20.
//

import SwiftUI

/// Root of the app: one tab per main screen. Navigation lives in the View layer (STYLE.md §4).
struct ContentView: View {
    /// Created in `WeatherApp`, which decides where the data comes from and where it is saved.
    let forecastViewModel: ForecastViewModel
    let favouritesViewModel: FavouritesViewModel
    let settingsViewModel: SettingsViewModel

    enum Tab: Hashable {
        case weather, favourites, settings
    }

    @State private var selectedTab: Tab = .weather
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView(viewModel: forecastViewModel, favouritesViewModel: favouritesViewModel)
                .tabItem { Label("Weather", systemImage: "cloud.sun") }
                .tag(Tab.weather)

            FavouritesView(viewModel: favouritesViewModel, onOpen: { favourite in
                // W-05: by the saved coordinates, no geocoding (SPEC.md §8).
                selectedTab = .weather
                Task { await forecastViewModel.showForecast(for: favourite.place) }
            })
            .tabItem { Label("Favourites", systemImage: "star") }
            .tag(Tab.favourites)

            SettingsView(viewModel: settingsViewModel)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        // W-06: settings reach the whole app from here.
        .preferredColorScheme(colorScheme(for: settingsViewModel.settings.appearance))
        .environment(\.timeFormat, settingsViewModel.settings.timeFormat)
        .onChange(of: settingsViewModel.settings, initial: true) { _, settings in
            forecastViewModel.setUnits(temperature: settings.temperatureUnit, windSpeed: settings.windSpeedUnit)
        }
        .onChange(of: scenePhase) { _, phase in
            // Back in the foreground: reload if the forecast is older than the chosen interval (SPEC.md §7 #4).
            guard phase == .active else { return }
            Task { await forecastViewModel.refreshIfOlder(than: settingsViewModel.settings.refreshInterval.minutes) }
        }
    }

    /// "System" means no override: `nil` follows the phone's own setting.
    private func colorScheme(for appearance: UserSettings.Appearance) -> ColorScheme? {
        switch appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

#Preview {
    ContentView(
        forecastViewModel: ForecastViewModel(repository: LiveWeatherRepository.configured()),
        favouritesViewModel: FavouritesViewModel(store: FavouritesStore()),
        settingsViewModel: SettingsViewModel(store: SettingsStore())
    )
}
