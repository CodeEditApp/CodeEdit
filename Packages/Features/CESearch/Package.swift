// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CESearch",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CESearch", targets: ["CESearch"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditUI")
    ],
    targets: [
        .target(
            name: "CESearch",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditUI", package: "CodeEditUI")
            ]
        )
    ]
)
