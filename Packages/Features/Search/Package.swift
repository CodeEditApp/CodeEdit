// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Search",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Search", targets: ["Search"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditUI"),
        .package(url: "https://github.com/hmlongco/Factory", exact: "2.5.3")
    ],
    targets: [
        .target(
            name: "Search",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditUI", package: "CodeEditUI"),
                .product(name: "Factory", package: "Factory")
            ]
        )
    ]
)
