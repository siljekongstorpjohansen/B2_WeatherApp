import Foundation

/// A forecast from the repository, and whether it came from the network or the cache (W-17).
nonisolated struct LoadedForecast: Sendable {
    let forecast: Forecast
    /// When the cached copy was saved; `nil` when the forecast is fresh from the network.
    let cachedAt: Date?
}
