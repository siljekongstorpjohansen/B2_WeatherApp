import Foundation
import Network

/// Tells whether the phone has a network path, as it changes (W-17).
///
/// Only used to show the offline banner at once and to reload when the connection returns.
/// It never blocks a request: the path can be wrong (e.g. Wi-Fi with a login page), so requests
/// are always tried and real errors decide the cache fallback (SPEC.md §8).
nonisolated struct ConnectivityMonitor: Sendable {

    /// `true` = online, `false` = offline. The first value arrives right after start.
    ///
    /// Keeps only the newest value: if the reader is busy (e.g. reloading), only the current state matters.
    /// The monitor stops when the reader stops (the stream ends).
    func updates() -> AsyncStream<Bool> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { _ in
                monitor.cancel()
            }
            // Its own background queue, so path changes never wait for the main thread (W-21).
            monitor.start(queue: DispatchQueue(label: "ConnectivityMonitor"))
        }
    }
}
