import SwiftUI

/// The start screen (SPEC.md §6, W-02): search, favourite chips, and the forecast from `ForecastViewModel`.
struct SearchView: View {
    let viewModel: ForecastViewModel
    /// Shared with the Favourites tab, so the ★ and the chips show the same saved list (W-04, W-05).
    let favouritesViewModel: FavouritesViewModel
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            SearchScreenLayout(
                searchText: $searchText,
                onSubmitSearch: submitSearch,
                favouriteNames: favouritesViewModel.sortedFavourites.map(\.placeName),
                selectedFavourite: selectedChipName,
                onSelectFavourite: openFavourite(named:),
                // W-17: the yellow banner when the shown forecast came from the cache (SPEC.md §6).
                offlineSince: viewModel.offlineSince
            ) {
                content
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Date.self) { date in
                dayDetailDestination(for: date)
            }
        }
        // First appearance only: later visits keep what the user chose (`.task` reruns on every visit).
        .task {
            guard case .idle = viewModel.state else { return }
            // Most viewed favourite first; Stockholm on first launch (SPEC.md §6).
            let startPlace = favouritesViewModel.sortedFavourites.first?.place ?? .stockholm
            await viewModel.showForecast(for: startPlace)
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
                timeZone: display.timeZone,
                isFavourite: favouritesViewModel.isFavourite(display.place),
                onToggleFavourite: { favouritesViewModel.toggleFavourite(display.place) }
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

    /// W-03: the 7-day list pushes the tapped day's date; the details come from the loaded forecast.
    @ViewBuilder
    private func dayDetailDestination(for date: Date) -> some View {
        if case .loaded(let display) = viewModel.state,
           let detail = display.dayDetails.first(where: { $0.date == date }) {
            DayDetailView(detail: detail)
        } else {
            // E.g. a new search started while this screen was open (SPEC.md §6).
            MessageStateView(
                title: "Day not available",
                message: "Search again to see this day's forecast.",
                systemImage: "calendar.badge.exclamationmark"
            )
        }
    }

    /// The chip to highlight: the shown place, if it is a favourite.
    private var selectedChipName: String? {
        guard case .loaded(let display) = viewModel.state, favouritesViewModel.isFavourite(display.place) else {
            return nil
        }
        return display.place.name
    }

    /// A chip tap counts as an open and loads the favourite by its coordinates (SPEC.md §8).
    private func openFavourite(named name: String) {
        guard let favourite = favouritesViewModel.favourites.first(where: { $0.placeName == name }) else {
            return
        }
        favouritesViewModel.recordOpen(favourite)
        Task { await viewModel.showForecast(for: favourite.place) }
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
        favouritesViewModel: FavouritesViewModel(store: FavouritesStore())
    )
}
