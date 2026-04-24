import DockDoorWidgetSDK
import SwiftUI

struct NextPrayerView: View {
    let size: CGSize
    let isVertical: Bool
    let widgetId: String
    var service: PrayerTimesService

    // MARK: - Settings

    private var city: String { WidgetDefaults.string(key: "city", widgetId: widgetId, default: "Riyadh") }
    private var country: String { WidgetDefaults.string(key: "country", widgetId: widgetId, default: "Saudi Arabia") }
    private var method: PrayerMethod {
        PrayerMethod.from(WidgetDefaults.string(key: "method", widgetId: widgetId, default: PrayerMethod.ummAlQura.rawValue))
    }
    private var theme: NextPrayerTheme {
        NextPrayerTheme.from(WidgetDefaults.string(key: "theme", widgetId: widgetId, default: NextPrayerTheme.emerald.rawValue))
    }
    private var arabicFont: ArabicFont {
        ArabicFont.from(WidgetDefaults.string(key: "arabicFont", widgetId: widgetId, default: ArabicFont.mishafi.rawValue))
    }
    private var arabicFontScale: CGFloat {
        CGFloat(WidgetDefaults.double(key: "arabicFontScale", widgetId: widgetId, default: 1.0))
    }
    private var use24Hour: Bool { WidgetDefaults.bool(key: "use24Hour", widgetId: widgetId, default: false) }

    // MARK: - Layout helpers

    private var dim: CGFloat { min(size.width, size.height) }

    private var isExtended: Bool {
        isVertical
            ? size.height > size.width * 1.5
            : size.width > size.height * 1.5
    }

    // MARK: - Body

    var body: some View {
        // Vertical extended shows seconds → 1s tick; all horizontal layouts
        // show h:mm only so 30s is sufficient.
        TimelineView(.periodic(from: .now, by: (isExtended && isVertical) ? 1.0 : 30.0)) { context in
            let now = context.date
            let next = service.nextPrayer(from: now)
            let progress = service.progress(from: now)

            ZStack {
                LuxuryGlassBackground(cornerRadius: dim * 0.14, theme: theme)

                if isExtended {
                    extendedLayout(next: next, progress: progress, now: now)
                        .padding(dim * 0.08)
                } else {
                    // Compact handles its own (tighter) padding so the hero
                    // Arabic glyph can claim nearly the full widget width.
                    compactLayout(next: next, progress: progress, now: now)
                }
            }
            .shadow(color: theme.primary.opacity(0.22), radius: dim * 0.12, y: dim * 0.04)
        }
        .onAppear { refreshIfNeeded() }
    }

    // MARK: - Compact

    /// Compact dock layout: horizontal pill — [Arabic name] | [h:mm remaining].
    ///
    /// Using a horizontal arrangement instead of a vertical stack means the
    /// Arabic name can occupy the full widget height (= dim for a horizontal
    /// dock widget) rather than a fraction of it, making calligraphic faces
    /// like Mishafi render at a usable size. Progress ring and seconds are
    /// omitted to keep the layout uncluttered.
    private func compactLayout(next: Prayer?, progress: Double, now: Date) -> some View {
        HStack(spacing: 0) {
            Text(next?.arabicName ?? "\u{2014}")
                .font(arabicFont.font(size: dim * 0.72, userScale: arabicFontScale))
                .foregroundStyle(theme.gradient)
                .shadow(color: theme.primary.opacity(0.5), radius: dim * 0.025)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .layoutPriority(1)

            Rectangle()
                .fill(Color.primary.opacity(0.25))
                .frame(width: 0.5)
                .padding(.vertical, dim * 0.18)
                .padding(.horizontal, dim * 0.12)

            Text(countdownHM(to: next?.time, now: now))
                .font(.system(size: dim * 0.30, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .layoutPriority(2)
        }
        .padding(.horizontal, dim * 0.12)
        .padding(.vertical, dim * 0.08)
    }

    // MARK: - Extended

    private func extendedLayout(next: Prayer?, progress: Double, now: Date) -> some View {
        Group {
            if isVertical {
                extendedVertical(next: next, progress: progress, now: now)
            } else {
                extendedHorizontal(next: next, progress: progress, now: now)
            }
        }
    }

    private func extendedVertical(next: Prayer?, progress: Double, now: Date) -> some View {
        VStack(spacing: dim * 0.08) {
            Text(next?.arabicName ?? "\u{2014}")
                .font(arabicFont.font(size: dim * 0.55, userScale: arabicFontScale))
                .foregroundStyle(theme.gradient)
                .shadow(color: theme.primary.opacity(0.45), radius: dim * 0.04)
                .lineLimit(1)
                .minimumScaleFactor(0.05)
                .frame(maxWidth: .infinity, maxHeight: dim * 0.85)
                .layoutPriority(1)

            Text(countdownLong(to: next?.time, now: now))
                .font(.system(size: dim * 0.30, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxHeight: dim * 0.32)
                .layoutPriority(2)

            progressBar(progress: progress, thickness: dim * 0.05)
                .padding(.horizontal, dim * 0.06)
                .layoutPriority(3)
        }
    }

    /// Horizontal dock layout: wide widget gets a side-by-side pill.
    /// Arabic name claims the left portion at full widget height so
    /// calligraphic faces like Mishafi render large and readable.
    /// Seconds and the progress bar are omitted for clarity.
    private func extendedHorizontal(next: Prayer?, progress: Double, now: Date) -> some View {
        HStack(spacing: 0) {
            Text(next?.arabicName ?? "\u{2014}")
                .font(arabicFont.font(size: dim * 0.72, userScale: arabicFontScale))
                .foregroundStyle(theme.gradient)
                .shadow(color: theme.primary.opacity(0.5), radius: dim * 0.025)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .layoutPriority(1)

            Rectangle()
                .fill(Color.primary.opacity(0.25))
                .frame(width: 0.5)
                .padding(.vertical, dim * 0.18)
                .padding(.horizontal, dim * 0.12)

            Text(countdownHM(to: next?.time, now: now))
                .font(.system(size: dim * 0.30, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .layoutPriority(2)
        }
        .padding(.horizontal, dim * 0.12)
        .padding(.vertical, dim * 0.08)
    }

    // MARK: - Progress bar (extended layouts)

    private func progressBar(progress: Double, thickness: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.primary.opacity(0.12))

                Capsule()
                    .fill(theme.gradient)
                    .frame(width: max(thickness, geo.size.width * progress))
                    .shadow(color: theme.primary.opacity(0.6), radius: 3)
            }
        }
        .frame(height: thickness)
    }

    // MARK: - Progress ring

    private func progressRing(diameter: CGFloat, lineWidth: CGFloat, progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.001, progress))
                .stroke(
                    AngularGradient(
                        colors: [theme.primary, theme.secondary, theme.primary],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: theme.primary.opacity(0.5), radius: lineWidth * 0.6)
        }
        .frame(width: diameter, height: diameter)
    }

    // MARK: - Formatting

    private func countdownShort(to target: Date?, now: Date) -> String {
        guard let target else { return "\u{2014}" }
        let diff = max(0, target.timeIntervalSince(now))
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        if h >= 1 { return "\(h)h \(m)m" }
        let s = Int(diff) % 60
        if m >= 1 { return "\(m)m" }
        return "\(s)s"
    }

    /// Hours and minutes only — used in the compact dock layout where
    /// showing seconds would cause the text to update every second and
    /// add visual noise without meaningful information at a glance.
    private func countdownHM(to target: Date?, now: Date) -> String {
        guard let target else { return "--:--" }
        let diff = max(0, target.timeIntervalSince(now))
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        if h > 0 { return String(format: "%d:%02d", h, m) }
        return String(format: "%dm", m)
    }

    private func countdownLong(to target: Date?, now: Date) -> String {
        guard let target else { return "--:--:--" }
        let diff = max(0, target.timeIntervalSince(now))
        let h = Int(diff) / 3600
        let m = (Int(diff) % 3600) / 60
        let s = Int(diff) % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = use24Hour ? "HH:mm" : "h:mm a"
        return fmt.string(from: date)
    }

    // MARK: - Refresh

    private func refreshIfNeeded() {
        service.refresh(city: city, country: country, method: method)
    }
}
