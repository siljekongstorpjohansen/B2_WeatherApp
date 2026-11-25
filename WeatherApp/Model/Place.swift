import Foundation

/// A location the user can get a forecast for.
///
/// `nonisolated` + `Sendable`: the project defaults every type to the main actor,
/// but places are passed to the service and parser off the main thread (W-21).
nonisolated struct Place: Hashable, Sendable, Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}

nonisolated extension Place {
    /// Default place: start-screen fallback before any favourite is chosen, and in tests and previews.
    static let stockholm = Place(name: "Stockholm", latitude: 59.33, longitude: 18.07)
}
