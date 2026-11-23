import SwiftUI

/// The frame of the start screen: search field and favourite chips on top, then whatever
/// the current state needs (forecast, message, …). Which content to show is decided by
/// the caller — later `ForecastViewModel`'s state, for now sample data.
struct SearchScreenLayout<Content: View>: View {
    @Binding var searchText: String
    var onSubmitSearch: () -> Void
    let favouriteNames: [String]
    let selectedFavourite: String?
    var onSelectFavourite: (String) -> Void
    var offlineSince: Date? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: Spacing.md) {
            SearchFieldView(text: $searchText, onSubmit: onSubmitSearch)

            if !favouriteNames.isEmpty {
                FavouriteChipsView(
                    placeNames: favouriteNames,
                    selectedPlaceName: selectedFavourite,
                    onSelect: onSelectFavourite
                )
            }

            if let offlineSince {
                OfflineBannerView(lastUpdated: offlineSince)
            }

            content
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }
}

// MARK: - Previews of every state in SPEC.md §6

private struct StatePreview<Content: View>: View {
    var favouriteNames = SampleData.favouriteNames
    var searchText = ""
    var offlineSince: Date? = nil
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack {
            SearchScreenLayout(
                searchText: .constant(searchText),
                onSubmitSearch: {},
                favouriteNames: favouriteNames,
                selectedFavourite: favouriteNames.first,
                onSelectFavourite: { _ in },
                offlineSince: offlineSince
            ) {
                content
            }
        }
    }
}

private var sampleForecast: ForecastView {
    ForecastView(
        conditions: SampleData.conditions,
        hours: SampleData.hours,
        days: SampleData.days,
        isFavourite: true,
        onToggleFavourite: {}
    )
}

#Preview("Loaded") {
    StatePreview { sampleForecast }
}

#Preview("Loaded – landscape", traits: .landscapeLeft) {
    StatePreview { sampleForecast }
}

#Preview("First launch") {
    StatePreview(favouriteNames: []) {
        MessageStateView(
            title: "Find your weather",
            message: "Search for a city or enter coordinates.",
            systemImage: "mappin.and.ellipse"
        )
    }
}

#Preview("Loading") {
    StatePreview { sampleForecast.loadingOverlay(isLoading: true) }
}

#Preview("Offline, cached") {
    StatePreview(offlineSince: .now.addingTimeInterval(-3 * 60 * 60)) { sampleForecast }
}

#Preview("Error, no cache") {
    StatePreview(favouriteNames: []) {
        MessageStateView(
            title: "Couldn't load the forecast",
            message: "Check your connection and try again.",
            systemImage: "icloud.slash",
            actionTitle: "Try again",
            action: {}
        )
    }
}

#Preview("No search results") {
    StatePreview(searchText: "Xqzvbnm") {
        MessageStateView(
            title: "No places found",
            message: "No results for \u{201C}Xqzvbnm\u{201D}. Check the spelling or try coordinates.",
            systemImage: "magnifyingglass"
        )
    }
}
