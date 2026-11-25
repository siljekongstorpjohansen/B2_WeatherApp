import Foundation

/// Fetches the raw Open-Meteo forecast for a place (W-10).
///
/// Returns the DTO; the repository runs the parser, so API types never leave the Data layer (STYLE.md §4).
nonisolated struct ForecastService {
    private let session: URLSession

    /// - Parameter session: injectable so tests can use their own; the app uses `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Downloads and decodes the forecast for `place`.
    ///
    /// `@concurrent`: with approachable concurrency a plain `async` function runs on the caller's actor
    /// (the main actor when a ViewModel calls it). This moves the request and JSON decoding off it (W-21).
    /// - Throws: only `NetworkError` — every failure is classified here (W-22).
    @concurrent
    func fetchForecast(for place: Place) async throws(NetworkError) -> OpenMeteoResponse {
        do {
            let (data, response) = try await session.data(from: forecastURL(for: place))

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                // Open-Meteo explains errors in the body: {"error": true, "reason": "..."}.
                // `try?`: the body may not be that JSON (e.g. a 502 HTML page) — then there is no reason.
                let apiError = try? JSONDecoder().decode(OpenMeteoErrorResponse.self, from: data)
                throw NetworkError.httpStatus(code: httpResponse.statusCode, reason: apiError?.reason)
            }
            return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
        } catch {
            throw NetworkError(classifying: error)
        }
    }

    /// The Open-Meteo URL for `place`, with the fields from CONTEXT.md §5 and default units (km/h).
    private func forecastURL(for place: Place) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.open-meteo.com"
        components.path = "/v1/forecast"
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(place.latitude)),
            URLQueryItem(name: "longitude", value: String(place.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code,wind_speed_10m"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code,precipitation_probability"),
            URLQueryItem(
                name: "daily",
                value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max,"
                    // W-03: extras for the day detail screen (optional in the DTO).
                    + "sunrise,sunset,apparent_temperature_max,apparent_temperature_min,"
                    + "precipitation_probability_max,uv_index_max,wind_direction_10m_dominant,wind_gusts_10m_max"
            ),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "7"),
        ]
        guard let url = components.url else {
            // Can't happen with these fixed parts, but no force-unwrap outside tests (STYLE.md §5).
            throw NetworkError.unknown
        }
        return url
    }
}
