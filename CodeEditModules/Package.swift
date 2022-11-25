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
            name: "Keybindings",
            targets: ["Keybindings"]
        ),
        .library(
            name: "TabBar",
            targets: ["TabBar"]
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
            name: "Keybindings",
            dependencies: ["WorkspaceClient"],
            path: "Modules/Keybindings/src",
            resources: [.copy("default_keybindings.json")]
        ),
        .target(
            name: "TabBar",
            path: "Modules/TabBar/src"
        ),
    ]
)
