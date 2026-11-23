import SwiftUI

/// Loading state from SPEC.md §6: keep the previous data visible but dimmed, with a spinner
/// on top, so the screen is never blank while a request is in flight (W-22, W-33).
private struct LoadingOverlay: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0.4 : 1)
            .allowsHitTesting(!isLoading)
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .accessibilityLabel("Loading forecast")
                }
            }
            .animation(.default, value: isLoading)
    }
}

extension View {
    func loadingOverlay(isLoading: Bool) -> some View {
        modifier(LoadingOverlay(isLoading: isLoading))
    }
}
