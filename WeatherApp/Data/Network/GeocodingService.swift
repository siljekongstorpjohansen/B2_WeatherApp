import Foundation

/// Searches geocode.maps.co for places matching a name (W-11).
///
/// Returns the DTOs; the repository runs `GeocodingParser`, so API types never leave the Data layer (STYLE.md §4).
nonisolated struct GeocodingService {
    private let apiKey: String
    private let session: URLSession

    /// - Parameters:
    ///   - apiKey: from `Config/Secrets.xcconfig` via Info.plist, passed in by `WeatherApp` (SPEC.md §8).
    ///   - session: injectable so tests can use their own; the app uses `.shared`.
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    /// Downloads and decodes the results for `query`, most relevant first.
    ///
    /// `@concurrent` so the request and decoding run off the main actor (W-21).
    /// - Throws: only `NetworkError`. geocode.maps.co answers 401 for a missing or wrong key
    ///   and 429 when we exceed the rate limit (≈ 1 request per second) — both become `.httpStatus` (W-22).
    @concurrent
    func searchPlaces(matching query: String) async throws(NetworkError) -> [GeocodingResult] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            // Nothing to search for: no request, no results.
            return []
        }
        do {
            let (data, response) = try await session.data(from: searchURL(for: trimmedQuery))

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpStatus(code: httpResponse.statusCode, reason: nil)
            }
            // An empty array `[]` is a normal answer: no places match.
            return try JSONDecoder().decode([GeocodingResult].self, from: data)
        } catch {
            throw NetworkError(classifying: error)
        }
    }

    /// Looks up what is at `latitude`, `longitude`, e.g. to name a place the user typed as coordinates (W-14).
    ///
    /// `@concurrent` like `searchPlaces` (W-21).
    /// - Throws: only `NetworkError`; 401 / 429 become `.httpStatus` (W-22).
    @concurrent
    func reversePlace(latitude: Double, longitude: Double) async throws(NetworkError) -> ReverseGeocodingResult {
        do {
            let (data, response) = try await session.data(from: reverseURL(latitude: latitude, longitude: longitude))

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpStatus(code: httpResponse.statusCode, reason: nil)
            }
            return try JSONDecoder().decode(ReverseGeocodingResult.self, from: data)
        } catch {
            throw NetworkError(classifying: error)
        }
    }

    /// `https://geocode.maps.co/search?q=…&api_key=…`. `URLComponents` percent-encodes the query,
    /// so spaces and å/ä/ö are sent correctly.
    private func searchURL(for query: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "geocode.maps.co"
        components.path = "/search"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "api_key", value: apiKey),
        ]
        guard let url = components.url else {
            // Can't happen with these fixed parts, but no force-unwrap outside tests (STYLE.md §5).
            throw NetworkError.unknown
        }
        return url
    }

    /// `https://geocode.maps.co/reverse?lat=…&lon=…&api_key=…`.
    private func reverseURL(latitude: Double, longitude: Double) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "geocode.maps.co"
        components.path = "/reverse"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "api_key", value: apiKey),
        ]
        guard let url = components.url else {
            throw NetworkError.unknown
        }
        return url
    }
}
