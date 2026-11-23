import Foundation
import Observation

/// State for the search/forecast screen (W-02, W-22, W-34).
///
/// The view calls `search(_:)` and draws `state`; it never sees the repository, `Forecast` or errors.
@Observable
@MainActor
final class ForecastViewModel {
    /// What the screen shows. Exactly one at a time, so stale data can't sit next to a spinner (oral Q11).
    enum State: Equatable {
        case idle
        case loading
        case loaded(ForecastDisplay)
        case failed(message: String)
    }

    private(set) var state: State = .idle

    private let repository: any WeatherRepository
    private let now: () -> Date
    private var searchTask: Task<Void, Never>?

    /// - Parameters:
    ///   - repository: `LiveWeatherRepository` in the app, `FakeWeatherRepository` in tests and previews.
    ///   - now: the clock; tests pass a fixed time so "Now" and "Today" are predictable.
    init(repository: any WeatherRepository, now: @escaping () -> Date = { Date() }) {
        self.repository = repository
        self.now = now
    }

    /// Searches for `query` and shows the forecast for the first match.
    ///
    /// A newer call cancels this one; only the newest search may change `state` (W-34, oral Q12).
    func search(_ query: String) async {
        searchTask?.cancel()
        let task = Task { await runSearch(query) }
        searchTask = task
        await task.value
    }

    private func runSearch(_ query: String) async {
        state = .loading
        let newState = await loadState(for: query)
        // A newer search started while this one was waiting: drop this result, the newer one wins.
        guard !Task.isCancelled else { return }
        state = newState
    }

    /// Place search + forecast, turned into the state to show. Never throws: every error becomes `.failed`.
    private func loadState(for query: String) async -> State {
        do throws(NetworkError) {
            let places = try await repository.searchPlaces(matching: query)
            guard let place = places.first else {
                // A designed empty state comes later (W-33, W-34).
                return .failed(message: "No places match \"\(query)\".")
            }
            let forecast = try await repository.forecast(for: place)
            return .loaded(ForecastDisplay(forecast: forecast, now: now()))
        } catch {
            return .failed(message: message(for: error))
        }
    }

    /// User-facing text for each error (W-22). Wording and icons get designed later (W-33).
    private func message(for error: NetworkError) -> String {
        switch error {
        case .offline:
            "You're offline. Check your connection and try again."
        case .timeout:
            "The weather service didn't answer in time. Try again."
        case .httpStatus:
            "The weather service returned an error. Try again later."
        case .decoding:
            "The weather data couldn't be read. Try again later."
        case .cancelled, .unknown:
            "Something went wrong. Try again."
        }
    }
}
