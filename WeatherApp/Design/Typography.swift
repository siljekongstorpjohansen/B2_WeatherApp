import SwiftUI

extension Font {
    /// The large current temperature — the most prominent element on the start screen.
    static let heroTemperature = Font.system(size: 72, weight: .thin, design: .rounded)
    /// The "°C" / "°F" beside the large temperature: same family, much smaller (SPEC.md §6).
    static let heroTemperatureUnit = Font.system(size: 28, weight: .light, design: .rounded)
    /// High / low on the day detail screen: same style as the hero, one step smaller.
    static let dayTemperature = Font.system(size: 44, weight: .thin, design: .rounded)
}

extension Double {
    /// Rounded to a whole number, e.g. `1.8` → `"2"`.
    var wholeNumberText: String {
        "\(Int(rounded()))"
    }

    /// Whole degrees without unit letter, e.g. `1.8` → `"2°"`.
    var degreesText: String {
        "\(wholeNumberText)°"
    }

    /// Whole number with the wind unit from Settings, e.g. `21.2` → `"21 km/h"` (W-06).
    func speedText(_ unit: UserSettings.WindSpeedUnit) -> String {
        "\(wholeNumberText) \(unit.title)"
    }
}

/// Placement of the unit beside the large temperature.
enum HeroUnit {
    /// How far the "°C" / "°F" is raised above the number's baseline, so it reads like a superscript.
    static let raise: CGFloat = 34
}
