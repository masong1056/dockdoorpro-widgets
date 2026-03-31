# DockDoor Pro Widgets

This is where community-made widgets for [DockDoor Pro](https://pro.dockdoor.net) live. You write real Swift/SwiftUI code, open a PR, I review it, and on merge it shows up in the app's widget marketplace.

No JSON-to-UI nonsense. You write actual SwiftUI views that render natively in the dock.

## How it works

1. You write a widget (SwiftUI view + a small plugin class)
2. Open a PR to this repo
3. I review it for quality and safety
4. On merge, CI compiles it into a `.bundle` and publishes it to `widgets.dockdoor.net`
5. Users can install it directly from the marketplace inside DockDoor Pro
6. When a widget is updated, the app detects the change and prompts users to reinstall

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full walkthrough.

## SDK

The `DockDoorWidgetSDK` package gives you everything you need:

- `DockDoorWidgetProvider` - protocol your widget conforms to
- `WidgetPlugin` - base class for bundle loading
- `WidgetMetrics` - sizing constants so your widget looks native
- `WidgetSetting` - declare settings as data, the app renders them
- `WidgetDefaults` - read your settings values at runtime

## For DockDoor Pro users

Widgets from this repo show up in the marketplace tab inside the app. Just hit install.

## License

[BSL 1.1](LICENSE) - you can use this to build widgets for DockDoor Pro, but you can't use the SDK or tooling in your own products.
