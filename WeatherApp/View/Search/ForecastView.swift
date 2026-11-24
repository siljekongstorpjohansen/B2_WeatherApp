import SwiftUI

/// Current conditions + today's hours + 7 days. One column in portrait,
/// two columns in landscape and on iPad (W-18).
struct ForecastView: View {
    let conditions: CurrentConditionsView.Conditions
    let hours: [HourlyStripView.Hour]
    let days: [DailyForecastListView.Day]
    let isFavourite: Bool
    var onToggleFavourite: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // iPhone landscape has a compact height; iPad has a regular width.
    private var usesTwoColumns: Bool {
        horizontalSizeClass == .regular || verticalSizeClass == .compact
    }

    var body: some View {
        if usesTwoColumns {
            HStack(alignment: .top, spacing: Spacing.xl) {
                ScrollView {
                    currentConditions
                        .padding(.vertical, Spacing.xl)
                }
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        HourlyStripView(hours: hours)
                        DailyForecastListView(days: days)
                    }
                    .padding(.vertical, Spacing.sm)
                }
            }
        } else {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    currentConditions
                        .padding(.vertical, Spacing.lg)
                    HourlyStripView(hours: hours)
                    DailyForecastListView(days: days)
                }
                .padding(.bottom, Spacing.lg)
            }
        }
    }

    private var currentConditions: some View {
        CurrentConditionsView(conditions: conditions, isFavourite: isFavourite, onToggleFavourite: onToggleFavourite)
    }
}
