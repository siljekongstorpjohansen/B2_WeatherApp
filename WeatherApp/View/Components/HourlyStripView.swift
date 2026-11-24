import SwiftUI

/// Horizontal hour-by-hour strip for today (W-13).
struct HourlyStripView: View {
    /// Plain values for one hour. Which hours count as "today" is decided before this view.
    typealias Hour = ForecastDisplay.Hour

    let hours: [Hour]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: "Today")

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
        let timeText = hour.isNow ? "Now" : hour.time.formatted(.dateTime.hour())
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
