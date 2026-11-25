import Foundation

/// The answer from geocode.maps.co `/reverse` for one coordinate pair — a Decodable mirror of the JSON (W-14, W-19).
///
/// Every field is optional: the lookup is best effort (SPEC.md §8), and over the open sea the API
/// has no address at all. Not yet checked against a saved response (SPEC.md §6).
nonisolated struct ReverseGeocodingResult: Decodable, Sendable {
    /// Full name, e.g. "Drottninggatan, Norrmalm, Stockholm, Stockholms kommun, Sverige".
    let displayName: String?
    let address: Address?

    /// The parts of the address we might use as a short name, from most to least specific.
    nonisolated struct Address: Decodable, Sendable {
        let city: String?
        let town: String?
        let village: String?
        let municipality: String?
        let county: String?
    }

    nonisolated enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case address
    }
}
