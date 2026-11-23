import SwiftUI

/// Horizontal row of favourite places for one-tap switching (W-05).
struct FavouriteChipsView: View {
    // Names are used as identity for now; switch to the real `Place` type once it exists,
    // since two places can share a name.
    let placeNames: [String]
    let selectedPlaceName: String?
    var onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(placeNames, id: \.self) { name in
                    chip(for: name)
                }
            }
        }
    }

    private func chip(for name: String) -> some View {
        let isSelected = name == selectedPlaceName
        return Button {
            onSelect(name)
        } label: {
            Label(name, systemImage: isSelected ? "star.fill" : "star")
                .font(.subheadline)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .background(
                    Capsule().fill(isSelected ? Color.accentColor.opacity(0.15) : Color.cardBackground)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    FavouriteChipsView(placeNames: ["Stockholm", "Oslo", "Bergen"], selectedPlaceName: "Stockholm", onSelect: { _ in })
        .padding()
}
