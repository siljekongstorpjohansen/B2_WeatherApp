import SwiftUI

/// One tile on the day detail screen: icon + label, a large value, and an optional
/// line of extra text underneath (W-03, W-32).
struct DetailTileView<Accessory: View>: View {
    let title: String
    let systemImage: String
    /// Shown large. "—" when the API didn't send the value (W-22).
    let value: String
    var footnote: String? = nil
    /// Optional small graphic next to the value, e.g. the wind direction arrow.
    @ViewBuilder var accessory: Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Label(title, systemImage: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                Text(value)
                    .font(.title2.weight(.medium))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                accessory
            }

            if let footnote {
                Text(footnote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: DetailTile.minHeight, alignment: .topLeading)
        .padding(Spacing.lg)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: CornerRadius.card))
        .accessibilityElement(children: .combine)
    }
}

extension DetailTileView where Accessory == EmptyView {
    /// A tile without a graphic next to the value.
    init(title: String, systemImage: String, value: String, footnote: String? = nil) {
        self.init(title: title, systemImage: systemImage, value: value, footnote: footnote) {
            EmptyView()
        }
    }
}

#Preview {
    VStack {
        DetailTileView(title: "UV index", systemImage: "sun.max", value: "1", footnote: "Low")
        DetailTileView(title: "Feels like", systemImage: "thermometer.medium", value: "—")
    }
    .padding()
}
