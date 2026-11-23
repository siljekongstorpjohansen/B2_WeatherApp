/// Body Open-Meteo sends with HTTP 400, e.g.
/// `{"error": true, "reason": "Latitude must be in range of -90 to 90°. Given: 100.0."}` (W-22).
nonisolated struct OpenMeteoErrorResponse: Decodable, Sendable {
    let error: Bool
    let reason: String
}
