import SwiftUI

/// Semantic colours. Built on system colours so Dark Mode works automatically.
extension Color {
    /// Background for cards and the search field.
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    /// Unfilled part of the temperature range bar.
    static let rangeTrack = Color(uiColor: .tertiarySystemFill)
    /// Background for the offline banner (W-17).
    static let warningBackground = Color.yellow.opacity(0.25)
}
