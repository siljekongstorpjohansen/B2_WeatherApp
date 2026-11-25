import SwiftUI

/// Full forecast for one day, pushed from the 7-day list (SPEC.md §6, W-03).
/// One column in portrait; header on the left and details on the right in landscape
/// and on iPad (W-18).
struct DayDetailView: View {
    /// Built by `ForecastDisplay` from the loaded forecast.
    typealias Detail = ForecastDisplay.DayDetail

    let detail: Detail

    @Environment(\.timeFormat) private var timeFormat

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // Same rule as ForecastView: iPhone landscape has a compact height; iPad has a regular width.
    private var usesTwoColumns: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .compact
    }

    /// Tiles at least this wide: 2 per row on an iPhone in portrait, more when there's room.
    /// Top-aligned so a tile with a two-line footnote doesn't push its neighbour down.
    private let tileColumns = [
        GridItem(.adaptive(minimum: DetailTile.minWidth), spacing: Spacing.md, alignment: .top),
    ]

    var body: some View {
        Group {
            if usesTwoColumns {
                HStack(alignment: .top, spacing: Spacing.xl) {
                    ScrollView {
                        header
                            .padding(.vertical, Spacing.xl)
                    }
                    .frame(maxWidth: ReadableWidth.sideColumn)
                    ScrollView {
                        detailSections
                            .padding(.vertical, Spacing.sm)
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        header
                            .padding(.vertical, Spacing.lg)
                        detailSections
                    }
                    .padding(.bottom, Spacing.lg)
                }
            }
        }
        .padding(.horizontal, Spacing.lg)
        .navigationTitle(detail.date.formatted(weekdayStyle))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Spacing.xs) {
            Text(detail.date.formatted(fullDateStyle))
                .font(.title3.weight(.semibold))

            Image(systemName: detail.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.largeTitle)
                .padding(.top, Spacing.sm)
                .accessibilityHidden(true)

            Text(detail.conditionText)
                .font(.title3)

            HStack(spacing: Spacing.lg) {
                Text("H \(detail.high.degreesText)")
                Text("L \(detail.low.degreesText)")
                    .foregroundStyle(.secondary)
            }
            .font(.dayTemperature)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("High \(detail.high.degreesText), low \(detail.low.degreesText)")
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Hours + tiles

    private var detailSections: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            if !detail.hours.isEmpty {
                HourlyStripView(hours: detail.hours, title: "Hour by hour", timeZone: detail.timeZone)
            }

            SectionHeaderView(title: "Details")
            LazyVGrid(columns: tileColumns, spacing: Spacing.md) {
                feelsLikeTile
                precipitationTile
                windTile
                uvTile
                sunTile(title: "Sunrise", systemImage: "sunrise", time: detail.sunrise, footnote: daylightText)
                sunTile(title: "Sunset", systemImage: "sunset", time: detail.sunset)
            }
        }
    }

    private var feelsLikeTile: some View {
        DetailTileView(title: "Feels like", systemImage: "thermometer.medium", value: feelsLikeText)
    }

    private var precipitationTile: some View {
        let amount = detail.precipitationMillimetres.formatted(.number.precision(.fractionLength(0...1)))
        return DetailTileView(
            title: "Precipitation",
            systemImage: "drop",
            value: "\(amount) mm",
            footnote: detail.precipitationProbabilityPercent.map { "\($0)% chance" }
        )
    }

    private var windTile: some View {
        let gustText = detail.maxWindGust.map { "Gusts \($0.speedText(detail.windSpeedUnit))" }
        let directionText = detail.windDirectionDegrees.map { "from \(Self.compassPoint(for: $0))" }
        let footnote = [gustText, directionText].compactMap { $0 }.joined(separator: " · ")

        return DetailTileView(
            title: "Wind",
            systemImage: "wind",
            value: detail.maxWindSpeed.speedText(detail.windSpeedUnit),
            footnote: footnote.isEmpty ? nil : footnote
        ) {
            if let degrees = detail.windDirectionDegrees {
                // The arrow points where the wind blows *to*: wind from the north (0°) points down.
                Image(systemName: "location.north.fill")
                    .rotationEffect(.degrees(Double(degrees) + 180))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
            }
        }
    }

    private var uvTile: some View {
        DetailTileView(
            title: "UV index",
            systemImage: "sun.max",
            value: detail.uvIndex.map { String(Int($0.rounded())) } ?? "—",
            footnote: detail.uvIndex.map(Self.uvCategory)
        )
    }

    private func sunTile(title: String, systemImage: String, time: Date?, footnote: String? = nil) -> some View {
        DetailTileView(
            title: title,
            systemImage: systemImage,
            value: time.map(timeText) ?? "—",
            footnote: footnote
        )
    }

    // MARK: - Formatting

    /// Dates are shown in the place's time zone, like Open-Meteo sends them (`timezone=auto`).
    private var weekdayStyle: Date.FormatStyle {
        var style = Date.FormatStyle().weekday(.wide)
        style.timeZone = detail.timeZone
        return style
    }

    private var fullDateStyle: Date.FormatStyle {
        var style = Date.FormatStyle().weekday(.wide).day().month(.wide)
        style.timeZone = detail.timeZone
        return style
    }

    private func timeText(_ date: Date) -> String {
        date.timeText(timeFormat, timeZone: detail.timeZone)
    }

    /// "-2° / -9°", or "—" if either value is missing.
    private var feelsLikeText: String {
        guard let high = detail.feelsLikeHigh, let low = detail.feelsLikeLow else { return "—" }
        return "\(high.degreesText) / \(low.degreesText)"
    }

    /// "6 h 32 min of daylight", or `nil` if sunrise or sunset is missing.
    private var daylightText: String? {
        guard let sunrise = detail.sunrise, let sunset = detail.sunset, sunset > sunrise else { return nil }
        let minutes = Int(sunset.timeIntervalSince(sunrise) / 60)
        return "\(minutes / 60) h \(minutes % 60) min of daylight"
    }

    /// 0° → "N", 225° → "SW". Eight points are precise enough for a daily summary.
    private static func compassPoint(for degrees: Int) -> String {
        let points = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
        // Each point covers 45° centred on its direction, so shift by half a sector before dividing.
        let normalised = ((degrees % 360) + 360) % 360
        let index = Int((Double(normalised) + 22.5) / 45) % points.count
        return points[index]
    }

    /// WHO UV index categories.
    private static func uvCategory(for index: Double) -> String {
        switch index {
        case ..<3: "Low"
        case ..<6: "Moderate"
        case ..<8: "High"
        case ..<11: "Very high"
        default: "Extreme"
        }
    }
}

// MARK: - Previews

#Preview("Full data") {
    NavigationStack {
        DayDetailView(detail: SampleData.dayDetail())
    }
}

#Preview("Full data – landscape", traits: .landscapeLeft) {
    NavigationStack {
        DayDetailView(detail: SampleData.dayDetail())
    }
}

#Preview("Missing extras") {
    NavigationStack {
        DayDetailView(detail: SampleData.dayDetail(includeExtras: false))
    }
}
