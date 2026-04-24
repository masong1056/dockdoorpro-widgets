import SwiftUI

// MARK: - Arabic Font

/// Curated list of Arabic fonts that ship with macOS. Ordered roughly
/// from most Quranic / calligraphic to most utilitarian. Each font has
/// a per-face size multiplier so calligraphic scripts (Mishafi, Diwan
/// Thuluth, Farisi) don't render visually smaller than the system font
/// at the same point size.
enum ArabicFont: String, CaseIterable {
    case mishafi        = "Mishafi (Mushaf)"
    case mishafiGold    = "Mishafi Gold"
    case alBayan        = "Al Bayan"
    case decoTypeNaskh  = "DecoType Naskh"
    case geezaPro       = "Geeza Pro"
    case damascus       = "Damascus"
    case baghdad        = "Baghdad"
    case beirut         = "Beirut"
    case nadeem         = "Nadeem"
    case farisi         = "Farisi"
    case diwanThuluth   = "Diwan Thuluth"
    case diwanKufi      = "Diwan Kufi"
    case system         = "System"

    static func from(_ name: String) -> ArabicFont {
        ArabicFont(rawValue: name) ?? .mishafi
    }

    /// Font family name that SwiftUI's `Font.custom` resolves on macOS.
    /// If the family isn't installed, SwiftUI falls back to the system font.
    var familyName: String {
        switch self {
        case .mishafi:       return "Mishafi"
        case .mishafiGold:   return "Mishafi Gold"
        case .alBayan:       return "Al Bayan"
        case .decoTypeNaskh: return "DecoType Naskh"
        case .geezaPro:      return "Geeza Pro"
        case .damascus:      return "Damascus"
        case .baghdad:       return "Baghdad"
        case .beirut:        return "Beirut"
        case .nadeem:        return "Nadeem"
        case .farisi:        return "Farisi"
        case .diwanThuluth:  return "Diwan Thuluth"
        case .diwanKufi:     return "Diwan Kufi"
        case .system:        return ""
        }
    }

    /// Calligraphic Arabic faces reserve a huge chunk of their em-box for
    /// tashkeel clearance above/below the baseline, so the visible glyph body
    /// ends up much smaller than a system font at the same point size.
    /// These multipliers bring each face up to roughly match SF Arabic.
    var sizeBoost: CGFloat {
        switch self {
        case .mishafi:       return 2.00
        case .mishafiGold:   return 2.00
        case .diwanThuluth:  return 2.20
        case .diwanKufi:     return 1.80
        case .farisi:        return 2.00
        case .decoTypeNaskh: return 1.60
        case .alBayan:       return 1.55
        case .beirut:        return 1.50
        case .baghdad:       return 1.50
        case .damascus:      return 1.35
        case .geezaPro:      return 1.30
        case .nadeem:        return 1.30
        case .system:        return 1.00
        }
    }

    func font(size: CGFloat, userScale: CGFloat = 1.0, weight: Font.Weight = .bold) -> Font {
        let adjusted = size * sizeBoost * userScale
        if self == .system {
            return .system(size: adjusted, weight: weight)
        }
        return Font.custom(familyName, size: adjusted).weight(weight)
    }
}

// MARK: - Theme

enum NextPrayerTheme: String, CaseIterable {
    case emerald = "Emerald"
    case midnight = "Midnight"
    case roseGold = "Rose Gold"
    case sapphire = "Sapphire"
    case sand = "Desert Sand"

    static func from(_ name: String) -> NextPrayerTheme {
        NextPrayerTheme(rawValue: name) ?? .emerald
    }

    /// Primary accent for countdown text, progress arcs, icons.
    var primary: Color {
        switch self {
        case .emerald:  return Color(red: 0.18, green: 0.78, blue: 0.55)
        case .midnight: return Color(red: 0.42, green: 0.68, blue: 1.00)
        case .roseGold: return Color(red: 1.00, green: 0.67, blue: 0.62)
        case .sapphire: return Color(red: 0.31, green: 0.55, blue: 0.96)
        case .sand:     return Color(red: 0.93, green: 0.78, blue: 0.48)
        }
    }

    /// Secondary accent (the trailing color of the gradient).
    var secondary: Color {
        switch self {
        case .emerald:  return Color(red: 0.98, green: 0.85, blue: 0.44) // warm gold
        case .midnight: return Color(red: 0.66, green: 0.48, blue: 0.92) // iris
        case .roseGold: return Color(red: 0.98, green: 0.85, blue: 0.44)
        case .sapphire: return Color(red: 0.54, green: 0.82, blue: 1.00)
        case .sand:     return Color(red: 0.82, green: 0.54, blue: 0.30) // bronze
        }
    }

    /// Gradient used across text, icons, and the progress arc.
    var gradient: LinearGradient {
        LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Subtle wash used behind the widget content.
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                primary.opacity(0.18),
                Color.black.opacity(0.15),
                secondary.opacity(0.12),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Stronger wash used on the hover panel.
    var panelGradient: LinearGradient {
        LinearGradient(
            colors: [
                primary.opacity(0.22),
                Color.clear,
                secondary.opacity(0.14),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Shared chrome building blocks

struct LuxuryGlassBackground: View {
    var cornerRadius: CGFloat = 12
    var theme: NextPrayerTheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(theme.backgroundGradient)

            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.05),
                            Color.clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        }
    }
}

struct LuxuryInnerCard: View {
    var cornerRadius: CGFloat = 10
    var theme: NextPrayerTheme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.primary.opacity(0.05))
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [theme.primary.opacity(0.08), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.22), Color.white.opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        }
    }
}

struct LuxuryDivider: View {
    var vertical: Bool = false
    var length: CGFloat? = nil

    var body: some View {
        if vertical {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.02), Color.white.opacity(0.18), Color.white.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 0.5, height: length)
        } else {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.02), Color.white.opacity(0.18), Color.white.opacity(0.02)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
    }
}

struct LuxuryPulseDot: View {
    let color: Color
    @State private var pulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: 10, height: 10)
                .scaleEffect(pulsing ? 2.0 : 1.0)
                .opacity(pulsing ? 0 : 0.7)
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color.opacity(0.8), radius: 4)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                pulsing = true
            }
        }
    }
}
