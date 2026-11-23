import SwiftUI

/// Small heading above a card ("Today", "7 days").
struct SectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .accessibilityAddTraits(.isHeader)
    }
}
