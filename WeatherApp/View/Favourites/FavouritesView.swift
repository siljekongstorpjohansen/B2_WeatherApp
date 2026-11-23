import SwiftUI

/// The Favourites tab (SPEC.md §6, W-04, W-05): quick access to starred places,
/// sortable by most viewed, A–Z or recently added.
///
/// TODO (plan step 8): replace the local `@State` with `FavouritesViewModel` / `FavouritesStore`
/// so favourites, open counts and the chosen sort order are saved.
struct FavouritesView: View {
    @State private var favourites: [Favourite]
    @State private var sortOrder: FavouriteSortOrder = .mostViewed
    /// Called when a place is tapped; the parent switches to the Weather tab.
    var onOpen: (Favourite) -> Void

    init(favourites: [Favourite] = SampleData.favourites, onOpen: @escaping (Favourite) -> Void = { _ in }) {
        _favourites = State(initialValue: favourites)
        self.onOpen = onOpen
    }

    private var sortedFavourites: [Favourite] {
        sortOrder.sorted(favourites)
    }

    var body: some View {
        NavigationStack {
            Group {
                if favourites.isEmpty {
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
                if !favourites.isEmpty {
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
                    FavouriteRowView(favourite: favourite, sortOrder: sortOrder)
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
            Picker("Sort by", selection: $sortOrder) {
                ForEach(FavouriteSortOrder.allCases) { order in
                    Text(order.title).tag(order)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .accessibilityLabel("Sort favourites, currently \(sortOrder.title)")
    }

    // MARK: - Actions

    private func open(_ favourite: Favourite) {
        if let index = favourites.firstIndex(where: { $0.id == favourite.id }) {
            favourites[index].openCount += 1
        }
        onOpen(favourite)
    }

    /// `offsets` refer to the sorted list on screen, so look up ids there before removing.
    private func delete(at offsets: IndexSet) {
        let idsToDelete = Set(offsets.map { sortedFavourites[$0].id })
        favourites.removeAll { idsToDelete.contains($0.id) }
    }
}

#Preview("Loaded") {
    FavouritesView()
}

#Preview("Loaded – landscape", traits: .landscapeLeft) {
    FavouritesView()
}

#Preview("Empty") {
    FavouritesView(favourites: [])
}
