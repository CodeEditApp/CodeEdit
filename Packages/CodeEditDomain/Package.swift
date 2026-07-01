// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditDomain",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditDomain", targets: ["CodeEditDomain"])
    ],
    targets: [
        .target(name: "CodeEditDomain")
    ]
)
