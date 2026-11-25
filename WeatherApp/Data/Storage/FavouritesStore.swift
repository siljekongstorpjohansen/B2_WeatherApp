import Foundation

/// Saves the favourites and their sort order as JSON in `UserDefaults` (SPEC.md §8, W-04, W-05).
///
/// `UserDefaults` is injected so tests use their own suite and never touch the app's data.
struct FavouritesStore {
    private let defaults: UserDefaults
    private let favouritesKey = "favourites"
    private let sortOrderKey = "favouritesSortOrder"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// The saved favourites; `[]` on first launch or if the saved data can't be read.
    func loadFavourites() -> [Favourite] {
        guard let data = defaults.data(forKey: favouritesKey) else {
            return []
        }
        // Corrupt data (e.g. after a model change) must not crash the app: start empty instead (W-22).
        return (try? JSONDecoder().decode([Favourite].self, from: data)) ?? []
    }

    func saveFavourites(_ favourites: [Favourite]) {
        guard let data = try? JSONEncoder().encode(favourites) else {
            return  // Can't happen for these plain types; nothing sensible to save.
        }
        defaults.set(data, forKey: favouritesKey)
    }

    /// The saved sort order; "Most viewed" if none is saved (SPEC.md §6).
    func loadSortOrder() -> FavouriteSortOrder {
        defaults.string(forKey: sortOrderKey).flatMap(FavouriteSortOrder.init(rawValue:)) ?? .mostViewed
    }

    func saveSortOrder(_ sortOrder: FavouriteSortOrder) {
        defaults.set(sortOrder.rawValue, forKey: sortOrderKey)
    }
}
