// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditSettings",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditSettings", targets: ["CodeEditSettings"])
    ],
    dependencies: [
        // Pins match the app's Package.resolved to avoid a second resolved copy.
        .package(path: "../CodeEditCore")
    ],
    targets: [
        .target(
            name: "CodeEditSettings",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore")
            ]
        )
    ]
)
