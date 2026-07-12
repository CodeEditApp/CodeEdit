// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CESourceControl",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CESourceControl", targets: ["CESourceControl"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditSettings"),
        .package(path: "../../Foundation/CodeEditUI"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSymbols.git", exact: "0.2.3")
    ],
    targets: [
        .target(
            name: "CESourceControl",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditSettings", package: "CodeEditSettings"),
                .product(name: "CodeEditUI", package: "CodeEditUI"),
                .product(name: "CodeEditSymbols", package: "CodeEditSymbols")
            ]
        )
    ]
)
