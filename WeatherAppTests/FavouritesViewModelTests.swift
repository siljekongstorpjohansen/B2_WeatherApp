import Foundation
import Testing
@testable import WeatherApp

/// `FavouritesViewModel`: the ★ toggle, matching by coordinates, open counts and deleting —
/// each change saved (W-04, W-05, W-23).
@MainActor
struct FavouritesViewModelTests {

    private static let bergen = Place(name: "Bergen", latitude: 60.39, longitude: 5.32)

    @Test func toggleAddsAPlaceAndTogglingAgainRemovesIt() {
        let viewModel = FavouritesViewModel(store: FavouritesStore(defaults: makeTestDefaults()))

        viewModel.toggleFavourite(Self.bergen)
        let addedFirst = viewModel.isFavourite(Self.bergen)
        viewModel.toggleFavourite(Self.bergen)

        #expect(addedFirst)
        #expect(viewModel.favourites.isEmpty)
    }

    @Test func placeMatchesByCoordinatesNotByName() {
        let viewModel = FavouritesViewModel(store: FavouritesStore(defaults: makeTestDefaults()))
        viewModel.toggleFavourite(Self.bergen)

        // Same town, other name and slightly different geocoding decimals → same place.
        let sameTown = Place(name: "Bergen kommune", latitude: 60.3913, longitude: 5.3221)
        // Same name, other country → not the same place.
        let otherBergen = Place(name: "Bergen", latitude: 52.67, longitude: 4.70)

        #expect(viewModel.isFavourite(sameTown))
        #expect(!viewModel.isFavourite(otherBergen))
    }

    @Test func recordOpenIncreasesCountAndIsSaved() throws {
        let store = FavouritesStore(defaults: makeTestDefaults())
        let viewModel = FavouritesViewModel(store: store)
        viewModel.toggleFavourite(Self.bergen)
        let favourite = try #require(viewModel.favourites.first)

        viewModel.recordOpen(favourite)
        viewModel.recordOpen(favourite)

        #expect(store.loadFavourites().first?.openCount == 2)
    }

    @Test func removeDeletesTheFavouriteFromTheStore() throws {
        let store = FavouritesStore(defaults: makeTestDefaults())
        let viewModel = FavouritesViewModel(store: store)
        viewModel.toggleFavourite(Self.bergen)
        let favourite = try #require(viewModel.favourites.first)

        viewModel.remove(favourite)

        #expect(store.loadFavourites().isEmpty)
    }
}
