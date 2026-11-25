import Foundation
import Testing
@testable import WeatherApp

/// `CoordinateValidator`: place name vs. coordinates, accepted formats and range checks (W-14, W-15, W-23).
struct CoordinateValidatorTests {

    @Test(arguments: ["Stockholm", "Ålesund", "  Göteborg  "])
    func textWithLettersIsAPlaceName(text: String) {
        let input = CoordinateValidator.interpret(text)

        #expect(input == .placeName(text.trimmingCharacters(in: .whitespaces)))
    }

    @Test(arguments: [
        "59.33, 18.07",   // comma + space
        "59.33 18.07",    // space only
        "59.33,18.07",    // comma, no space
        "59.33; 18.07",   // semicolon
        "59,33 18,07",    // comma decimals, space between
        "59,33; 18,07",   // comma decimals, semicolon between
        "59,33, 18,07",   // comma decimals, comma + space between
    ])
    func acceptedFormatsGiveStockholmsCoordinates(text: String) {
        let input = CoordinateValidator.interpret(text)

        #expect(input == .coordinates(latitude: 59.33, longitude: 18.07))
    }

    @Test func negativeCoordinatesAreValid() {
        let input = CoordinateValidator.interpret("-33.87, 151.21")  // Sydney

        #expect(input == .coordinates(latitude: -33.87, longitude: 151.21))
    }

    @Test func latitudeAbove90IsInvalid() {
        let input = CoordinateValidator.interpret("91, 0")

        #expect(input == .invalidCoordinates(message: "Latitude must be between -90 and 90."))
    }

    @Test func longitudeAbove180IsInvalid() {
        let input = CoordinateValidator.interpret("0, 181")

        #expect(input == .invalidCoordinates(message: "Longitude must be between -180 and 180."))
    }

    @Test(arguments: ["59.33", "59.33, 18.07, 5", "59,33,18,07", "-, ."])
    func wrongNumberOfPartsShowsFormatHint(text: String) {
        let input = CoordinateValidator.interpret(text)

        #expect(input == .invalidCoordinates(message: CoordinateValidator.formatHint))
    }

    @Test func displayNameUsesNorthAndEastForPositiveValues() {
        let name = CoordinateValidator.displayName(latitude: 59.3251, longitude: 18.0711)

        #expect(name == "59.33° N, 18.07° E")
    }

    @Test func displayNameUsesSouthAndWestForNegativeValues() {
        let name = CoordinateValidator.displayName(latitude: -33.87, longitude: -70.65)

        #expect(name == "33.87° S, 70.65° W")
    }
}
