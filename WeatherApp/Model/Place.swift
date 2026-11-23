import Foundation

/// A location the user can get a forecast for.
///
/// `nonisolated` + `Sendable`: the project defaults every type to the main actor,
/// but places are passed to the service and parser off the main thread (W-21).
nonisolated struct Place: Hashable, Sendable {
    let name: String
    let latitude: Double
    let longitude: Double
}

nonisolated extension Place {
    /// Temporary fixed search result until geocoding has an API key (SPEC.md §8, W-11).
    static let stockholm = Place(name: "Stockholm", latitude: 59.33, longitude: 18.07)
}
