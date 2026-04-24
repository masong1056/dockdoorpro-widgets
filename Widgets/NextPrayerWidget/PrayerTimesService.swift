import DockDoorWidgetSDK
import Foundation
import Observation

enum PrayerMethod: String, CaseIterable {
    case ummAlQura = "Umm al-Qura"
    case muslimWorldLeague = "Muslim World League"
    case egyptian = "Egyptian"
    case isna = "ISNA"
    case karachi = "Karachi"
    case tehran = "Tehran"
    case dubai = "Dubai"
    case kuwait = "Kuwait"
    case qatar = "Qatar"
    case singapore = "Singapore"
    case turkey = "Turkey"

    var apiValue: Int {
        switch self {
        case .karachi: return 1
        case .isna: return 2
        case .muslimWorldLeague: return 3
        case .ummAlQura: return 4
        case .egyptian: return 5
        case .tehran: return 7
        case .dubai: return 8
        case .kuwait: return 9
        case .qatar: return 10
        case .singapore: return 11
        case .turkey: return 13
        }
    }

    static func from(_ name: String) -> PrayerMethod {
        PrayerMethod(rawValue: name) ?? .ummAlQura
    }
}

struct Prayer: Identifiable, Hashable, Codable {
    let name: String
    let arabicName: String
    let icon: String
    let time: Date

    var id: String { name }
}

struct PrayerDay: Codable, Equatable {
    let prayers: [Prayer]
    let hijriDate: String
    let gregorianDate: String
    let city: String
    let country: String
    let methodRaw: String
    let fetchedAt: Date

    var method: PrayerMethod { PrayerMethod.from(methodRaw) }
}

@Observable
final class PrayerTimesService {
    var day: PrayerDay?
    var isLoading: Bool = false
    var errorMessage: String?

    private var lastRequestKey: String?

    init() {
        day = Self.loadCache()
    }

    // MARK: - Public API

    /// Refresh for the given location+method. No-op if cached data for today already matches.
    @MainActor
    func refresh(city: String, country: String, method: PrayerMethod, force: Bool = false) {
        let key = cacheKey(city: city, country: country, method: method, date: Date())
        if !force,
           let existing = day,
           Calendar.current.isDateInToday(existing.fetchedAt),
           existing.city == city,
           existing.country == country,
           existing.methodRaw == method.rawValue {
            return
        }
        guard lastRequestKey != key || force else { return }
        lastRequestKey = key

        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            do {
                let fetched = try await Self.fetch(city: city, country: country, method: method)
                await MainActor.run {
                    guard let self else { return }
                    self.day = fetched
                    self.isLoading = false
                    Self.saveCache(fetched)
                }
            } catch {
                await MainActor.run {
                    guard let self else { return }
                    self.isLoading = false
                    self.errorMessage = "Couldn\u{2019}t load prayer times"
                }
            }
        }
    }

    // MARK: - Derived values

    /// The upcoming prayer (or first prayer of tomorrow, if the day is done).
    func nextPrayer(from now: Date = Date()) -> Prayer? {
        guard let prayers = day?.prayers, !prayers.isEmpty else { return nil }
        if let upcoming = prayers.first(where: { $0.time > now }) {
            return upcoming
        }
        // After Isha: return Fajr shifted to tomorrow
        let fajr = prayers.first
        if let fajr, let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: fajr.time) {
            return Prayer(name: fajr.name, arabicName: fajr.arabicName, icon: fajr.icon, time: tomorrow)
        }
        return nil
    }

    /// The prayer that is currently in session (the most recent past prayer).
    func currentPrayer(from now: Date = Date()) -> Prayer? {
        guard let prayers = day?.prayers else { return nil }
        return prayers.last(where: { $0.time <= now })
    }

    /// Fraction (0…1) between the current prayer and the next. Useful for the ring.
    func progress(from now: Date = Date()) -> Double {
        guard let next = nextPrayer(from: now) else { return 0 }
        let start = currentPrayer(from: now)?.time
            ?? Calendar.current.date(byAdding: .hour, value: -6, to: next.time)
            ?? next.time.addingTimeInterval(-21_600)
        let total = next.time.timeIntervalSince(start)
        guard total > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(start)
        return max(0, min(1, elapsed / total))
    }

    // MARK: - Networking

    private static func fetch(city: String, country: String, method: PrayerMethod) async throws -> PrayerDay {
        var components = URLComponents(string: "https://api.aladhan.com/v1/timingsByCity")!
        components.queryItems = [
            URLQueryItem(name: "city", value: city),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "method", value: "\(method.apiValue)"),
        ]
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(AladhanResponse.self, from: data)

        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let timings = decoded.data.timings

        // Full Arabic names with tashkeel (diacritical marks):
        // Fajr    \u{2192} \u{0627}\u{0644}\u{0652}\u{0641}\u{064E}\u{062C}\u{0652}\u{0631}
        // Sunrise \u{2192} \u{0627}\u{0644}\u{0634}\u{0651}\u{064F}\u{0631}\u{064F}\u{0648}\u{0642}
        // Dhuhr   \u{2192} \u{0627}\u{0644}\u{0638}\u{0651}\u{064F}\u{0647}\u{0652}\u{0631}
        // Asr     \u{2192} \u{0627}\u{0644}\u{0652}\u{0639}\u{064E}\u{0635}\u{0652}\u{0631}
        // Maghrib \u{2192} \u{0627}\u{0644}\u{0652}\u{0645}\u{064E}\u{063A}\u{0652}\u{0631}\u{0650}\u{0628}
        // Isha    \u{2192} \u{0627}\u{0644}\u{0652}\u{0639}\u{0650}\u{0634}\u{064E}\u{0627}\u{0621}
        let targets: [(name: String, arabic: String, icon: String)] = [
            ("Fajr",    "\u{0627}\u{0644}\u{0652}\u{0641}\u{064E}\u{062C}\u{0652}\u{0631}",                             "moon.stars.fill"),
            ("Sunrise", "\u{0627}\u{0644}\u{0634}\u{0651}\u{064F}\u{0631}\u{064F}\u{0648}\u{0642}",                     "sunrise.fill"),
            ("Dhuhr",   "\u{0627}\u{0644}\u{0638}\u{0651}\u{064F}\u{0647}\u{0652}\u{0631}",                             "sun.max.fill"),
            ("Asr",     "\u{0627}\u{0644}\u{0652}\u{0639}\u{064E}\u{0635}\u{0652}\u{0631}",                             "sun.min.fill"),
            ("Maghrib", "\u{0627}\u{0644}\u{0652}\u{0645}\u{064E}\u{063A}\u{0652}\u{0631}\u{0650}\u{0628}",             "sunset.fill"),
            ("Isha",    "\u{0627}\u{0644}\u{0652}\u{0639}\u{0650}\u{0634}\u{064E}\u{0627}\u{0621}",                     "moon.fill"),
        ]

        let prayers: [Prayer] = targets.compactMap { entry in
            guard let timeString = timings[entry.name] else { return nil }
            let trimmed = timeString.split(separator: " ").first.map(String.init) ?? timeString
            let parts = trimmed.split(separator: ":")
            guard parts.count >= 2,
                  let hour = Int(parts[0]),
                  let minute = Int(parts[1]),
                  let date = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)
            else { return nil }
            return Prayer(
                name: entry.name,
                arabicName: entry.arabic,
                icon: entry.icon,
                time: date
            )
        }

        let hijri = decoded.data.date.hijri
        let hijriString = "\(hijri.day) \(hijri.month.en) \(hijri.year) AH"
        let gregString = decoded.data.date.readable

        return PrayerDay(
            prayers: prayers,
            hijriDate: hijriString,
            gregorianDate: gregString,
            city: city,
            country: country,
            methodRaw: method.rawValue,
            fetchedAt: Date()
        )
    }

    // MARK: - Cache

    private static let cacheKeyName = "widget.next-prayer.cachedDay.v2"

    private static func loadCache() -> PrayerDay? {
        guard let data = UserDefaults.standard.data(forKey: cacheKeyName) else { return nil }
        guard let decoded = try? JSONDecoder().decode(PrayerDay.self, from: data) else { return nil }
        // Cached prayers are only useful for today (they\u{2019}re calendar-aligned).
        if Calendar.current.isDateInToday(decoded.fetchedAt) { return decoded }
        return nil
    }

    private static func saveCache(_ day: PrayerDay) {
        guard let data = try? JSONEncoder().encode(day) else { return }
        UserDefaults.standard.set(data, forKey: cacheKeyName)
    }

    private func cacheKey(city: String, country: String, method: PrayerMethod, date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return "\(city)|\(country)|\(method.rawValue)|\(fmt.string(from: date))"
    }
}

// MARK: - API response shapes

private struct AladhanResponse: Codable {
    let data: AladhanData
}

private struct AladhanData: Codable {
    let timings: [String: String]
    let date: AladhanDate
}

private struct AladhanDate: Codable {
    let readable: String
    let hijri: AladhanHijri
}

private struct AladhanHijri: Codable {
    let day: String
    let year: String
    let month: AladhanHijriMonth
}

private struct AladhanHijriMonth: Codable {
    let en: String
}
