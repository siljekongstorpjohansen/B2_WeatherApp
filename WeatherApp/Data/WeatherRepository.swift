import Foundation

/// The only door from ViewModels into the Data layer (STYLE.md §4, W-30).
///
/// A protocol because there are two implementations: `LiveWeatherRepository` (real API)
/// and `FakeWeatherRepository` (tests and previews).
/// Both functions throw only `NetworkError`, so the ViewModel handles one known set of cases (W-22).
nonisolated protocol WeatherRepository: Sendable {
    /// Places matching a search text, e.g. "Stockholm".
    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place]

    /// The full forecast (current, hours, days) for `place`.
    func forecast(for place: Place) async throws(NetworkError) -> Forecast
}
