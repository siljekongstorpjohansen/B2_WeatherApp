import SwiftUI

/// The start screen (SPEC.md §6, W-02): search, favourite chips, and the forecast from `ForecastViewModel`.
struct SearchView: View {
    let viewModel: ForecastViewModel
    @State private var searchText = ""
    /// Owned by `ContentView`, so the Favourites tab can choose which place to show.
    @Binding var selectedFavourite: String?
    @State private var isFavourite = true

    var body: some View {
        NavigationStack {
            SearchScreenLayout(
                searchText: $searchText,
                onSubmitSearch: submitSearch,
                favouriteNames: SampleData.favouriteNames,
                selectedFavourite: selectedFavourite,
                onSelectFavourite: { selectedFavourite = $0 }
            ) {
                content
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Date.self) { date in
                // Placeholder until DayDetailView exists (plan step 7, W-03).
                MessageStateView(
                    title: "Day details",
                    message: "The full forecast for this day comes in a later step.",
                    systemImage: "calendar"
                )
                .navigationTitle(date.formatted(.dateTime.weekday(.wide)))
            }
        }
        // Runs when the screen appears and whenever a chip or the Favourites tab picks another place (W-05).
        .task(id: selectedFavourite) {
            await viewModel.search(selectedFavourite ?? Place.stockholm.name)
        }
    }

    /// One view per ViewModel state, so the screen is never blank (W-22, W-33).
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            MessageStateView(
                title: "Find your weather",
                message: "Search for a city or enter coordinates.",
                systemImage: "mappin.and.ellipse"
            )
        case .loading:
            // Plain spinner for now; the old forecast dimmed under it comes in plan step 9 (SPEC.md §8).
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel("Loading forecast")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let display):
            ForecastView(
                conditions: display.conditions,
                hours: display.hours,
                days: display.days,
                isFavourite: isFavourite,
                onToggleFavourite: { isFavourite.toggle() }
            )
        case .failed(let message):
            MessageStateView(
                title: "Couldn't load the forecast",
                message: message,
                systemImage: "icloud.slash",
                actionTitle: "Try again",
                action: { Task { await viewModel.retry() } }
            )
        }
    }

    private func submitSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        Task { await viewModel.search(query) }
    }
}

#Preview {
    // Real Open-Meteo data in the canvas; every state with sample data is in `SearchScreenLayout`'s previews.
    SearchView(
        viewModel: ForecastViewModel(repository: LiveWeatherRepository.configured()),
        selectedFavourite: .constant(SampleData.favouriteNames.first)
    )
}
