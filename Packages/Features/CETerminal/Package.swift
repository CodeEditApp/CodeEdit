// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CETerminal",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CETerminal", targets: ["CETerminal"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditSettings"),
        .package(url: "https://github.com/thecoolwinter/SwiftTerm", branch: "codeedit")
    ],
    targets: [
        .target(
            name: "CETerminal",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditSettings", package: "CodeEditSettings"),
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ]
        )
    ]
)
