import Foundation
import Observation

/// The user's favourite places, shared by the start screen (★, chips) and the Favourites tab (W-04, W-05).
///
/// Every change is saved straight away through `FavouritesStore`, so nothing is lost if the app is closed.
@Observable
@MainActor
final class FavouritesViewModel {
    private(set) var favourites: [Favourite]

    /// How the Favourites tab lists them; saved so the choice survives a restart.
    var sortOrder: FavouriteSortOrder {
        didSet { store.saveSortOrder(sortOrder) }
    }

    /// `favourites` in the chosen order — what the list and the chips show.
    var sortedFavourites: [Favourite] {
        sortOrder.sorted(favourites)
    }

    private let store: FavouritesStore
    private let now: () -> Date

    /// Two coordinates closer than this are the same place (about 1 km). Geocoding can return
    /// slightly different decimals for the same town, so exact equality would miss it (SPEC.md §8).
    private static let samePlaceTolerance = 0.01

    /// - Parameters:
    ///   - store: `FavouritesStore()` in the app; tests pass one with their own `UserDefaults` suite.
    ///   - now: the clock for "Added", fixed in tests.
    init(store: FavouritesStore, now: @escaping () -> Date = { Date() }) {
        self.store = store
        self.now = now
        favourites = store.loadFavourites()
        sortOrder = store.loadSortOrder()
    }

    /// Whether `place` is saved, compared by coordinates, not by name.
    func isFavourite(_ place: Place) -> Bool {
        favourite(matching: place) != nil
    }

    /// The ★ button: saves `place` if it isn't a favourite yet, otherwise removes it.
    func toggleFavourite(_ place: Place) {
        if let existing = favourite(matching: place) {
            remove(existing)
        } else {
            let newFavourite = Favourite(
                placeName: place.name,
                latitude: place.latitude,
                longitude: place.longitude,
                dateAdded: now()
            )
            favourites.append(newFavourite)
            store.saveFavourites(favourites)
        }
    }

    /// Counts one view, for "Most viewed".
    func recordOpen(_ favourite: Favourite) {
        guard let index = favourites.firstIndex(where: { $0.id == favourite.id }) else {
            return
        }
        favourites[index].openCount += 1
        store.saveFavourites(favourites)
    }

    func remove(_ favourite: Favourite) {
        remove([favourite])
    }

    /// Removes several at once (swipe-to-delete can delete more than one row) and saves once.
    func remove(_ favouritesToRemove: [Favourite]) {
        let idsToRemove = Set(favouritesToRemove.map(\.id))
        favourites.removeAll { idsToRemove.contains($0.id) }
        store.saveFavourites(favourites)
    }

    private func favourite(matching place: Place) -> Favourite? {
        favourites.first { favourite in
            abs(favourite.latitude - place.latitude) < Self.samePlaceTolerance
                && abs(favourite.longitude - place.longitude) < Self.samePlaceTolerance
        }
    }
}
