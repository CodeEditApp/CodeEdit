// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditCore", targets: ["CodeEditCore"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CodeEditCore",
            dependencies: []
        ),
        .testTarget(
            name: "CodeEditCoreTests",
            dependencies: ["CodeEditCore"]
        )
    ]
)
