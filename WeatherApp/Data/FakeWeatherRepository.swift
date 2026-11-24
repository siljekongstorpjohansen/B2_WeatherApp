import Foundation

/// A repository with canned answers — no network. For ViewModel tests and SwiftUI previews (W-23).
///
/// Each result is either a value or a `NetworkError`, so tests can drive every screen state.
nonisolated struct FakeWeatherRepository: WeatherRepository {
    private let placesResult: Result<[Place], NetworkError>
    private let forecastResult: Result<Forecast, NetworkError>

    init(
        placesResult: Result<[Place], NetworkError> = .success([.stockholm]),
        forecastResult: Result<Forecast, NetworkError>
    ) {
        self.placesResult = placesResult
        self.forecastResult = forecastResult
    }

    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place] {
        try placesResult.get()
    }

    func forecast(for place: Place) async throws(NetworkError) -> Forecast {
        try forecastResult.get()
    }
}
