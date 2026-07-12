// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CEEditor",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CEEditor", targets: ["CEEditor"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore"),
        .package(path: "../../Foundation/CodeEditUI"),
        .package(path: "../../Foundation/CodeEditDocument"),
        .package(path: "../../Foundation/CodeEditSettings"),
        .package(path: "../../Services/CodeEditServices"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSourceEditor", exact: "0.15.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditTextView.git", exact: "0.12.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditLanguages.git", exact: "0.1.20"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSymbols.git", exact: "0.2.3"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "CEEditor",
            dependencies: [
                .product(name: "CodeEditCore", package: "CodeEditCore"),
                .product(name: "CodeEditUI", package: "CodeEditUI"),
                .product(name: "CodeEditDocument", package: "CodeEditDocument"),
                .product(name: "CodeEditSettings", package: "CodeEditSettings"),
                .product(name: "CodeEditServices", package: "CodeEditServices"),
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "CodeEditTextView", package: "CodeEditTextView"),
                .product(name: "CodeEditLanguages", package: "CodeEditLanguages"),
                .product(name: "CodeEditSymbols", package: "CodeEditSymbols"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "DequeModule", package: "swift-collections")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
