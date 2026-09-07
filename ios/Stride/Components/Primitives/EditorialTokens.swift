// 10x primitive: headspace/design-tokens v1
import SwiftUI

/// Central design tokens for the warm editorial language. The app's whole
/// theme lives here: retheme by editing these values, add new tokens here,
/// and never hardcode colors or fonts in views.
///
/// Values follow the observed spec in `../REFERENCE.md`: warm off-white
/// sheet, white cards with whisper shadows, warm-charcoal ink, vivid blue
/// CTAs, brand orange leading illustration, saturated category panes, a dark
/// navy sleep sub-world, and one rounded sans with heavy display numerals.
@available(iOS 17.0, *)
enum EditorialTokens {
    // MARK: Grounds & surfaces
    /// Warm off-white sheet the daytime app sits on (observed `#F7F3EE`).
    static let ground: Color = Color(red: 0.97, green: 0.95, blue: 0.93)
    /// Card white; pair with `shadow` for the whisper elevation.
    static let surface: Color = .white
    static let surfaceRaised: Color = .white
    /// Whisper card shadow (black 6%).
    static let shadow: Color = Color.black.opacity(0.06)
    /// Near-black navy ground of the sleep sub-world (observed `#181A33`).
    static let nightGround: Color = Color(red: 0.09, green: 0.10, blue: 0.20)
    /// Navy sleep-world card (observed `#1F2142`).
    static let nightSurface: Color = Color(red: 0.12, green: 0.13, blue: 0.26)

    // MARK: Ink
    /// Warm dark charcoal — never pure black (observed `#3E3A36`).
    static let ink: Color = Color(red: 0.24, green: 0.23, blue: 0.21)
    /// Warm gray metadata (observed `#6D6862`).
    static let inkSecondary: Color = Color(red: 0.43, green: 0.41, blue: 0.38)
    static let inkOnAccent: Color = .white
    /// White titles in the sleep sub-world.
    static let nightInk: Color = .white
    /// Gray-lavender sleep-world secondary (observed `(0.62, 0.62, 0.72)`).
    static let nightInkSecondary: Color = Color(red: 0.62, green: 0.62, blue: 0.72)

    // MARK: Accent & semantics
    /// Vivid CTA blue — "blue means go" (observed `#0061EF`).
    static let accent: Color = Color(red: 0.0, green: 0.38, blue: 0.94)
    static let accentSoft: Color = Color(red: 0.0, green: 0.38, blue: 0.94).opacity(0.12)
    /// Brand/illustration orange — never the CTA (observed `#F47D31`).
    static let brandOrange: Color = Color(red: 0.96, green: 0.49, blue: 0.19)
    static let positive: Color = Color(red: 0.16, green: 0.60, blue: 0.38)
    static let negative: Color = Color(red: 0.83, green: 0.30, blue: 0.24)
    /// Amber band hue doubling as the warning tone (observed `#FFA713`).
    static let warning: Color = Color(red: 1.0, green: 0.65, blue: 0.07)

    // MARK: Saturated illustration panes
    static let paneOrange: Color = Color(red: 0.75, green: 0.37, blue: 0.17)   // #C05F2B
    static let paneIndigo: Color = Color(red: 0.24, green: 0.20, blue: 0.53)   // #3E3487
    static let paneMagenta: Color = Color(red: 0.78, green: 0.36, blue: 0.61)  // #C75B9B
    static let paneBlue: Color = Color(red: 0.16, green: 0.42, blue: 0.83)     // #2A6BD4
    static let paneYellow: Color = Color(red: 1.0, green: 0.85, blue: 0.20)    // #FFD833

    // MARK: Radii
    static let radiusCard: CGFloat = 16
    static let radiusControl: CGFloat = 12
    static let radiusSheet: CGFloat = 24

    // MARK: Type
    /// Proud heavy rounded numerals — count-ups are a feature.
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static let titleFont: Font = .system(.title2, design: .rounded, weight: .bold)
    static let headlineFont: Font = .system(.headline, design: .rounded, weight: .bold)
    static let bodyFont: Font = .system(.body, design: .rounded)
    static let captionFont: Font = .system(.caption, design: .rounded, weight: .medium)
    /// Sentence-case dot-separated metadata ("Course • 10 min").
    static let metaFont: Font = .system(.footnote, design: .rounded)
}

#Preview("Token swatches") {
    if #available(iOS 17.0, *) {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Headspace tokens")
                    .font(EditorialTokens.titleFont)
                    .foregroundStyle(EditorialTokens.ink)
                HStack(spacing: 10) {
                    ForEach(
                        [
                            ("paneOrange", EditorialTokens.paneOrange),
                            ("paneIndigo", EditorialTokens.paneIndigo),
                            ("paneMagenta", EditorialTokens.paneMagenta),
                            ("paneBlue", EditorialTokens.paneBlue),
                        ],
                        id: \.0
                    ) { name, color in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: EditorialTokens.radiusControl)
                                .fill(color)
                                .frame(height: 52)
                            Text(name)
                                .font(EditorialTokens.captionFont)
                                .foregroundStyle(EditorialTokens.inkSecondary)
                        }
                    }
                }
                HStack(spacing: 10) {
                    ForEach(
                        [
                            ("accent", EditorialTokens.accent),
                            ("brandOrange", EditorialTokens.brandOrange),
                            ("positive", EditorialTokens.positive),
                            ("negative", EditorialTokens.negative),
                            ("warning", EditorialTokens.warning),
                        ],
                        id: \.0
                    ) { name, color in
                        VStack(spacing: 6) {
                            Circle().fill(color).frame(width: 40, height: 40)
                            Text(name)
                                .font(EditorialTokens.captionFont)
                                .foregroundStyle(EditorialTokens.inkSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: EditorialTokens.radiusCard)
                        .fill(EditorialTokens.nightGround)
                        .frame(height: 52)
                        .overlay {
                            Text("nightGround")
                                .font(EditorialTokens.captionFont)
                                .foregroundStyle(EditorialTokens.nightInkSecondary)
                        }
                    RoundedRectangle(cornerRadius: EditorialTokens.radiusCard)
                        .fill(EditorialTokens.nightSurface)
                        .frame(height: 52)
                        .overlay {
                            Text("nightSurface")
                                .font(EditorialTokens.captionFont)
                                .foregroundStyle(EditorialTokens.nightInkSecondary)
                        }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Everything rounded, hierarchy by weight")
                        .font(EditorialTokens.headlineFont)
                        .foregroundStyle(EditorialTokens.ink)
                    Text("Course • 10 min")
                        .font(EditorialTokens.metaFont)
                        .foregroundStyle(EditorialTokens.inkSecondary)
                    Text("342")
                        .font(EditorialTokens.display(30))
                        .monospacedDigit()
                        .foregroundStyle(EditorialTokens.ink)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    EditorialTokens.surface,
                    in: RoundedRectangle(cornerRadius: EditorialTokens.radiusCard, style: .continuous)
                )
                .shadow(color: EditorialTokens.shadow, radius: 8, y: 3)
            }
            .padding(24)
        }
        .background(EditorialTokens.ground.ignoresSafeArea())
    }
}
