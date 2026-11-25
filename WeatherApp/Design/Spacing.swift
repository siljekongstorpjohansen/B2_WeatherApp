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

/// Maximum content widths, so lists don't stretch across a landscape iPhone or iPad (W-18).
enum ReadableWidth {
    static let list: CGFloat = 640
    /// Left column (header) of a two-column screen in landscape, e.g. the day detail header.
    static let sideColumn: CGFloat = 300
}

/// Sizes for the day detail tiles (W-03).
enum DetailTile {
    /// Narrowest a tile may get: 2 per row on an iPhone in portrait, more when there's room.
    static let minWidth: CGFloat = 150
    /// Every tile is at least this tall, so grid rows line up.
    static let minHeight: CGFloat = 88
}

/// Corner radii, so every card and control has the same rounding.
enum CornerRadius {
    static let control: CGFloat = 10
    static let card: CGFloat = 16
}
