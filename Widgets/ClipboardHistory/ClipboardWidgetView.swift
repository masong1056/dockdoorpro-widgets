import DockDoorWidgetSDK
import SwiftUI

struct ClipboardWidgetView: View {
    let size: CGSize
    let isVertical: Bool
    var manager: ClipboardManagerState

    private var dim: CGFloat { min(size.width, size.height) }

    private var isExtended: Bool {
        isVertical
            ? size.height > size.width * 1.5
            : size.width > size.height * 1.5
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            let _ = manager.refresh()
            Group {
                if isExtended {
                    extendedLayout
                } else {
                    compactLayout
                }
            }
            .padding(8)
        }
        .onAppear { manager.loadCurrentClipboard() }
    }


    private var compactLayout: some View {
        ZStack {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: dim * WidgetMetrics.sfSymbolScale)
                .foregroundStyle(.secondary)
        }
    }


    private var extendedLayout: some View {
        Group {
            if isVertical {
                VStack(spacing: dim * WidgetMetrics.spacingScale) {
                    icon
                    snippetView
                }
            } else {
                HStack(spacing: dim * 0.1) {
                    icon
                    snippetView
                }
            }
        }
    }

    private var icon: some View {
        Image(systemName: "list.bullet.clipboard")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: dim * WidgetMetrics.sfSymbolScale)
            .foregroundStyle(.secondary)
    }

    private var snippetView: some View {
        Group {
            if let latest = manager.unpinnedItems.first ?? manager.clipboardItems.first {
                switch latest.data {
                case .image:
                    Image(systemName: "photo")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                case let .text(text):
                    Text(text.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                default:
                    Text(latest.displayText)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            } else {
                Image(systemName: "clipboard")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
