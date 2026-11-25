import Foundation

/// A repository with canned answers — no network. For ViewModel tests and SwiftUI previews (W-23).
///
/// Each result is either a value or a `NetworkError`, so tests can drive every screen state.
nonisolated struct FakeWeatherRepository: WeatherRepository {
    private let placesResult: Result<[Place], NetworkError>
    private let forecastResult: Result<Forecast, NetworkError>
    private let reverseName: String?
    /// Set to pretend the forecast came from the cache, saved at this time (W-17).
    private let cachedAt: Date?

    init(
        placesResult: Result<[Place], NetworkError> = .success([.stockholm]),
        forecastResult: Result<Forecast, NetworkError>,
        reverseName: String? = nil,
        cachedAt: Date? = nil
    ) {
        self.placesResult = placesResult
        self.forecastResult = forecastResult
        self.reverseName = reverseName
        self.cachedAt = cachedAt
    }

    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place] {
        try placesResult.get()
    }

    /// The canned forecast, but for the `place` that was asked for — like the real API,
    /// so tests can check which place name reached the screen.
    func forecast(for place: Place) async throws(NetworkError) -> LoadedForecast {
        let canned = try forecastResult.get()
        let forecast = Forecast(
            place: place,
            timeZone: canned.timeZone,
            current: canned.current,
            hours: canned.hours,
            days: canned.days
        )
        return LoadedForecast(forecast: forecast, cachedAt: cachedAt)
    }

    func cachedForecast() async -> LoadedForecast? {
        nil
    }

    func placeName(latitude: Double, longitude: Double) async -> String? {
        reverseName
    }
}
