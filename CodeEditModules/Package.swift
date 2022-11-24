// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "CodeEditModules",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "WorkspaceClient",
            targets: ["WorkspaceClient"]
        ),
        .library(
            name: "ShellClient",
            targets: ["ShellClient"]
        ),
        .library(
            name: "CodeEditUI",
            targets: ["CodeEditUI"]
        ),
        .library(
            name: "CodeEditUtils",
            targets: ["CodeEditUtils"]
        ),
        .library(
            name: "Keybindings",
            targets: ["Keybindings"]
        ),
        .library(
            name: "TabBar",
            targets: ["TabBar"]
        ),
        .library(
            name: "Git",
            targets: ["Git"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/sparkle-project/Sparkle.git",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
        .package(
            url: "https://github.com/migueldeicaza/SwiftTerm.git",
            from: "1.0.7"
        ),
        .package(
            url: "https://github.com/sindresorhus/Preferences.git",
            from: "2.6.0"
        ),
        .package(
            url: "https://github.com/CodeEditApp/CodeEditKit.git",
            exact: "0.0.1"
        ),
        .package(
            url: "https://github.com/Light-Untar/Light-Swift-Untar.git",
            from: "1.0.4"
        ),
        .package(
            url: "https://github.com/groue/GRDB.swift.git",
            from: "5.22.2"
        ),
        .package(
            url: "https://github.com/CodeEditApp/CodeEditSymbols.git",
            exact: "0.1.0"
        ),
        .package(
            url: "https://github.com/CodeEditApp/CodeEditTextView.git",
            exact: "0.1.5"
        ),
    ],
    targets: [
        .target(
            name: "WorkspaceClient",
            dependencies: [
                "TabBar"
            ],
            path: "Modules/WorkspaceClient/src"
        ),
        .testTarget(
            name: "WorkspaceClientTests",
            dependencies: [
                "WorkspaceClient",
            ],
            path: "Modules/WorkspaceClient/Tests"
        ),
        .target(
            name: "ShellClient",
            path: "Modules/ShellClient/src"
        ),
        .target(
            name: "CodeEditUI",
            dependencies: [
                "CodeEditSymbols",
                "WorkspaceClient",
                "Git"
            ],
            path: "Modules/CodeEditUI/src"
        ),
        .testTarget(
            name: "CodeEditUITests",
            dependencies: [
                "CodeEditUI",
                "WorkspaceClient",
                "Git",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Modules/CodeEditUI/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "CodeEditUtils",
            path: "Modules/CodeEditUtils/src"
        ),
        .target(
            name: "Keybindings",
            dependencies: ["WorkspaceClient"],
            path: "Modules/Keybindings/src",
            resources: [.copy("default_keybindings.json")]
        ),
        .target(
            name: "TabBar",
            path: "Modules/TabBar/src"
        ),
        .testTarget(
            name: "CodeEditUtilsTests",
            dependencies: [
                "CodeEditUtils"
            ],
            path: "Modules/CodeEditUtils/Tests"
        ),
        .target(
            name: "Git",
            dependencies: [
                "ShellClient",
                "WorkspaceClient"
            ],
            path: "Modules/Git/src"
        ),
        .testTarget(
            name: "GitTests",
            dependencies: [
                "Git",
                "ShellClient",
            ],
            path: "Modules/Git/Tests"
        ),
    ]
)
