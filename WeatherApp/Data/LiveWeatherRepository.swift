import Foundation

/// The real repository: geocode.maps.co for place search, Open-Meteo for forecasts (W-10, W-11, W-19).
nonisolated struct LiveWeatherRepository: WeatherRepository {
    private let geocodingService: GeocodingService
    private let forecastService: ForecastService
    private let geocodingParser: GeocodingParser
    private let forecastParser: ForecastParser

    /// - Parameter geocodingService: no default, because it needs the API key (see `configured()` in `WeatherApp.swift`).
    init(
        geocodingService: GeocodingService,
        forecastService: ForecastService = ForecastService(),
        geocodingParser: GeocodingParser = GeocodingParser(),
        forecastParser: ForecastParser = ForecastParser()
    ) {
        self.geocodingService = geocodingService
        self.forecastService = forecastService
        self.geocodingParser = geocodingParser
        self.forecastParser = forecastParser
    }

    /// Places matching `query`, most relevant first; `[]` when nothing matches.
    ///
    /// `@concurrent` so the request and parsing run off the main actor (W-21).
    @concurrent
    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place] {
        let results = try await geocodingService.searchPlaces(matching: query)
        return geocodingParser.parse(results)
    }

    /// Fetches and parses the forecast for `place`.
    ///
    /// `@concurrent` so parsing 168 hours also runs off the main actor, not only the request (W-21).
    @concurrent
    func forecast(for place: Place) async throws(NetworkError) -> Forecast {
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
