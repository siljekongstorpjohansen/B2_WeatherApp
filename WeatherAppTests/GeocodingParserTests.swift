import Foundation
import Testing
@testable import WeatherApp

/// `GeocodingParser` with saved geocode.maps.co fixtures and hand-made results — no network (W-11, W-15, W-23).
struct GeocodingParserTests {

    @Test func parserReturnsPlacesInOrderForStockholmFixture() throws {
        let results = try loadFixture("geocode-stockholm")  // 5 results, Stockholm (Sweden) first

        let places = GeocodingParser().parse(results)

        #expect(places.count == 5)
        let first = try #require(places.first)
        #expect(first.name == "Stockholm")
        #expect(abs(first.latitude - 59.3251172) < 0.000001)
        #expect(abs(first.longitude - 18.0710935) < 0.000001)
    }

    @Test func parserReturnsEmptyListForNoResultsFixture() throws {
        let results = try loadFixture("geocode-no-results")  // []

        let places = GeocodingParser().parse(results)

        #expect(places.isEmpty)
    }

    @Test func parserSkipsResultsWithInvalidCoordinates() {
        let results = [
            GeocodingResult(name: "Not a number", displayName: "Not a number", latitude: "abc", longitude: "18.07"),
            GeocodingResult(name: "Too far north", displayName: "Too far north", latitude: "91", longitude: "18.07"),
            GeocodingResult(name: "Stockholm", displayName: "Stockholm, Sverige", latitude: "59.33", longitude: "18.07"),
        ]

        let places = GeocodingParser().parse(results)

        #expect(places.map(\.name) == ["Stockholm"])
    }

    @Test func parserFallsBackToDisplayNameWhenNameIsMissing() {
        let results = [
            GeocodingResult(
                name: nil,
                displayName: "Göteborg, Västra Götaland, Sverige",
                latitude: "57.7072",
                longitude: "11.9668"
            ),
        ]

        let places = GeocodingParser().parse(results)

        #expect(places.map(\.name) == ["Göteborg"])
    }

    // MARK: - Helpers

    private func loadFixture(_ name: String) throws -> [GeocodingResult] {
        let url = try #require(Bundle(for: BundleToken.self).url(forResource: name, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([GeocodingResult].self, from: data)
    }
}

/// Lets `Bundle(for:)` find the test bundle, where Xcode copies `Fixtures/`.
private final class BundleToken {}
