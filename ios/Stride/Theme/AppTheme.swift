import SwiftUI

// MARK: - App Theme (Headspace warmth + Dusk Lavender Palette)

enum AppTheme {
    // Primary Dusk Lavender palette
    static let primary = Color(hex: "6B63B5")
    static let primaryLight = Color(hex: "8A83CE")
    static let primarySubtle = Color(hex: "E8E5F7")
    
    // Soft Peach / Coral Accent
    static let accent = Color(hex: "F0A98C")
    static let accentLight = Color(hex: "FCEEE8")
    
    // Grounds and Surfaces
    static let background = Color(hex: "F6F4F9")
    static let surface = Color(hex: "FFFFFF")
    static let surfaceElevated = Color(hex: "FAF9FC")
    
    // Ink / Text
    static let ink = Color(hex: "2B2A38")
    static let inkSecondary = Color(hex: "706E80")
    static let inkTertiary = Color(hex: "A3A1B2")
    
    // Semantic States
    static let success = Color(hex: "6BBF8C")
    static let successSubtle = Color(hex: "EDF7F1")
    static let cardBorder = Color(hex: "2B2A38").opacity(0.04)

    // Typography Ramp (Headspace-inspired rounded styling)
    static let largeDisplayFont: Font = .system(size: 38, weight: .bold, design: .rounded)
    static let displayFont: Font = .system(size: 30, weight: .bold, design: .rounded)
    static let titleFont: Font = .system(size: 22, weight: .bold, design: .rounded)
    static let headlineFont: Font = .system(size: 17, weight: .semibold, design: .rounded)
    static let bodyFont: Font = .system(size: 16, weight: .regular, design: .default)
    static let calloutFont: Font = .system(size: 15, weight: .medium, design: .default)
    static let subheadlineFont: Font = .system(size: 14, weight: .regular, design: .default)
    static let captionFont: Font = .system(size: 12, weight: .medium, design: .default)
    static let numeralFont: Font = .system(size: 32, weight: .bold, design: .rounded)
    static let statHeroFont: Font = .system(size: 44, weight: .bold, design: .rounded)

    // Spacing
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 48
        static let screenMargin: CGFloat = 20
    }

    // Radii
    enum Radius {
        static let small: CGFloat = 8
        static let card: CGFloat = 16
        static let largeCard: CGFloat = 22
        static let sheet: CGFloat = 28
    }
}

// MARK: - Color Hex Initializer Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r, g, b, a: Double
            if hex.count == 8 {
                r = Double((hexNumber & 0xff000000) >> 24) / 255
                g = Double((hexNumber & 0x00ff0000) >> 16) / 255
                b = Double((hexNumber & 0x0000ff00) >> 8) / 255
                a = Double(hexNumber & 0x000000ff) / 255
            } else {
                r = Double((hexNumber & 0xff0000) >> 16) / 255
                g = Double((hexNumber & 0x00ff00) >> 8) / 255
                b = Double(hexNumber & 0x0000ff) / 255
                a = 1.0
            }
            self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
            return
        }
        self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
    }
}

// MARK: - Button & Card View Modifiers
struct CalmCardModifier: ViewModifier {
    var padding: CGFloat = AppTheme.Spacing.md
    var cornerRadius: CGFloat = AppTheme.Radius.card
    var background: Color = AppTheme.surface

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: AppTheme.ink.opacity(0.04), radius: 8, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
    }
}

struct PrimaryPressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func calmCard(
        padding: CGFloat = AppTheme.Spacing.md,
        cornerRadius: CGFloat = AppTheme.Radius.card,
        background: Color = AppTheme.surface
    ) -> some View {
        modifier(CalmCardModifier(padding: padding, cornerRadius: cornerRadius, background: background))
    }
}
