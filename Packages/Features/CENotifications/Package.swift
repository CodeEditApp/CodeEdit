// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CENotifications",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CENotifications", targets: ["CENotifications"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditUI")
    ],
    targets: [
        .target(
            name: "CENotifications",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditUI", package: "CodeEditUI")
            ]
        )
    ]
)
