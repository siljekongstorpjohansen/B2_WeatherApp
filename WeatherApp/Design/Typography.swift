import SwiftUI

extension Font {
    /// The large current temperature — the most prominent element on the start screen.
    static let heroTemperature = Font.system(size: 72, weight: .thin, design: .rounded)
}

extension Double {
    /// Whole degrees without unit letter, e.g. `1.8` → `"2°"`.
    var degreesText: String {
        "\(Int(rounded()))°"
    }
}
