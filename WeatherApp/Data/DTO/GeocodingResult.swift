import Foundation

/// One result from geocode.maps.co `/search` — a Decodable mirror of the JSON (W-11, W-19).
///
/// The response is a JSON array of these; an empty array means no results.
/// Only the fields we use are listed; `Decodable` ignores the rest (`address`, `boundingbox`, …).
nonisolated struct GeocodingResult: Decodable, Sendable {
    /// Short name, e.g. "Stockholm". Optional: the API doesn't promise it for every result.
    let name: String?
    /// Full name, e.g. "Stockholm, Stockholms kommun, Stockholms län, 111 29, Sverige".
    let displayName: String
    /// Sent as text, e.g. "59.3251172"; `GeocodingParser` turns it into a number.
    let latitude: String
    /// Sent as text, e.g. "18.0710935".
    let longitude: String

    nonisolated enum CodingKeys: String, CodingKey {
        case name
        case displayName = "display_name"
        case latitude = "lat"
        case longitude = "lon"
    }
}
