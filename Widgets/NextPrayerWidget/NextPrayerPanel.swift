import DockDoorWidgetSDK
import SwiftUI

// MARK: - Tab model

private enum PanelTab: String, CaseIterable {
    case prayers = "Prayers"
    case dhikr   = "Dhikr"
    case tasbih  = "Tasbih"

    var icon: String {
        switch self {
        case .prayers: return "clock.fill"
        case .dhikr:   return "text.book.closed.fill"
        case .tasbih:  return "circle.dotted"
        }
    }
}

// MARK: - Panel

struct NextPrayerPanel: View {
    let widgetId: String
    var service: PrayerTimesService
    let dismiss: () -> Void

    @State private var appeared = false
    @State private var selectedTab: PanelTab = .prayers
    @State private var dhikr: Dhikr = AthkarData.pick()
    @State private var tasbihCounts: [Int] = [0, 0, 0]

    private let tasbihItems: [(arabic: String, en: String, target: Int, color: (Double, Double, Double))] = [
        ("سُبْحَانَ اللَّهِ", "SubhanAllah",   33, (0.18, 0.78, 0.55)),
        ("اَلْحَمْدُ لِلَّهِ", "Alhamdulillah", 33, (0.42, 0.68, 1.00)),
        ("اَللَّهُ أَكْبَرُ",  "AllahuAkbar",  34, (0.93, 0.78, 0.48)),
    ]

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
    private var showHijri: Bool { WidgetDefaults.bool(key: "showHijri", widgetId: widgetId, default: true) }
    private var showArabic: Bool { WidgetDefaults.bool(key: "showArabicNames", widgetId: widgetId, default: true) }

    // MARK: - Body

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            content(now: context.date)
        }
        .onAppear {
            service.refresh(city: city, country: country, method: method)
            dhikr = AthkarData.pick()
            tasbihCounts = [0, 0, 0]
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private func content(now: Date) -> some View {
        VStack(spacing: 0) {
            header(now: now)
            LuxuryDivider()
            tabBar()
            LuxuryDivider()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    tabContent(now: now)
                }
                .padding(14)
                .id(selectedTab)
            }
        }
        .frame(width: 320, height: 500)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 14)
                    .fill(theme.panelGradient)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
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
        )
        .shadow(color: theme.primary.opacity(0.18), radius: 24, y: 8)
        .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.96)
        .animation(.easeInOut(duration: 0.18), value: selectedTab)
    }

    // MARK: - Tab bar

    private func tabBar() -> some View {
        HStack(spacing: 4) {
            ForEach(PanelTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 11,
                                          weight: selectedTab == tab ? .semibold : .regular))
                        Text(tab.rawValue)
                            .font(.system(size: 11,
                                          weight: selectedTab == tab ? .semibold : .regular))
                    }
                    .foregroundStyle(
                        selectedTab == tab
                            ? AnyShapeStyle(theme.gradient)
                            : AnyShapeStyle(Color.secondary.opacity(0.65))
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        Group {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(theme.primary.opacity(0.14))
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [theme.primary.opacity(0.07), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Tab content router

    @ViewBuilder
    private func tabContent(now: Date) -> some View {
        switch selectedTab {
        case .prayers:
            heroSection(now: now)
            prayersSection(now: now)
            footerSection()
        case .dhikr:
            athkarSection()
        case .tasbih:
            tasbihSection()
        }
    }

    // MARK: - Header

    private func header(now: Date) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.gradient)
                .shadow(color: theme.primary.opacity(0.7), radius: 6)

            VStack(alignment: .leading, spacing: 1) {
                Text("Prayer Times")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(city.isEmpty ? "\u{2014}" : "\(city), \(country)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            LuxuryPulseDot(color: theme.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    theme.primary.opacity(0.12),
                    Color.clear,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Hero (countdown to next prayer)

    private func heroSection(now: Date) -> some View {
        let next = service.nextPrayer(from: now)
        let progress = service.progress(from: now)

        return VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Coming Up")

            ZStack {
                LuxuryInnerCard(cornerRadius: 12, theme: theme)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(Color.primary.opacity(0.12), lineWidth: 6)
                            .frame(width: 58, height: 58)
                        Circle()
                            .trim(from: 0, to: max(0.001, progress))
                            .stroke(
                                AngularGradient(
                                    colors: [theme.primary, theme.secondary, theme.primary],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 58, height: 58)
                            .shadow(color: theme.primary.opacity(0.6), radius: 4)
                        Image(systemName: next?.icon ?? "moon.stars.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(theme.gradient)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(next?.name ?? "\u{2014}")
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundStyle(theme.gradient)
                            if showArabic, let arabic = next?.arabicName {
                                Text(arabic)
                                    .font(arabicFont.font(size: 16, userScale: arabicFontScale, weight: .medium))
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Text(countdownLong(to: next?.time, now: now))
                            .font(.system(size: 26, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.primary)

                        if let next {
                            Text("at \(formatTime(next.time))")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        } else if service.isLoading {
                            Text("Loading…")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.tertiary)
                        } else if let err = service.errorMessage {
                            Text(err)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.orange)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(12)
            }
        }
    }

    // MARK: - Prayers list

    private func prayersSection(now: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Today")

            let prayers = service.day?.prayers ?? []
            let next = service.nextPrayer(from: now)

            if prayers.isEmpty {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.secondary)
                    Text(service.isLoading ? "Loading prayer times…" : (service.errorMessage ?? "No data yet"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(12)
                .background(LuxuryInnerCard(cornerRadius: 10, theme: theme))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                        prayerRow(prayer, isNext: prayer.id == next?.id, now: now)
                        if index < prayers.count - 1 {
                            LuxuryDivider().padding(.leading, 44)
                        }
                    }
                }
                .background(LuxuryInnerCard(cornerRadius: 12, theme: theme))
            }
        }
    }

    private func prayerRow(_ prayer: Prayer, isNext: Bool, now: Date) -> some View {
        let isPast = prayer.time < now
        let tint: Color = isNext ? theme.primary : (isPast ? Color.secondary : Color.primary.opacity(0.85))

        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isNext ? theme.primary.opacity(0.22) : Color.primary.opacity(0.06))
                    .frame(width: 28, height: 28)
                Image(systemName: prayer.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isNext ? AnyShapeStyle(theme.gradient) : AnyShapeStyle(tint))
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(prayer.name)
                        .font(.system(size: 13, weight: isNext ? .semibold : .medium))
                        .foregroundStyle(isNext ? AnyShapeStyle(theme.gradient) : AnyShapeStyle(.primary))
                    if showArabic {
                        Text(prayer.arabicName)
                            .font(arabicFont.font(size: 13, userScale: arabicFontScale, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                if isPast {
                    Text("passed")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.tertiary)
                } else {
                    Text("in \(countdownShort(to: prayer.time, now: now))")
                        .font(.system(size: 10, weight: isNext ? .semibold : .medium, design: .monospaced))
                        .foregroundStyle(isNext ? AnyShapeStyle(theme.primary) : AnyShapeStyle(Color.secondary))
                }
            }

            Spacer()

            Text(formatTime(prayer.time))
                .font(.system(size: 12, weight: isNext ? .semibold : .medium, design: .monospaced).monospacedDigit())
                .foregroundStyle(isPast && !isNext ? AnyShapeStyle(.tertiary) : AnyShapeStyle(.primary))
                .strikethrough(isPast && !isNext, color: Color.secondary.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            isNext
                ? RoundedRectangle(cornerRadius: 8)
                    .fill(theme.primary.opacity(0.08))
                    .padding(.horizontal, 4)
                : nil
        )
    }

    // MARK: - Athkar

    private func athkarSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionLabel("Dhikr")
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        dhikr = AthkarData.pick()
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 9, weight: .semibold))
                        Text("New")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(theme.primary)
                }
                .buttonStyle(.plain)
            }

            ZStack {
                LuxuryInnerCard(cornerRadius: 12, theme: theme)

                VStack(alignment: .leading, spacing: 10) {
                    // Category badge
                    HStack(spacing: 5) {
                        Image(systemName: dhikr.category.icon)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(theme.secondary)
                        Text(dhikr.category.rawValue.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .kerning(0.8)
                            .foregroundStyle(theme.secondary)
                        Spacer()
                        if dhikr.repetitions > 1 {
                            Text("×\(dhikr.repetitions)")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(theme.primary.opacity(0.15))
                                )
                                .foregroundStyle(theme.primary)
                        }
                    }

                    // Arabic text — right-aligned, using the chosen calligraphic font
                    Text(dhikr.arabic)
                        .font(arabicFont.font(size: 15, userScale: arabicFontScale, weight: .medium))
                        .foregroundStyle(theme.gradient)
                        .multilineTextAlignment(.trailing)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    LuxuryDivider()

                    // Transliteration
                    Text(dhikr.transliteration)
                        .font(.system(size: 10, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)

                    // English meaning
                    Text(dhikr.meaning)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.tertiary)
                        .lineSpacing(2)
                }
                .padding(12)
            }
        }
    }

    // MARK: - Tasbih

    private func tasbihSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionLabel("Tasbih")
                Spacer()
                if tasbihCounts.contains(where: { $0 > 0 }) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            tasbihCounts = [0, 0, 0]
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 9, weight: .semibold))
                            Text("Reset")
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 6) {
                ForEach(tasbihItems.indices, id: \.self) { i in
                    tasbihCard(index: i)
                }
            }

            // Overall progress bar
            let total = tasbihCounts.reduce(0, +)
            let totalTarget = tasbihItems.reduce(0) { $0 + $1.target }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.08))
                    Capsule()
                        .fill(theme.gradient)
                        .frame(width: max(4, geo.size.width * CGFloat(total) / CGFloat(totalTarget)))
                        .animation(.spring(response: 0.3), value: total)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 2)
        }
    }

    private func tasbihCard(index: Int) -> some View {
        let item = tasbihItems[index]
        let count = tasbihCounts[index]
        let progress = min(1.0, Double(count) / Double(item.target))
        let done = count >= item.target
        let accent = Color(red: item.color.0, green: item.color.1, blue: item.color.2)

        return Button {
            guard tasbihCounts[index] < item.target else { return }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                tasbihCounts[index] += 1
            }
        } label: {
            ZStack {
                LuxuryInnerCard(cornerRadius: 10, theme: theme)
                    .overlay(
                        done
                            ? RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(accent.opacity(0.45), lineWidth: 1)
                            : nil
                    )

                VStack(spacing: 7) {
                    ZStack {
                        Circle()
                            .stroke(Color.primary.opacity(0.10), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                done
                                    ? AnyShapeStyle(accent)
                                    : AnyShapeStyle(theme.gradient),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.3), value: progress)

                        if done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(accent)
                        } else {
                            Text("\(count)")
                                .font(.system(size: 13, weight: .bold, design: .rounded).monospacedDigit())
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                        }
                    }
                    .frame(width: 38, height: 38)

                    Text(item.arabic)
                        .font(arabicFont.font(size: 8, userScale: arabicFontScale, weight: .regular))
                        .foregroundStyle(done ? AnyShapeStyle(accent) : AnyShapeStyle(Color.secondary))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)

                    Text("×\(item.target)")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer

    private func footerSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if showHijri, let hijriEn = service.day?.hijriDate, !hijriEn.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    datePill(
                        icon: "moon.stars.fill",
                        arabicText: arabicHijriDate(),
                        englishText: hijriEn,
                        iconColor: theme.primary
                    )
                    Rectangle()
                        .fill(Color.primary.opacity(0.12))
                        .frame(width: 0.5)
                        .padding(.vertical, 2)
                    datePill(
                        icon: "calendar",
                        arabicText: arabicGregorianDate(),
                        englishText: service.day?.gregorianDate ?? "",
                        iconColor: theme.secondary
                    )
                }
                .padding(10)
                .background(LuxuryInnerCard(cornerRadius: 10, theme: theme))
            }

            HStack(spacing: 6) {
                Image(systemName: "function")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(theme.secondary)
                Text("Method: \(method.rawValue)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    service.refresh(city: city, country: country, method: method, force: true)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10, weight: .semibold))
                        Text("Refresh")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(theme.primary.opacity(0.18))
                    )
                    .foregroundStyle(theme.gradient)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 2)
    }

    // MARK: - Date helpers

    /// Hijri date in Arabic script using the Islamic Umm al-Qura calendar.
    private func arabicHijriDate() -> String {
        let fmt = DateFormatter()
        fmt.calendar = Calendar(identifier: .islamicUmmAlQura)
        fmt.locale = Locale(identifier: "ar_SA")
        fmt.dateStyle = .long
        fmt.timeStyle = .none
        return fmt.string(from: Date())
    }

    /// Gregorian date formatted in Arabic script.
    /// Calendar must be explicitly set to .gregorian because ar_SA locale
    /// defaults to the Islamic Umm al-Qura calendar.
    private func arabicGregorianDate() -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ar_SA")
        fmt.calendar = Calendar(identifier: .gregorian)
        fmt.dateFormat = "d MMMM yyyy"
        return fmt.string(from: Date())
    }

    @ViewBuilder
    private func datePill(icon: String, arabicText: String, englishText: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(iconColor)
                Text(arabicText)
                    .font(arabicFont.font(size: 11, userScale: arabicFontScale, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(englishText)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .kerning(1.2)
            .foregroundStyle(.secondary)
    }

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
}
