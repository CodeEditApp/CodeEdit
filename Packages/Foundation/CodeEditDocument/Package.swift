// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditDocument",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditDocument", targets: ["CodeEditDocument"])
    ],
    dependencies: [
        // Pins match the app's Package.resolved to avoid a second resolved copy.
        .package(path: "../CodeEditCore"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSourceEditor", exact: "0.15.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditTextView.git", exact: "0.12.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditLanguages.git", exact: "0.1.20"),
        .package(url: "https://github.com/ChimeHQ/TextStory", exact: "0.9.1")
    ],
    targets: [
        .target(
            name: "CodeEditDocument",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "CodeEditTextView", package: "CodeEditTextView"),
                .product(name: "CodeEditLanguages", package: "CodeEditLanguages"),
                .product(name: "TextStory", package: "TextStory")
            ]
        )
    ]
)
