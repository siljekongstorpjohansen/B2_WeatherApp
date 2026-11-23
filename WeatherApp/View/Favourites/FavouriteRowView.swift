import SwiftUI

/// One row in the favourites list. The subtitle follows the sort order, so the user
/// can see why the list is in this order.
struct FavouriteRowView: View {
    let favourite: Favourite
    let sortOrder: FavouriteSortOrder

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "star.fill")
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(favourite.placeName)
                    .font(.body.weight(.semibold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Shows the weather for \(favourite.placeName)")
    }

    private var subtitle: String {
        switch sortOrder {
        case .mostViewed:
            favourite.openCount == 1 ? "Opened 1 time" : "Opened \(favourite.openCount) times"
        case .alphabetical:
            coordinatesText
        case .recentlyAdded:
            "Added \(favourite.dateAdded.formatted(.dateTime.day().month(.abbreviated)))"
        }
    }

    /// "59.33° N  18.07° E". Compass letters keep the two numbers apart in locales that
    /// use a comma as decimal separator ("59,33, 18,07" would be ambiguous).
    private var coordinatesText: String {
        let format = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(2))
        let latitudeText = "\(abs(favourite.latitude).formatted(format))° \(favourite.latitude >= 0 ? "N" : "S")"
        let longitudeText = "\(abs(favourite.longitude).formatted(format))° \(favourite.longitude >= 0 ? "E" : "W")"
        return "\(latitudeText)  \(longitudeText)"
    }
}

#Preview {
    List {
        ForEach(FavouriteSortOrder.allCases) { order in
            FavouriteRowView(favourite: SampleData.favourites[0], sortOrder: order)
        }
    }
}
