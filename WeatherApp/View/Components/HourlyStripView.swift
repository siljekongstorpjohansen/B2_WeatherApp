import SwiftUI

/// Horizontal hour-by-hour strip (W-13): today on the start screen, one day on the detail screen.
struct HourlyStripView: View {
    /// Plain values for one hour. Which hours count as "today" is decided before this view.
    typealias Hour = ForecastDisplay.Hour

    let hours: [Hour]
    /// "Today" on the start screen; "Hour by hour" on the day detail screen (W-03).
    var title = "Today"
    /// The place's time zone, so "08" means 08:00 there, not on the phone (SPEC.md §8).
    var timeZone: TimeZone = .current

    @Environment(\.timeFormat) private var timeFormat

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: title)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xl) {
                    ForEach(hours) { hour in
                        column(for: hour)
                    }
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: CornerRadius.card))
    }

    private func column(for hour: Hour) -> some View {
        let timeText = hour.isNow ? "Now" : hour.time.hourText(timeFormat, timeZone: timeZone)
        return VStack(spacing: Spacing.sm) {
            Text(timeText)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Image(systemName: hour.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.title3)
            Text(hour.temperature.degreesText)
                .font(.body.weight(.medium))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(timeText), \(hour.conditionText), \(hour.temperature.degreesText)")
    }
}

#Preview {
    HourlyStripView(hours: SampleData.hours)
        .padding()
}
