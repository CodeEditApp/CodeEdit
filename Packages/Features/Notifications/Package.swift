// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Notifications",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Notifications", targets: ["Notifications"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditUI")
    ],
    targets: [
        .target(
            name: "Notifications",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditUI", package: "CodeEditUI")
            ]
        )
    ]
)
