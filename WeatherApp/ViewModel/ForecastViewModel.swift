import Foundation
import Observation

/// State for the search/forecast screen (W-02, W-22, W-34).
///
/// The view calls `search(_:)` and draws `state`; it never sees the repository, `Forecast` or errors.
@Observable
@MainActor
final class ForecastViewModel {
    /// What the screen shows. Exactly one at a time (oral Q11).
    enum State: Equatable {
        case idle
        /// `previous` = the forecast that was on screen when loading started, shown dimmed under
        /// the spinner so the screen is never blank (W-33); `nil` on first load or after an error.
        case loading(previous: ForecastDisplay?)
        case loaded(ForecastDisplay)
        case failed(message: String)
    }

    private(set) var state: State = .idle

    /// When the shown forecast was saved, if it came from the cache because the phone is offline;
    /// `nil` for fresh data. Drives the offline banner (W-17, SPEC.md §6).
    private(set) var offlineSince: Date?

    /// What can be loaded: typed text, or a known place (favourite, start place) by coordinates.
    private enum Request: Equatable {
        case search(String)
        case place(Place)
    }

    /// A failed load, with the text the user sees.
    private struct LoadFailure: Error {
        let message: String
    }

    /// The forecast behind `.loaded`, kept so a unit change can rebuild the screen without a new request (W-06).
    private struct ShownForecast {
        let forecast: Forecast
        /// When it was put on screen — the "now" for "Now" and "Today".
        let shownAt: Date
        /// When its data was fetched: `shownAt` if fresh, the cache time when offline (W-17).
        let fetchedAt: Date
    }

    private let repository: any WeatherRepository
    private let connectivityUpdates: AsyncStream<Bool>
    private let now: () -> Date
    /// What `ConnectivityMonitor` last said. Starts `false`, so the first "online" at app start isn't a "return".
    private var isOffline = false
    private var searchTask: Task<Void, Never>?
    /// What the user last asked for, so `retry()` and `refreshIfOlder` can repeat it.
    private var lastRequest: Request?
    private var shownForecast: ShownForecast?
    private var temperatureUnit: UserSettings.TemperatureUnit = .celsius
    private var windSpeedUnit: UserSettings.WindSpeedUnit = .kilometresPerHour

    /// - Parameters:
    ///   - repository: `LiveWeatherRepository` in the app, `FakeWeatherRepository` in tests and previews.
    ///   - connectivityUpdates: `ConnectivityMonitor().updates()` in the app; tests pass their own stream.
    ///     Empty by default, so previews and tests that don't need it never watch the network.
    ///   - now: the clock; tests pass a fixed time so "Now" and "Today" are predictable.
    init(
        repository: any WeatherRepository,
        connectivityUpdates: AsyncStream<Bool> = AsyncStream { $0.finish() },
        now: @escaping () -> Date = { Date() }
    ) {
        self.repository = repository
        self.connectivityUpdates = connectivityUpdates
        self.now = now
    }

    /// Searches for `query` — a place name or coordinates (W-14) — and shows the forecast.
    ///
    /// A newer call cancels this one; only the newest search may change `state` (W-34, oral Q12).
    func search(_ query: String) async {
        await run(.search(query))
    }

    /// Shows the forecast for a place we already know — a favourite or the start place — by its
    /// coordinates, without geocoding (W-05, SPEC.md §8).
    func showForecast(for place: Place) async {
        await run(.place(place))
    }

    /// Repeats the last request, e.g. from the error state's "Try again" (W-22).
    /// Does nothing before the first request.
    func retry() async {
        guard let lastRequest else { return }
        await run(lastRequest)
    }

    /// Reloads the shown forecast if it is older than `minutes`; `nil` means "Manual only" (W-06).
    /// Called when the app comes back to the foreground.
    func refreshIfOlder(than minutes: Int?) async {
        guard let minutes,
              let lastRequest,
              let shownForecast,
              // The age of the data, not of the screen: cached data from this morning is old (W-17).
              now().timeIntervalSince(shownForecast.fetchedAt) > Double(minutes) * 60
        else {
            return
        }
        await run(lastRequest)
    }

    /// New units from Settings (W-06). If a forecast is shown, it is rebuilt at once — no new request.
    func setUnits(temperature: UserSettings.TemperatureUnit, windSpeed: UserSettings.WindSpeedUnit) {
        temperatureUnit = temperature
        windSpeedUnit = windSpeed
        if case .loaded = state, let shownForecast {
            state = .loaded(display(for: shownForecast))
        }
    }

    /// Follows the connection for as long as the caller's task runs — the view's `.task` (W-17).
    ///
    /// Offline: the banner shows at once instead of after a failed request. Back online: the last
    /// request is repeated, so cached or failed data is replaced without the user doing anything.
    func watchConnectivity() async {
        for await isOnline in connectivityUpdates {
            if isOnline {
                await connectionReturned()
            } else {
                connectionLost()
            }
        }
    }

    // MARK: - Connectivity

    private func connectionLost() {
        isOffline = true
        // The data on screen stays; the banner says how old it is. Its age is when it was
        // fetched, not when the connection dropped (W-17).
        if case .loaded = state, offlineSince == nil, let shownForecast {
            offlineSince = shownForecast.fetchedAt
        }
    }

    private func connectionReturned() async {
        // Also skips the first report at app start and Wi-Fi ↔ cellular switches: online → online.
        guard isOffline else { return }
        isOffline = false

        // Fresh data on screen needs no reload; cached data (banner) or an error does.
        let showsFailure = if case .failed = state { true } else { false }
        guard offlineSince != nil || showsFailure else { return }
        await retry()
    }

    // MARK: - Loading

    private func run(_ request: Request) async {
        lastRequest = request
        searchTask?.cancel()
        let task = Task { await load(request) }
        searchTask = task
        await task.value
    }

    private func load(_ request: Request) async {
        state = .loading(previous: displayedForecast)
        let result: Result<LoadedForecast, LoadFailure>
        switch request {
        case .search(let query):
            result = await loadForecast(for: query)
        case .place(let place):
            result = await loadForecast(at: place)
        }
        // A newer request started while this one was waiting: drop this result, the newer one wins.
        guard !Task.isCancelled else { return }

        switch result {
        case .success(let loaded):
            let shownAt = now()
            let shown = ShownForecast(forecast: loaded.forecast, shownAt: shownAt, fetchedAt: loaded.cachedAt ?? shownAt)
            shownForecast = shown
            offlineSince = loaded.cachedAt
            state = .loaded(display(for: shown))
        case .failure(let failure):
            offlineSince = nil
            state = .failed(message: failure.message)
        }
    }

    /// The forecast the user sees right now: loaded, or still dimmed from a load before.
    /// A rapid second search keeps the same old data instead of falling back to a bare spinner (W-34).
    private var displayedForecast: ForecastDisplay? {
        switch state {
        case .loaded(let display):
            display
        case .loading(let previous):
            previous
        case .idle, .failed:
            nil
        }
    }

    private func display(for shown: ShownForecast) -> ForecastDisplay {
        ForecastDisplay(
            forecast: shown.forecast,
            now: shown.shownAt,
            updatedAt: shown.fetchedAt,
            temperatureUnit: temperatureUnit,
            windSpeedUnit: windSpeedUnit
        )
    }

    /// The forecast for typed text. Coordinates skip place search (W-14); invalid ones never
    /// reach the network (W-15).
    private func loadForecast(for query: String) async -> Result<LoadedForecast, LoadFailure> {
        switch CoordinateValidator.interpret(query) {
        case .placeName(let name):
            return await loadForecast(searchingFor: name)
        case .coordinates(let latitude, let longitude):
            let townName = await repository.placeName(latitude: latitude, longitude: longitude)
            let name = townName ?? CoordinateValidator.displayName(latitude: latitude, longitude: longitude)
            return await loadForecast(at: Place(name: name, latitude: latitude, longitude: longitude))
        case .invalidCoordinates(let message):
            return .failure(LoadFailure(message: message))
        }
    }

    /// Place search, then the forecast for the first match.
    private func loadForecast(searchingFor name: String) async -> Result<LoadedForecast, LoadFailure> {
        do throws(NetworkError) {
            let places = try await repository.searchPlaces(matching: name)
            guard let place = places.first else {
                // A designed empty state comes later (W-33, W-34).
                return .failure(LoadFailure(message: "No places match \"\(name)\"."))
            }
            return .success(try await repository.forecast(for: place))
        } catch {
            // Offline before the forecast step (place search failed): show the latest saved
            // forecast like every other offline load (SPEC.md §8, W-17).
            if error.isConnectionProblem, let cached = await repository.cachedForecast() {
                return .success(cached)
            }
            return failure(for: error)
        }
    }

    /// The forecast for a known place; the repository already falls back to the cache (W-17).
    private func loadForecast(at place: Place) async -> Result<LoadedForecast, LoadFailure> {
        do throws(NetworkError) {
            return .success(try await repository.forecast(for: place))
        } catch {
            return failure(for: error)
        }
    }

    private func failure(for error: NetworkError) -> Result<LoadedForecast, LoadFailure> {
        .failure(LoadFailure(message: message(for: error)))
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
