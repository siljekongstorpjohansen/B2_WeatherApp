import SwiftUI

/// The Favourites tab (SPEC.md §6, W-04, W-05): quick access to starred places,
/// sortable by most viewed, A–Z or recently added. Data and saving live in `FavouritesViewModel`.
struct FavouritesView: View {
    /// Shared with the start screen's ★ and chips; saves every change (W-04, W-05).
    @Bindable var viewModel: FavouritesViewModel
    /// Called when a place is tapped; the parent switches to the Weather tab.
    var onOpen: (Favourite) -> Void

    private var sortedFavourites: [Favourite] {
        viewModel.sortedFavourites
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favourites.isEmpty {
                    MessageStateView(
                        title: "No favourites yet",
                        message: "Tap the star next to a place to add it here.",
                        systemImage: "star"
                    )
                } else {
                    list
                }
            }
            .navigationTitle("Favourites")
            .toolbar {
                if !viewModel.favourites.isEmpty {
                    sortMenu
                }
            }
        }
    }

    private var list: some View {
        List {
            ForEach(sortedFavourites) { favourite in
                Button {
                    open(favourite)
                } label: {
                    FavouriteRowView(favourite: favourite, sortOrder: viewModel.sortOrder)
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: delete)
        }
        // W-18: on wide screens, keep rows readable instead of stretching edge to edge.
        .frame(maxWidth: ReadableWidth.list)
        .frame(maxWidth: .infinity)
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort by", selection: $viewModel.sortOrder) {
                ForEach(FavouriteSortOrder.allCases) { order in
                    Text(order.title).tag(order)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort favourites, currently \(viewModel.sortOrder.title)")
    }

    // MARK: - Actions

    private func open(_ favourite: Favourite) {
        viewModel.recordOpen(favourite)
        onOpen(favourite)
    }

    /// `offsets` refer to the sorted list on screen, so look up ids there before removing.
    private func delete(at offsets: IndexSet) {
        viewModel.remove(offsets.map { sortedFavourites[$0] })
    }
}

#Preview("Loaded") {
    FavouritesView(viewModel: .preview(SampleData.favourites), onOpen: { _ in })
}

#Preview("Loaded – landscape", traits: .landscapeLeft) {
    FavouritesView(viewModel: .preview(SampleData.favourites), onOpen: { _ in })
}

#Preview("Empty") {
    FavouritesView(viewModel: .preview([]), onOpen: { _ in })
}

private extension FavouritesViewModel {
    /// A view model with its own throwaway `UserDefaults`, so previews never touch the app's saved data.
    static func preview(_ favourites: [Favourite]) -> FavouritesViewModel {
        let defaults = UserDefaults(suiteName: "preview-favourites-\(UUID())") ?? .standard
        let store = FavouritesStore(defaults: defaults)
        store.saveFavourites(favourites)
        return FavouritesViewModel(store: store)
    }
}
