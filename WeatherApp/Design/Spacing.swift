import SwiftUI

/// Spacing scale from STYLE.md §6. Use these instead of literal numbers in views.
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

/// Corner radii, so every card and control has the same rounding.
enum CornerRadius {
    static let control: CGFloat = 10
    static let card: CGFloat = 16
}
