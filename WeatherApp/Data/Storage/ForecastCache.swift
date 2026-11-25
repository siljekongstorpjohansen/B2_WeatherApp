import Foundation

/// Keeps the latest successful forecast on disk, so it can be shown when the phone is offline (W-16, W-17).
///
/// One JSON file in Application Support (SPEC.md §8). `nonisolated` so the repository can read and
/// write it off the main actor (STYLE.md §5). Best effort: a failed write is ignored and a missing or
/// unreadable file means "no cache" — the cache must never be the reason the app fails (W-22).
nonisolated struct ForecastCache: Sendable {
    /// What is saved: the forecast and when it was fetched.
    nonisolated struct Entry: Codable, Sendable {
        let forecast: Forecast
        let savedAt: Date
    }

    private let fileURL: URL

    /// - Parameter fileURL: injectable so tests use a temporary file; the app uses `defaultFileURL`.
    init(fileURL: URL = ForecastCache.defaultFileURL) {
        self.fileURL = fileURL
    }

    /// `…/Application Support/latest-forecast.json`. Application Support, not Caches: iOS may empty
    /// Caches when space is low, and then the offline fallback would be gone (SPEC.md §8).
    static var defaultFileURL: URL {
        URL.applicationSupportDirectory.appending(path: "latest-forecast.json")
    }

    /// The saved entry, or `nil` on first launch or if the file can't be read.
    func load() -> Entry? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return try? JSONDecoder().decode(Entry.self, from: data)
    }

    /// Replaces the saved forecast. Errors are ignored on purpose: without a cache the app still works.
    func save(_ forecast: Forecast, savedAt: Date) {
        guard let data = try? JSONEncoder().encode(Entry(forecast: forecast, savedAt: savedAt)) else {
            return
        }
        // Application Support doesn't exist until something creates it.
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        // `.atomic`: a crash mid-write leaves the old file, never half a file.
        try? data.write(to: fileURL, options: .atomic)
    }
}
