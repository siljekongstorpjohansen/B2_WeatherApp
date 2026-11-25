import Foundation

/// Every way a network request can fail, classified once in the service (W-22, oral Q13/Q14).
///
/// Callers only ever see these cases — never `URLError` or `DecodingError`.
nonisolated enum NetworkError: Error, Equatable {
    /// No connection: Wi-Fi/cellular off or the connection dropped.
    case offline
    /// The server didn't answer in time.
    case timeout
    /// The request was cancelled, e.g. by a newer search (W-34). Not an error to show the user.
    case cancelled
    /// The server answered, but not with 2xx. `reason` is the API's own explanation when it sends one.
    case httpStatus(code: Int, reason: String?)
    /// 2xx, but the JSON didn't match the DTO: missing field, `null`, wrong type (oral Q4).
    case decoding
    /// Anything else, e.g. DNS failure or a response that isn't HTTP.
    case unknown

    /// No working connection (offline or no answer in time): the cases where showing the latest
    /// saved forecast makes sense (SPEC.md §8, W-17). The other cases mean the server answered.
    var isConnectionProblem: Bool {
        self == .offline || self == .timeout
    }

    /// Sorts any error thrown while making a request into one of the cases above.
    init(classifying error: any Error) {
        if let networkError = error as? NetworkError {
            // Already classified (thrown by the service itself) — keep it.
            self = networkError
        } else if error is CancellationError {
            self = .cancelled
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                self = .offline
            case .timedOut:
                self = .timeout
            case .cancelled:
                self = .cancelled
            default:
                self = .unknown
            }
        } else if error is DecodingError {
            self = .decoding
        } else {
            self = .unknown
        }
    }
}
