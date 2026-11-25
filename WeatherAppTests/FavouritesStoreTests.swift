import Foundation
import Testing
@testable import WeatherApp

/// `FavouritesStore` saves and loads through its own `UserDefaults` suite — the app's data is never touched (W-04, W-16).
@MainActor
struct FavouritesStoreTests {

    @Test func savedFavouritesAndSortOrderAreLoadedAgain() {
        let store = FavouritesStore(defaults: makeTestDefaults())
        let favourites = [
            Favourite(placeName: "Bergen", latitude: 60.39, longitude: 5.32, openCount: 3),
            Favourite(placeName: "Ålesund", latitude: 62.47, longitude: 6.15),
        ]

        store.saveFavourites(favourites)
        store.saveSortOrder(.alphabetical)

        #expect(store.loadFavourites() == favourites)
        #expect(store.loadSortOrder() == .alphabetical)
    }
}

/// A fresh, empty `UserDefaults` for one test.
func makeTestDefaults() -> UserDefaults {
    let suiteName = "test-\(UUID())"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
}
