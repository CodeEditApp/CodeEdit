// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditModules",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "CodeEditCore", targets: ["CodeEditCore"]),
        .library(name: "CodeEditUI", targets: ["CodeEditUI"]),
        .library(name: "CodeEditDocument", targets: ["CodeEditDocument"]),
        .library(name: "CodeEditSettings", targets: ["CodeEditSettings"]),
        .library(name: "ShellClient", targets: ["ShellClient"]),
        .library(name: "CEWorkspaceFileManager", targets: ["CEWorkspaceFileManager"]),
        .library(name: "CEEditor", targets: ["CEEditor"]),
        .library(name: "CELSP", targets: ["CELSP"]),
        .library(name: "CENotifications", targets: ["CENotifications"]),
        .library(name: "CESearch", targets: ["CESearch"]),
        .library(name: "CESourceControl", targets: ["CESourceControl"]),
        .library(name: "CETerminal", targets: ["CETerminal"])
    ],
    dependencies: [
        // Pins match the app's Package.resolved to avoid a second resolved copy.
        .package(url: "https://github.com/CodeEditApp/CodeEditSymbols.git", exact: "0.2.3"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSourceEditor", exact: "0.15.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditTextView.git", exact: "0.12.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditLanguages.git", exact: "0.1.20"),
        .package(url: "https://github.com/ChimeHQ/TextStory", exact: "0.9.1"),
        .package(url: "https://github.com/ChimeHQ/LanguageClient", exact: "0.8.2"),
        .package(url: "https://github.com/ChimeHQ/LanguageServerProtocol", exact: "0.14.0"),
        .package(url: "https://github.com/ChimeHQ/JSONRPC", exact: "0.9.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation", exact: "0.9.19"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", exact: "1.0.1"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
        .package(url: "https://github.com/thecoolwinter/SwiftTerm", branch: "codeedit")
    ],
    targets: [
        // MARK: - Kernel
        // Rule: zero dependencies, no UI imports, platform-free. See ARCHITECTURE.md.
        .target(name: "CodeEditCore"),

        // MARK: - Shared substrate
        // Rule: CodeEditUI depends on CodeEditSymbols only — no local targets.
        .target(
            name: "CodeEditUI",
            dependencies: [.product(name: "CodeEditSymbols", package: "CodeEditSymbols")],
            resources: [.process("Resources")]
        ),
        .target(name: "CodeEditSettings", dependencies: ["CodeEditCore"]),

        // MARK: - Editor substrate
        // CodeFileDocument + editor-framework bridging; consumed only by CEEditor and CELSP.
        .target(
            name: "CodeEditDocument",
            dependencies: [
                "CodeEditCore",
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "CodeEditTextView", package: "CodeEditTextView"),
                .product(name: "CodeEditLanguages", package: "CodeEditLanguages"),
                .product(name: "TextStory", package: "TextStory")
            ]
        ),

        // MARK: - App-linked services
        // Zero package-internal consumers; the app target links these directly.
        .target(name: "ShellClient", dependencies: ["CodeEditCore"]),
        .target(name: "CEWorkspaceFileManager", dependencies: ["CodeEditCore"]),

        // MARK: - Features
        // Norm: prefer features to be leaves. Declare any feature→feature edge here.
        .target(
            name: "CEEditor",
            dependencies: [
                "CodeEditCore",
                "CodeEditUI",
                "CodeEditDocument",
                "CodeEditSettings",
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "CodeEditTextView", package: "CodeEditTextView"),
                .product(name: "CodeEditLanguages", package: "CodeEditLanguages"),
                .product(name: "CodeEditSymbols", package: "CodeEditSymbols"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "DequeModule", package: "swift-collections")
            ],
            // The ONLY target permitted to opt out of Swift 6. See ARCHITECTURE.md.
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .target(
            name: "CELSP",
            dependencies: [
                "CodeEditCore",
                "CodeEditDocument",
                "CodeEditSettings",
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
        .target(name: "CENotifications", dependencies: ["CodeEditCore", "CodeEditUI"]),
        .target(name: "CESearch", dependencies: ["CodeEditCore", "CodeEditUI", "CodeEditSettings"]),
        .target(
            name: "CESourceControl",
            dependencies: [
                "CodeEditCore",
                "CodeEditSettings",
                "CodeEditUI",
                .product(name: "CodeEditSymbols", package: "CodeEditSymbols")
            ]
        ),
        .target(
            name: "CETerminal",
            dependencies: [
                "CodeEditCore",
                "CodeEditSettings",
                "CodeEditUI",
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ]
        ),

        // MARK: - Tests
        .testTarget(name: "CodeEditCoreTests", dependencies: ["CodeEditCore"]),
        .testTarget(
            name: "CodeEditSettingsTests",
            dependencies: ["CodeEditSettings", "CELSP", "CESourceControl", "CETerminal"],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(name: "CodeEditUIUnitTests", dependencies: ["CodeEditUI"]),
        .testTarget(name: "CESearchTests", dependencies: ["CESearch", "CodeEditCore"]),
        .testTarget(
            name: "CELSPTests",
            dependencies: [
                "CELSP",
                .product(name: "CodeEditSourceEditor", package: "CodeEditSourceEditor"),
                .product(name: "LanguageServerProtocol", package: "LanguageServerProtocol")
            ]
        ),
        .testTarget(name: "CESourceControlTests", dependencies: ["CESourceControl"])
    ]
)
