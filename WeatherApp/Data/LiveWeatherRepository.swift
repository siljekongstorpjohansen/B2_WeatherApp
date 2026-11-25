import Foundation

/// The real repository: geocode.maps.co for place search, Open-Meteo for forecasts (W-10, W-11, W-19).
nonisolated struct LiveWeatherRepository: WeatherRepository {
    private let geocodingService: GeocodingService
    private let forecastService: ForecastService
    private let geocodingParser: GeocodingParser
    private let forecastParser: ForecastParser
    private let forecastCache: ForecastCache
    private let now: @Sendable () -> Date

    /// - Parameter geocodingService: no default, because it needs the API key (see `configured()` in `WeatherApp.swift`).
    init(
        geocodingService: GeocodingService,
        forecastService: ForecastService = ForecastService(),
        geocodingParser: GeocodingParser = GeocodingParser(),
        forecastParser: ForecastParser = ForecastParser(),
        forecastCache: ForecastCache = ForecastCache(),
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.geocodingService = geocodingService
        self.forecastService = forecastService
        self.geocodingParser = geocodingParser
        self.forecastParser = forecastParser
        self.forecastCache = forecastCache
        self.now = now
    }

    /// Places matching `query`, most relevant first; `[]` when nothing matches.
    ///
    /// `@concurrent` so the request and parsing run off the main actor (W-21).
    @concurrent
    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place] {
        let results = try await geocodingService.searchPlaces(matching: query)
        return geocodingParser.parse(results)
    }

    /// Reverse lookup via geocode.maps.co; `nil` if it fails or finds no name.
    @concurrent
    func placeName(latitude: Double, longitude: Double) async -> String? {
        do {
            let result = try await geocodingService.reversePlace(latitude: latitude, longitude: longitude)
            return geocodingParser.placeName(from: result)
        } catch {
            // Missing key, rate limit, offline: the forecast must still load, so no name rather than an error.
            return nil
        }
    }

    /// Fetches and parses the forecast for `place`.
    ///
    /// `@concurrent` so parsing 168 hours also runs off the main actor, not only the request (W-21).
    ///
    /// Each fresh forecast is saved; offline or timed out, the saved one is returned instead (W-16, W-17).
    @concurrent
    func forecast(for place: Place) async throws(NetworkError) -> LoadedForecast {
        do throws(NetworkError) {
            let forecast = try await fetchAndParse(place)
            forecastCache.save(forecast, savedAt: now())
            return LoadedForecast(forecast: forecast, cachedAt: nil)
        } catch {
            // No connection: last saved data beats an error screen (oral Q16). A server error, or
            // nothing saved yet (first launch offline, oral Q15), still ends in the error state.
            guard error.isConnectionProblem, let cached = await cachedForecast() else {
                throw error
            }
            return cached
        }
    }

    @concurrent
    func cachedForecast() async -> LoadedForecast? {
        guard let entry = forecastCache.load() else {
            return nil
        }
        return LoadedForecast(forecast: entry.forecast, cachedAt: entry.savedAt)
    }

    private func fetchAndParse(_ place: Place) async throws(NetworkError) -> Forecast {
        let response = try await forecastService.fetchForecast(for: place)
        do {
            return try forecastParser.parse(response, for: place)
        } catch {
            // HTTP 200 but the data doesn't make sense (bad date, short array): same as bad JSON
            // for the user, so one case (SPEC.md §8, oral Q4).
            throw .decoding
        }
    }
}
