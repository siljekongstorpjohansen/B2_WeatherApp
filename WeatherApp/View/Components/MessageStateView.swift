import SwiftUI

/// Full-area message for empty and error states, so they all look the same (W-33).
struct MessageStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview("Error") {
    MessageStateView(
        title: "Couldn't load the forecast",
        message: "Check your connection and try again.",
        systemImage: "icloud.slash",
        actionTitle: "Try again",
        action: {}
    )
}
