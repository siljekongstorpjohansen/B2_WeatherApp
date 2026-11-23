import SwiftUI

/// The start screen (SPEC.md §6, W-02).
///
/// TODO (plan step 6–7): replace `SampleData` with `ForecastViewModel` and choose the
/// content (forecast, loading, message) from its state.
struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedFavourite: String? = SampleData.favouriteNames.first
    @State private var isFavourite = true

    var body: some View {
        NavigationStack {
            SearchScreenLayout(
                searchText: $searchText,
                onSubmitSearch: {},
                favouriteNames: SampleData.favouriteNames,
                selectedFavourite: selectedFavourite,
                onSelectFavourite: { selectedFavourite = $0 }
            ) {
                ForecastView(
                    conditions: SampleData.conditions,
                    hours: SampleData.hours,
                    days: SampleData.days,
                    isFavourite: isFavourite,
                    onToggleFavourite: { isFavourite.toggle() }
                )
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
    }
}

#Preview {
    SearchView()
}
