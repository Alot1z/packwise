import SwiftUI

// MARK: - PackWise Design System

/// Central design tokens for the PackWise visual identity.
/// Warm, travel-oriented, tactile — never generic enterprise/SaaS.
///
/// Principles:
/// - **Warm**: amber/terracotta primary, cream backgrounds, golden accents
/// - **Premium**: controlled spacing, refined typography, subtle materials
/// - **Tactile**: controls feel physical — haptics, spring animations, depth
/// - **Calm**: restrained color palette, clear hierarchy, no visual noise
/// - **Travel**: evokes clothing, preparation, discovery, movement

enum PackWiseDesign {
    // MARK: - Color Palette

    enum Color {
        // Primary: warm terracotta — the brand anchor
        static let primary = SwiftUI.Color("PackWisePrimary", bundle: nil)
        static let primaryLight = SwiftUI.Color(red: 0.92, green: 0.45, blue: 0.32)
        static let primaryDark = SwiftUI.Color(red: 0.75, green: 0.32, blue: 0.20)

        // Secondary: deep teal — calm, trustworthy, travel-marine
        static let secondary = SwiftUI.Color(red: 0.15, green: 0.42, blue: 0.42)
        static let secondaryLight = SwiftUI.Color(red: 0.20, green: 0.55, blue: 0.55)

        // Accent: golden amber — warmth, highlights, progress
        static let accent = SwiftUI.Color(red: 0.90, green: 0.65, blue: 0.20)
        static let accentLight = SwiftUI.Color(red: 0.96, green: 0.80, blue: 0.45)

        // Backgrounds: warm off-white base
        static let background = SwiftUI.Color(red: 0.97, green: 0.96, blue: 0.94)
        static let surface = SwiftUI.Color(red: 0.99, green: 0.98, blue: 0.97)
        static let surfaceSecondary = SwiftUI.Color(red: 0.94, green: 0.92, blue: 0.90)

        // Semantic
        static let success = SwiftUI.Color(red: 0.22, green: 0.62, blue: 0.35)
        static let warning = SwiftUI.Color(red: 0.72, green: 0.36, blue: 0.0)
        static let error = SwiftUI.Color(red: 0.74, green: 0.18, blue: 0.12)
        static let info = SwiftUI.Color(red: 0.15, green: 0.42, blue: 0.60)

        // Text
        static let textPrimary = SwiftUI.Color(red: 0.15, green: 0.13, blue: 0.12)
        static let textSecondary = SwiftUI.Color(red: 0.42, green: 0.38, blue: 0.35)
        static let textTertiary = SwiftUI.Color(red: 0.60, green: 0.55, blue: 0.52)

        // Dark mode overrides
        static let darkBackground = SwiftUI.Color(red: 0.10, green: 0.08, blue: 0.07)
        static let darkSurface = SwiftUI.Color(red: 0.16, green: 0.14, blue: 0.12)
    }

    // MARK: - Typography

    enum Typography {
        static let titleLarge = Font.system(.title, design: .serif).weight(.bold)
        static let titleMedium = Font.system(.title2, design: .serif).weight(.semibold)
        static let titleSmall = Font.system(.title3, design: .serif).weight(.medium)

        static let headline = Font.system(.headline, design: .default).weight(.semibold)
        static let subheadline = Font.system(.subheadline, design: .default).weight(.medium)
        static let body = Font.system(.body, design: .default)
        static let bodyBold = Font.system(.body, design: .default).weight(.semibold)
        static let caption = Font.system(.caption, design: .default)
        static let captionBold = Font.system(.caption, design: .default).weight(.semibold)
        static let caption2 = Font.system(.caption2, design: .default)

        static let mono = Font.system(.caption, design: .monospaced)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let section: CGFloat = 20
    }

    // MARK: - Corner Radii

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows (light mode)

    enum Shadow {
        static let subtle = SwiftUI.Color.black.opacity(0.04)
        static let card = SwiftUI.Color.black.opacity(0.06)
        static let elevated = SwiftUI.Color.black.opacity(0.10)

        static let radiusSubtle: CGFloat = 4
        static let radiusCard: CGFloat = 8
        static let radiusElevated: CGFloat = 16
    }

    // MARK: - Animation Timing

    enum Animation {
        static let fast = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let standard = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let slow = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - View Modifiers

/// Applies the warm PackWise card style: off-white surface, subtle shadow, rounded corners.
struct PackWiseCard: ViewModifier {
    var elevated: Bool = false
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .padding(PackWiseDesign.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PackWiseDesign.Radius.lg)
                    .fill(scheme == .dark ? PackWiseDesign.Color.darkSurface : PackWiseDesign.Color.surface)
            )
            .shadow(
                color: elevated ? PackWiseDesign.Shadow.elevated : PackWiseDesign.Shadow.card,
                radius: elevated ? PackWiseDesign.Shadow.radiusElevated : PackWiseDesign.Shadow.radiusCard,
                y: elevated ? 4 : 2
            )
    }
}

/// Warm label chip — compact category/tag pill.
struct PackWiseChip: ViewModifier {
    var color: SwiftUI.Color = PackWiseDesign.Color.primaryLight
    func body(content: Content) -> some View {
        content
            .font(PackWiseDesign.Typography.captionBold)
            .foregroundStyle(PackWiseDesign.Color.textPrimary)
            .padding(.horizontal, PackWiseDesign.Spacing.md)
            .padding(.vertical, PackWiseDesign.Spacing.xs)
            .background(color.opacity(0.18), in: Capsule())
    }
}

/// Section header — serif, warm
struct PackWiseSectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(PackWiseDesign.Typography.titleSmall)
            .foregroundStyle(PackWiseDesign.Color.textPrimary)
    }
}

// MARK: - Convenience extensions

extension View {
    func packWiseCard(elevated: Bool = false) -> some View {
        modifier(PackWiseCard(elevated: elevated))
    }

    func packWiseChip(color: SwiftUI.Color = PackWiseDesign.Color.primaryLight) -> some View {
        modifier(PackWiseChip(color: color))
    }

    func packWiseSectionHeader() -> some View {
        modifier(PackWiseSectionHeader())
    }
}
