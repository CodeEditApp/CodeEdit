// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CELSP",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CELSP", targets: ["CELSP"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditDocument"),
        .package(path: "../../Foundation/CodeEditSettings"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSourceEditor", exact: "0.15.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditTextView.git", exact: "0.12.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditLanguages.git", exact: "0.1.20"),
        .package(url: "https://github.com/ChimeHQ/LanguageClient", exact: "0.8.2"),
        .package(url: "https://github.com/ChimeHQ/LanguageServerProtocol", exact: "0.14.0"),
        .package(url: "https://github.com/ChimeHQ/JSONRPC", exact: "0.9.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: "0.9.19"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", exact: "1.0.1")
    ],
    targets: [
        .target(
            name: "CELSP",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditDocument", package: "CodeEditDocument"),
                .product(name: "CodeEditSettings", package: "CodeEditSettings"),
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "CodeEditTextView", package: "CodeEditTextView"),
                .product(name: "CodeEditLanguages", package: "CodeEditLanguages"),
                .product(name: "LanguageClient", package: "LanguageClient"),
                .product(name: "LanguageServerProtocol", package: "LanguageServerProtocol"),
                .product(name: "JSONRPC", package: "JSONRPC"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .testTarget(
            name: "CELSPTests",
            dependencies: [
                "CELSP",
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "LanguageServerProtocol", package: "LanguageServerProtocol")
            ]
        )
    ]
)
