import Foundation

/// The orders the favourites list can be sorted in (SPEC.md §6, W-05).
enum FavouriteSortOrder: String, CaseIterable, Codable, Identifiable {
    case mostViewed
    case alphabetical
    case recentlyAdded

    var id: Self { self }

    var title: String {
        switch self {
        case .mostViewed: "Most viewed"
        case .alphabetical: "A–Z"
        case .recentlyAdded: "Recently added"
        }
    }

    /// Returns `favourites` in this order. Pure function, so it can be unit tested (W-23).
    func sorted(_ favourites: [Favourite]) -> [Favourite] {
        switch self {
        case .mostViewed:
            favourites.sorted { first, second in
                // Equal counts fall back to A–Z so the order never looks random.
                if first.openCount != second.openCount {
                    return first.openCount > second.openCount
                }
                return isAlphabeticallyBefore(first, second)
            }
        case .alphabetical:
            favourites.sorted(by: isAlphabeticallyBefore)
        case .recentlyAdded:
            favourites.sorted { $0.dateAdded > $1.dateAdded }
        }
    }

    /// Locale-aware, so "Ålesund" sorts the way a Nordic user expects and "a" equals "A".
    private func isAlphabeticallyBefore(_ first: Favourite, _ second: Favourite) -> Bool {
        first.placeName.localizedStandardCompare(second.placeName) == .orderedAscending
    }
}
