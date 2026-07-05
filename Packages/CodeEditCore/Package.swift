// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditCore", targets: ["CodeEditCore"])
    ],
    dependencies: [
        // Pin matches the app's Package.resolved.
        .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3")
    ],
    targets: [
        .target(
            name: "CodeEditCore",
            dependencies: [.product(name: "Factory", package: "Factory")]
        )
    ]
)
