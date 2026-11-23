import Foundation

/// The real repository: Open-Meteo via `ForecastService`, then `ForecastParser` (W-10, W-19).
nonisolated struct LiveWeatherRepository: WeatherRepository {
    private let forecastService: ForecastService
    private let parser: ForecastParser

    init(forecastService: ForecastService = ForecastService(), parser: ForecastParser = ForecastParser()) {
        self.forecastService = forecastService
        self.parser = parser
    }

    /// Always returns Stockholm until geocoding has an API key (SPEC.md §8, W-11).
    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place] {
        [.stockholm]
    }

    /// Fetches and parses the forecast for `place`.
    ///
    /// `@concurrent` so parsing 168 hours also runs off the main actor, not only the request (W-21).
    @concurrent
    func forecast(for place: Place) async throws(NetworkError) -> Forecast {
        let response = try await forecastService.fetchForecast(for: place)
        do {
            return try parser.parse(response, for: place)
        } catch {
            // HTTP 200 but the data doesn't make sense (bad date, short array): same as bad JSON
            // for the user, so one case (SPEC.md §8, oral Q4).
            throw .decoding
        }
    }
}
