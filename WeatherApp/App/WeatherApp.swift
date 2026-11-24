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
    @State private var forecastViewModel = ForecastViewModel(repository: LiveWeatherRepository())

    var body: some Scene {
        WindowGroup {
            ContentView(forecastViewModel: forecastViewModel)
        }
    }
}
