import Foundation

/// A place the user has starred (W-04). `FavouritesStore` will persist these later (plan step 8).
struct Favourite: Identifiable, Equatable, Codable {
    let id: UUID
    let placeName: String
    let latitude: Double
    let longitude: Double
    let dateAdded: Date
    /// How many times the user has opened this place from favourites. Used by "Most viewed".
    var openCount: Int

    init(
        id: UUID = UUID(),
        placeName: String,
        latitude: Double,
        longitude: Double,
        dateAdded: Date = .now,
        openCount: Int = 0
    ) {
        self.id = id
        self.placeName = placeName
        self.latitude = latitude
        self.longitude = longitude
        self.dateAdded = dateAdded
        self.openCount = openCount
    }
}
