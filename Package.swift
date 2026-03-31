// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DockDoorWidgetSDK",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "DockDoorWidgetSDK", targets: ["DockDoorWidgetSDK"]),
    ],
    targets: [
        .target(name: "DockDoorWidgetSDK"),
    ]
)
