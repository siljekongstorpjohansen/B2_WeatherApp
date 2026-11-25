import Foundation
import Testing
@testable import WeatherApp

/// Proves the real Open-Meteo API works through every layer except the UI (W-10, W-27).
///
/// Skipped by default so normal test runs never hit the network or the daily request limit.
/// Run with: `TEST_RUNNER_LIVE_API_TESTS=1 xcodebuild test …` (xcodebuild passes `TEST_RUNNER_*`
/// variables to the tests without the prefix).
struct LiveWeatherRepositoryTests {

    @Test(.enabled(if: liveAPITestsEnabled, "Set LIVE_API_TESTS=1 to call the real Open-Meteo API"))
    func liveForecastForStockholmGoesThroughAllLayers() async throws {
        let forecast = try await LiveWeatherRepository.configured().forecast(for: .stockholm).forecast

        let display = ForecastDisplay(forecast: forecast, now: Date())

        #expect(forecast.timeZone.identifier == "Europe/Stockholm")
        #expect(forecast.days.count == 7)
        #expect(display.hours.count == ForecastDisplay.hourCount)
        #expect(display.days.first?.isToday == true)
        // Visible proof in the test log that the values are live, not the fixture.
        print("Live Open-Meteo:", display.conditions)
    }

    /// geocode.maps.co → Open-Meteo, the whole search path. Needs the key in `Config/Secrets.xcconfig`;
    /// without it the search throws `.httpStatus(code: 401, …)` (W-11).
    @Test(.enabled(if: liveAPITestsEnabled, "Set LIVE_API_TESTS=1 to call the real geocoding and forecast APIs"))
    func liveSearchForGoteborgFindsPlaceAndItsForecast() async throws {
        let repository = LiveWeatherRepository.configured()

        let places = try await repository.searchPlaces(matching: "Göteborg")
        let first = try #require(places.first)
        let forecast = try await repository.forecast(for: first).forecast

        #expect(first.name.contains("Göteborg"))  // å/ä/ö survive the URL encoding and the parser
        #expect(abs(first.latitude - 57.7) < 0.5)
        #expect(abs(first.longitude - 12.0) < 0.5)
        #expect(forecast.days.count == 7)
        print("Live geocoding:", first, "→", forecast.timeZone.identifier)
    }
}

private let liveAPITestsEnabled = ProcessInfo.processInfo.environment["LIVE_API_TESTS"] == "1"

/// `LiveWeatherRepository`'s cache fallback with a fake network — no real requests (W-16, W-17, oral Q16).
struct LiveWeatherRepositoryCacheTests {

    @Test func freshForecastIsSavedToTheCache() async throws {
        let cache = ForecastCache(fileURL: makeTemporaryCacheURL())
        let repository = makeRepository(serving: FixtureURLProtocol.self, cache: cache)

        let loaded = try await repository.forecast(for: .stockholm)

        #expect(loaded.cachedAt == nil)  // fresh from the (fake) network
        #expect(cache.load()?.forecast == loaded.forecast)
    }

    @Test func offlineReturnsTheSavedForecastWithItsTime() async throws {
        let cache = ForecastCache(fileURL: makeTemporaryCacheURL())
        let savedAt = Date(timeIntervalSince1970: 1_795_000_000)
        cache.save(try loadFixtureForecastForCache(), savedAt: savedAt)
        let repository = makeRepository(serving: OfflineURLProtocol.self, cache: cache)

        let loaded = try await repository.forecast(for: .stockholm)

        #expect(loaded.cachedAt == savedAt)
        #expect(loaded.forecast.days.count == 7)
    }

    /// A timeout is treated like offline: the saved forecast beats an error screen (oral Q13).
    @Test func timeoutReturnsTheSavedForecast() async throws {
        let cache = ForecastCache(fileURL: makeTemporaryCacheURL())
        let savedAt = Date(timeIntervalSince1970: 1_795_000_000)
        cache.save(try loadFixtureForecastForCache(), savedAt: savedAt)
        let repository = makeRepository(serving: TimeoutURLProtocol.self, cache: cache)

        let loaded = try await repository.forecast(for: .stockholm)

        #expect(loaded.cachedAt == savedAt)
    }

    /// HTTP 200 and valid JSON, but the data doesn't add up: `.decoding`, and no cache fallback,
    /// because the server did answer (oral Q4).
    @Test func inconsistentDataWithHTTP200ThrowsDecoding() async throws {
        let cache = ForecastCache(fileURL: makeTemporaryCacheURL())
        cache.save(try loadFixtureForecastForCache(), savedAt: Date(timeIntervalSince1970: 1_795_000_000))
        let repository = makeRepository(serving: ShortDailyArrayURLProtocol.self, cache: cache)

        await #expect(throws: NetworkError.decoding) {
            try await repository.forecast(for: .stockholm)
        }
    }

    private func makeRepository(serving protocolClass: URLProtocol.Type, cache: ForecastCache) -> LiveWeatherRepository {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [protocolClass]
        let session = URLSession(configuration: configuration)
        return LiveWeatherRepository(
            geocodingService: GeocodingService(apiKey: "", session: session),
            forecastService: ForecastService(session: session),
            forecastCache: cache
        )
    }
}

/// Every request fails as if the phone had no internet.
private final class OfflineURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
    }
    override func stopLoading() {}
}

/// Every request fails as if the server never answered in time.
private final class TimeoutURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLError(.timedOut))
    }
    override func stopLoading() {}
}

/// HTTP 200 with the Stockholm fixture, but `daily.weather_code` one day short, so the arrays don't line up.
private final class ShortDailyArrayURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let url = request.url,
              let fixtureURL = Bundle(for: CacheTestBundleToken.self)
                  .url(forResource: "open-meteo-forecast-stockholm", withExtension: "json"),
              let data = try? Data(contentsOf: fixtureURL),
              var json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              var daily = json["daily"] as? [String: Any],
              let weatherCodes = daily["weather_code"] as? [Int],
              let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
            return
        }
        daily["weather_code"] = Array(weatherCodes.dropLast())
        json["daily"] = daily
        let shortData = (try? JSONSerialization.data(withJSONObject: json)) ?? Data()
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: shortData)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}

/// Every request answers HTTP 200 with the saved Stockholm fixture.
private final class FixtureURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() {
        guard let url = request.url,
              let fixtureURL = Bundle(for: CacheTestBundleToken.self)
                  .url(forResource: "open-meteo-forecast-stockholm", withExtension: "json"),
              let data = try? Data(contentsOf: fixtureURL),
              let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    override func stopLoading() {}
}
