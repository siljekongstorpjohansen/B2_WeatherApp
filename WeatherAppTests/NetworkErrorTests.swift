import Foundation
import Testing
@testable import WeatherApp

/// `NetworkError(classifying:)` — error-state logic, no network needed (W-22, W-23).
struct NetworkErrorTests {

    @Test func noInternetURLErrorIsClassifiedAsOffline() {
        let error = URLError(.notConnectedToInternet)

        let classified = NetworkError(classifying: error)

        #expect(classified == .offline)
    }

    @Test func cancellationErrorIsClassifiedAsCancelled() {
        let error = CancellationError()

        let classified = NetworkError(classifying: error)

        #expect(classified == .cancelled)
    }

    @Test func decodingErrorIsClassifiedAsDecoding() {
        let error = DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "Missing key 'daily'")
        )

        let classified = NetworkError(classifying: error)

        #expect(classified == .decoding)
    }

    @Test func alreadyClassifiedErrorIsKept() {
        // The service throws `.httpStatus` inside its `do`; the `catch` must not turn it into `.unknown`.
        let error = NetworkError.httpStatus(code: 400, reason: "Latitude must be in range of -90 to 90°.")

        let classified = NetworkError(classifying: error)

        #expect(classified == error)
    }
}
