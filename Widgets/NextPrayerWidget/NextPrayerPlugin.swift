import DockDoorWidgetSDK
import SwiftUI

final class NextPrayerPlugin: WidgetPlugin, DockDoorWidgetProvider {
    var id: String { "next-prayer" }
    var name: String { "Next Prayer" }
    var iconSymbol: String { "moon.stars.fill" }
    var widgetDescription: String { "Countdown to the next prayer. Hover for all five daily times." }
    var supportedOrientations: [WidgetOrientation] { [.horizontal, .vertical] }

    private let service = PrayerTimesService()

    func settingsSchema() -> [WidgetSetting] {
        [
            .textField(
                key: "city",
                label: "City",
                placeholder: "e.g. Riyadh",
                defaultValue: "Riyadh"
            ),
            .textField(
                key: "country",
                label: "Country",
                placeholder: "e.g. Saudi Arabia",
                defaultValue: "Saudi Arabia"
            ),
            .picker(
                key: "method",
                label: "Calculation Method",
                options: PrayerMethod.allCases.map(\.rawValue),
                defaultValue: PrayerMethod.ummAlQura.rawValue
            ),
            .picker(
                key: "theme",
                label: "Theme",
                options: NextPrayerTheme.allCases.map(\.rawValue),
                defaultValue: NextPrayerTheme.emerald.rawValue
            ),
            .picker(
                key: "arabicFont",
                label: "Arabic Font",
                options: ArabicFont.allCases.map(\.rawValue),
                defaultValue: ArabicFont.mishafi.rawValue
            ),
            .slider(
                key: "arabicFontScale",
                label: "Arabic Font Size (\u{00D7})",
                range: 0.5...2.0,
                step: 0.05,
                defaultValue: 1.0
            ),
            .toggle(
                key: "use24Hour",
                label: "Use 24-hour Format",
                defaultValue: false
            ),
            .toggle(
                key: "showHijri",
                label: "Show Hijri Date in Panel",
                defaultValue: true
            ),
            .toggle(
                key: "showArabicNames",
                label: "Show Arabic Prayer Names",
                defaultValue: true
            ),
        ]
    }

    @MainActor
    func makeBody(size: CGSize, isVertical: Bool) -> AnyView {
        AnyView(NextPrayerView(
            size: size,
            isVertical: isVertical,
            widgetId: id,
            service: service
        ))
    }

    @MainActor
    func makePanelBody(dismiss: @escaping () -> Void) -> AnyView? {
        AnyView(NextPrayerPanel(
            widgetId: id,
            service: service,
            dismiss: dismiss
        ))
    }
}
