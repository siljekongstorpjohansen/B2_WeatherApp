import SwiftUI

/// Shown above cached data when there is no network (W-17).
struct OfflineBannerView: View {
    let lastUpdated: Date

    var body: some View {
        Label(
            "You're offline. Showing data from \(lastUpdated.formatted(date: .omitted, time: .shortened)).",
            systemImage: "wifi.slash"
        )
        .font(.footnote)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.warningBackground, in: RoundedRectangle(cornerRadius: CornerRadius.control))
    }
}

#Preview {
    OfflineBannerView(lastUpdated: .now)
        .padding()
}
