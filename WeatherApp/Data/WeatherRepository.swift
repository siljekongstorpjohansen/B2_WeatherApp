import Foundation

/// The only door from ViewModels into the Data layer (STYLE.md §4, W-30).
///
/// A protocol because there are two implementations: `LiveWeatherRepository` (real API)
/// and `FakeWeatherRepository` (tests and previews).
/// Both functions throw only `NetworkError`, so the ViewModel handles one known set of cases (W-22).
nonisolated protocol WeatherRepository: Sendable {
    /// Places matching a search text, e.g. "Stockholm".
    func searchPlaces(matching query: String) async throws(NetworkError) -> [Place]

    /// The full forecast (current, hours, days) for `place`. When offline or timed out, the latest
    /// saved forecast instead — possibly for another place — with `cachedAt` set (W-17, SPEC.md §8).
    func forecast(for place: Place) async throws(NetworkError) -> LoadedForecast

    /// The latest saved forecast, or `nil` if there is none — for a search that fails offline
    /// before it reaches the forecast step (W-17).
    func cachedForecast() async -> LoadedForecast?

    /// A town name for coordinates the user typed, e.g. "Stockholm" (W-14).
    /// Best effort: `nil` on any failure, and the caller shows the coordinates instead (SPEC.md §8).
    func placeName(latitude: Double, longitude: Double) async -> String?
}
