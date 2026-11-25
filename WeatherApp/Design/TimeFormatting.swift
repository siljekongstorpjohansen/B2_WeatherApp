import SwiftUI

extension EnvironmentValues {
    /// 12- or 24-hour clock from Settings, set once at the root so every view can read it (W-06, SPEC.md §8).
    @Entry var timeFormat: UserSettings.TimeFormat = .twentyFourHour
}

extension Date {
    /// Hour label for the hourly strip: "08" (24-hour) or "8 AM" (12-hour), in `timeZone`.
    func hourText(_ format: UserSettings.TimeFormat, timeZone: TimeZone) -> String {
        switch format {
        case .twentyFourHour: formatted(Self.verbatim(TimePattern.hourOnly24, timeZone))
        case .twelveHour: formatted(Self.verbatim(TimePattern.hourOnly12, timeZone))
        }
    }

    /// Time with minutes: "14:53" (24-hour) or "2:53 PM" (12-hour), in `timeZone`.
    func timeText(_ format: UserSettings.TimeFormat, timeZone: TimeZone) -> String {
        switch format {
        case .twentyFourHour: formatted(Self.verbatim(TimePattern.hourMinute24, timeZone))
        case .twelveHour: formatted(Self.verbatim(TimePattern.hourMinute12, timeZone))
        }
    }

    /// A fixed pattern, so the setting wins over the phone's own 12/24-hour preference.
    private static func verbatim(_ format: Date.FormatString, _ timeZone: TimeZone) -> Date.VerbatimFormatStyle {
        Date.VerbatimFormatStyle(
            format: format,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timeZone,
            calendar: Calendar(identifier: .gregorian)
        )
    }
}

/// The four time patterns, written once.
private enum TimePattern {
    /// "08"
    static var hourOnly24: Date.FormatString {
        "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))"
    }
    /// "8 AM"
    static var hourOnly12: Date.FormatString {
        "\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .oneBased)) \(dayPeriod: .standard(.abbreviated))"
    }
    /// "14:53"
    static var hourMinute24: Date.FormatString {
        "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)"
    }
    /// "2:53 PM"
    static var hourMinute12: Date.FormatString {
        "\(hour: .defaultDigits(clock: .twelveHour, hourCycle: .oneBased)):\(minute: .twoDigits) \(dayPeriod: .standard(.abbreviated))"
    }
}
