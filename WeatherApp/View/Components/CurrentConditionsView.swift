import SwiftUI

/// The top of the start screen: place, current temperature and condition (W-02, W-12).
struct CurrentConditionsView: View {
    /// Plain values to display, built by `ForecastViewModel` (SPEC.md §8, 2026-11-24).
    typealias Conditions = ForecastDisplay.Conditions

    let conditions: Conditions
    let isFavourite: Bool
    var onToggleFavourite: () -> Void

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

            Text("Updated \(conditions.updatedAt.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)

            Image(systemName: conditions.symbolName)
                .symbolRenderingMode(.multicolor)
                .font(.largeTitle)
                .padding(.top, Spacing.sm)
                .accessibilityHidden(true)

            Text(conditions.temperature.degreesText)
                .font(.heroTemperature)
                .accessibilityLabel("\(conditions.temperature.degreesText), \(conditions.conditionText)")

            Text(conditions.conditionText)
                .font(.title3)
                .accessibilityHidden(true)

            Text("H \(conditions.high.degreesText)   L \(conditions.low.degreesText)")
                .foregroundStyle(.secondary)
                .accessibilityLabel("High \(conditions.high.degreesText), low \(conditions.low.degreesText)")

            Label("\(Int(conditions.windSpeedKilometresPerHour.rounded())) km/h", systemImage: "wind")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Wind \(Int(conditions.windSpeedKilometresPerHour.rounded())) kilometres per hour")
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CurrentConditionsView(conditions: SampleData.conditions, isFavourite: true, onToggleFavourite: {})
}
