//
//  ContentView.swift
//  WeatherApp
//
//  Created by Loke Östangård on 2026-11-20.
//

import SwiftUI

/// Root of the app: one tab per main screen. Navigation lives in the View layer (STYLE.md §4).
struct ContentView: View {
    /// Created in `WeatherApp`, which decides where the data comes from.
    let forecastViewModel: ForecastViewModel

    enum Tab: Hashable {
        case weather, favourites, settings
    }

    @State private var selectedTab: Tab = .weather
    /// The place shown on the Weather tab. Shared so the Favourites tab can switch it (W-05).
    @State private var selectedPlaceName: String? = SampleData.favouriteNames.first

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView(viewModel: forecastViewModel, selectedFavourite: $selectedPlaceName)
                .tabItem { Label("Weather", systemImage: "cloud.sun") }
                .tag(Tab.weather)

            FavouritesView(onOpen: { favourite in
                selectedPlaceName = favourite.placeName
                selectedTab = .weather
            })
            .tabItem { Label("Favourites", systemImage: "star") }
            .tag(Tab.favourites)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView(forecastViewModel: ForecastViewModel(repository: LiveWeatherRepository.configured()))
}
