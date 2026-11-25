import Foundation

/// Turns geocode.maps.co results into our `Place` model (W-11, W-19).
///
/// Pure and synchronous like `ForecastParser`, so it is tested with saved fixtures (W-23).
/// Never throws: one bad result is skipped so it can't hide the good ones. If every result is bad,
/// the list is empty and the user sees "No places match" (SPEC.md §6).
nonisolated struct GeocodingParser {

    /// Builds places from `results`, keeping the API's order (most relevant first).
    func parse(_ results: [GeocodingResult]) -> [Place] {
        // `compactMap` drops the `nil`s, i.e. the skipped results.
        results.compactMap { place(from: $0) }
    }

    /// A short name for a reverse lookup, e.g. "Stockholm", or `nil` if the result has none (W-14).
    ///
    /// Takes the most specific address part that has text; falls back to the first part of `display_name`.
    func placeName(from result: ReverseGeocodingResult) -> String? {
        let address = result.address
        let candidates = [
            address?.city,
            address?.town,
            address?.village,
            address?.municipality,
            address?.county,
            result.displayName?.split(separator: ",").first.map(String.init),
        ]
        for candidate in candidates {
            let trimmed = candidate?.trimmingCharacters(in: .whitespaces) ?? ""
            if !trimmed.isEmpty {
                return trimmed
            }
        }
        return nil
    }

    /// One result → `Place`, or `nil` if its coordinates or name can't be used.
    private func place(from result: GeocodingResult) -> Place? {
        // The API sends coordinates as text ("59.3251172"); anything that isn't a number,
        // or is outside the globe, is skipped (W-15).
        guard let latitude = Double(result.latitude),
              let longitude = Double(result.longitude),
              (-90...90).contains(latitude),
              (-180...180).contains(longitude)
        else {
            return nil
        }
        let name = placeName(for: result)
        guard !name.isEmpty else {
            return nil
        }
        return Place(name: name, latitude: latitude, longitude: longitude)
    }

    /// `name` when the API sends one, otherwise the first part of `display_name`:
    /// "Göteborg, Västra Götaland, Sverige" → "Göteborg".
    private func placeName(for result: GeocodingResult) -> String {
        let name = result.name?.trimmingCharacters(in: .whitespaces) ?? ""
        if !name.isEmpty {
            return name
        }
        let firstPart = result.displayName.split(separator: ",").first ?? ""
        return firstPart.trimmingCharacters(in: .whitespaces)
    }
}
