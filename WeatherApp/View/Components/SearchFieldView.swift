import SwiftUI

/// One field for both a city name and "lat, lon" (W-14). Deciding which one it is
/// belongs to `CoordinateValidator`, not to this view.
struct SearchFieldView: View {
    @Binding var text: String
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField("City or 59.33, 18.07", text: $text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(Spacing.md)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: CornerRadius.control))
    }
}

#Preview {
    SearchFieldView(text: .constant(""), onSubmit: {})
        .padding()
}
