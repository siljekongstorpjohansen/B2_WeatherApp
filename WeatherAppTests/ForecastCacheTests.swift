import Foundation
import Testing
@testable import WeatherApp

/// `ForecastCache` with a temporary file — the app's real cache is never touched (W-16, W-17, W-22).
struct ForecastCacheTests {

    @Test func savedForecastIsLoadedWithItsTime() throws {
        let cache = ForecastCache(fileURL: makeTemporaryCacheURL())
        let forecast = try loadFixtureForecastForCache()
        let savedAt = Date(timeIntervalSince1970: 1_795_000_000)

        cache.save(forecast, savedAt: savedAt)
        let entry = try #require(cache.load())

        #expect(entry.forecast == forecast)
        #expect(entry.savedAt == savedAt)
    }

    @Test func noSavedFileMeansNoCache() {
        let cache = ForecastCache(fileURL: makeTemporaryCacheURL())  // first launch: nothing saved

        #expect(cache.load() == nil)
    }

    @Test func corruptFileMeansNoCacheInsteadOfCrashing() throws {
        let fileURL = makeTemporaryCacheURL()
        try Data("not json".utf8).write(to: fileURL)

        #expect(ForecastCache(fileURL: fileURL).load() == nil)
    }
}

/// A file path in the temporary folder that no other test uses.
func makeTemporaryCacheURL() -> URL {
    FileManager.default.temporaryDirectory.appending(path: "forecast-cache-test-\(UUID()).json")
}

/// The saved Stockholm fixture, parsed — a realistic forecast to put in the cache.
func loadFixtureForecastForCache() throws -> Forecast {
    let url = try #require(
        Bundle(for: CacheTestBundleToken.self).url(forResource: "open-meteo-forecast-stockholm", withExtension: "json")
    )
    let response = try JSONDecoder().decode(OpenMeteoResponse.self, from: Data(contentsOf: url))
    return try ForecastParser().parse(response, for: .stockholm)
}

/// Lets `Bundle(for:)` find the test bundle, where Xcode copies `Fixtures/`.
final class CacheTestBundleToken {}
