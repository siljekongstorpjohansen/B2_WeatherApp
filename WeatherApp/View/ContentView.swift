//
//  ContentView.swift
//  WeatherApp
//
//  Created by Loke Östangård on 2026-11-20.
//

import SwiftUI

/// Root of the app: one tab per main screen. Navigation lives in the View layer (STYLE.md §4).
struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem { Label("Weather", systemImage: "cloud.sun") }

            // Placeholders until plan step 8 (W-05, W-06).
            NavigationStack {
                MessageStateView(
                    title: "No favourites yet",
                    message: "Tap the star next to a place to add it here.",
                    systemImage: "star"
                )
                .navigationTitle("Favourites")
            }
            .tabItem { Label("Favourites", systemImage: "star") }

            NavigationStack {
                MessageStateView(
                    title: "Settings",
                    message: "Refresh rate and units will be set here.",
                    systemImage: "gearshape"
                )
                .navigationTitle("Settings")
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
}
