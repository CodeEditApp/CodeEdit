// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditUI",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditUI", targets: ["CodeEditUI"])
    ],
    dependencies: [
        // Pin matches the app's Package.resolved to avoid a second resolved copy.
        .package(url: "https://github.com/CodeEditApp/CodeEditSymbols.git", exact: "0.2.3")
    ],
    targets: [
        .target(
            name: "CodeEditUI",
            dependencies: [.product(name: "CodeEditSymbols", package: "CodeEditSymbols")]
        )
    ]
)
