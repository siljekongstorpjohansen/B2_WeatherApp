import SwiftUI

/// The 7-day overview (W-12, W-20). Each row navigates to the day's detail screen (W-03).
struct DailyForecastListView: View {
    /// Plain values for one day.
    struct Day: Identifiable {
        let date: Date
        let isToday: Bool
        let symbolName: String
        let conditionText: String
        let low: Double
        let high: Double

        var id: Date { date }
    }

    let days: [Day]

    // The bars share one scale, so the coldest and warmest days of the week line up.
    private var weekLow: Double { days.map(\.low).min() ?? 0 }
    private var weekHigh: Double { days.map(\.high).max() ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderView(title: "7 days")
                .padding(.bottom, Spacing.xs)

            ForEach(days) { day in
                NavigationLink(value: day.date) {
                    DayRowView(day: day, weekLow: weekLow, weekHigh: weekHigh)
                }
                .buttonStyle(.plain)

                if day.id != days.last?.id {
                    Divider()
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: CornerRadius.card))
    }
}

private struct DayRowView: View {
    let day: DailyForecastListView.Day
    let weekLow: Double
    let weekHigh: Double

    // Scaled so the columns grow with Dynamic Type.
    @ScaledMetric private var dayColumnWidth: CGFloat = 52
    @ScaledMetric private var iconColumnWidth: CGFloat = 28
    @ScaledMetric private var temperatureColumnWidth: CGFloat = 36

    private var dayText: String {
        day.isToday ? "Today" : day.date.formatted(.dateTime.weekday(.abbreviated))
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(dayText)
                .frame(width: dayColumnWidth, alignment: .leading)
            Image(systemName: day.symbolName)
                .symbolRenderingMode(.multicolor)
                .frame(width: iconColumnWidth)
            Text(day.low.degreesText)
                .foregroundStyle(.secondary)
                .frame(width: temperatureColumnWidth, alignment: .trailing)
            TemperatureRangeBar(low: day.low, high: day.high, scaleLow: weekLow, scaleHigh: weekHigh)
            Text(day.high.degreesText)
                .frame(width: temperatureColumnWidth, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, Spacing.md)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(dayText), \(day.conditionText), low \(day.low.degreesText), high \(day.high.degreesText)")
    }
}

/// A bar showing where the day's low–high range sits within the week's range.
private struct TemperatureRangeBar: View {
    let low: Double
    let high: Double
    let scaleLow: Double
    let scaleHigh: Double

    private let barHeight: CGFloat = Spacing.xs

    var body: some View {
        GeometryReader { geometry in
            let span = max(scaleHigh - scaleLow, 1)
            let startFraction = (low - scaleLow) / span
            let widthFraction = (high - low) / span

            ZStack(alignment: .leading) {
                Capsule().fill(Color.rangeTrack)
                Capsule()
                    .fill(Color.accentColor)
                    .frame(width: max(geometry.size.width * widthFraction, barHeight))
                    .offset(x: geometry.size.width * startFraction)
            }
        }
        .frame(height: barHeight)
    }
}

#Preview {
    NavigationStack {
        DailyForecastListView(days: SampleData.days)
            .padding()
    }
}
