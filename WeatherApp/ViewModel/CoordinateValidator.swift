import Foundation

/// What the user typed in the search field, once `CoordinateValidator` has looked at it (W-14).
nonisolated enum SearchInput: Equatable, Sendable {
    /// Text with letters, e.g. "Stockholm" — goes to geocoding.
    case placeName(String)
    /// Two valid numbers inside the globe — no geocoding needed.
    case coordinates(latitude: Double, longitude: Double)
    /// Looks like numbers but can't be used; `message` tells the user why (W-15, W-22).
    case invalidCoordinates(message: String)
}

/// Decides whether search text is a place name or coordinates, and checks the coordinates (W-14, W-15).
///
/// Pure and synchronous, so every input format is unit tested (W-23). Formats: SPEC.md §6, §8.
nonisolated enum CoordinateValidator {

    static let formatHint = "Enter latitude and longitude, e.g. 59.33, 18.07."

    /// Classifies `text`. Anything containing a letter is a place name, because coordinates never have letters.
    static func interpret(_ text: String) -> SearchInput {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.allSatisfy(isCoordinateCharacter) else {
            return .placeName(trimmed)
        }

        guard let parts = splitIntoTwoParts(trimmed),
              let latitude = number(from: parts.latitude),
              let longitude = number(from: parts.longitude)
        else {
            return .invalidCoordinates(message: formatHint)
        }

        guard (-90...90).contains(latitude) else {
            return .invalidCoordinates(message: "Latitude must be between -90 and 90.")
        }
        guard (-180...180).contains(longitude) else {
            return .invalidCoordinates(message: "Longitude must be between -180 and 180.")
        }
        return .coordinates(latitude: latitude, longitude: longitude)
    }

    /// Name shown when no town name is found: (59.33, 18.07) → "59.33° N, 18.07° E".
    /// `String(format:)` always uses a dot, so the text is the same in every language setting.
    static func displayName(latitude: Double, longitude: Double) -> String {
        let latitudeText = String(format: "%.2f° %@", abs(latitude), latitude >= 0 ? "N" : "S")
        let longitudeText = String(format: "%.2f° %@", abs(longitude), longitude >= 0 ? "E" : "W")
        return "\(latitudeText), \(longitudeText)"
    }

    // MARK: - Steps

    /// Digits, signs, decimal marks and the separators we accept.
    private static func isCoordinateCharacter(_ character: Character) -> Bool {
        character.isNumber || character.isWhitespace || "+-.,;".contains(character)
    }

    /// Splits into exactly two parts, or `nil`. Which separator counts depends on what the text contains:
    /// - `;` → it separates, so commas inside are decimals: "59,33; 18,07".
    /// - a space → it separates; a comma right before it is just punctuation: "59.33, 18.07", "59,33 18,07".
    /// - neither → a single comma separates: "59.33,18.07". "59,33,18,07" gives four parts → `nil`.
    private static func splitIntoTwoParts(_ text: String) -> (latitude: String, longitude: String)? {
        let rawParts: [Substring]
        if text.contains(";") {
            rawParts = text.split(separator: ";")
        } else if text.contains(where: \.isWhitespace) {
            rawParts = text.split(whereSeparator: \.isWhitespace)
                .map { $0.hasSuffix(",") ? $0.dropLast() : $0 }
        } else {
            rawParts = text.split(separator: ",")
        }

        let parts = rawParts
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard parts.count == 2 else {
            return nil
        }
        return (parts[0], parts[1])
    }

    /// "59,33" or "59.33" → 59.33. `Double` only understands a dot, so a decimal comma is swapped first.
    private static func number(from text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: "."))
    }
}
