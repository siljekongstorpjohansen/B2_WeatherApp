import SwiftUI

/// The top of the start screen: place, current temperature and condition (W-02, W-12).
struct CurrentConditionsView: View {
    /// Plain values to display, built by `ForecastViewModel` (SPEC.md §8, 2026-11-24).
    typealias Conditions = ForecastDisplay.Conditions

    let conditions: Conditions
    let isFavourite: Bool
    var onToggleFavourite: () -> Void

    @Environment(\.timeFormat) private var timeFormat

    var body: some View {
        VStack(spacing: Spacing.xs) {
            HStack(spacing: Spacing.sm) {
                Text(conditions.placeName)
                    .font(.title2.weight(.semibold))
                Button(action: onToggleFavourite) {
                    Image(systemName: isFavourite ? "star.fill" : "star")
                        .font(.title3)
                }
                .accessibilityLabel(isFavourite ? "Remove from favourites" : "Add to favourites")
            }

            // When this phone loaded it, so the phone's own time zone.
            Text("Updated \(conditions.updatedAt.timeText(timeFormat, timeZone: .current))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: conditions.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.largeTitle)
                .padding(.top, Spacing.sm)
                .accessibilityHidden(true)

            // The number stays the hero; the unit sits smaller and raised beside it (SPEC.md §6, W-06).
            HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                Text(conditions.temperature.wholeNumberText)
                    .font(.heroTemperature)
                Text(conditions.temperatureUnit.title)
                    .font(.heroTemperatureUnit)
                    .foregroundStyle(.secondary)
                    .baselineOffset(HeroUnit.raise)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "\(conditions.temperature.wholeNumberText) degrees \(conditions.temperatureUnit.spokenName), \(conditions.conditionText)"
            )

            Text(conditions.conditionText)
                .font(.title3)
                .accessibilityHidden(true)

            Text("H \(conditions.high.degreesText)   L \(conditions.low.degreesText)")
                .foregroundStyle(.secondary)
                .accessibilityLabel("High \(conditions.high.degreesText), low \(conditions.low.degreesText)")

            Label(conditions.windSpeed.speedText(conditions.windSpeedUnit), systemImage: "wind")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Wind \(conditions.windSpeed.wholeNumberText) \(conditions.windSpeedUnit.spokenName)")
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CurrentConditionsView(conditions: SampleData.conditions, isFavourite: true, onToggleFavourite: {})
}
