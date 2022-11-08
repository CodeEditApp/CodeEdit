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
            name: "CodeFile",
            targets: ["CodeFile"]
        ),
        .library(
            name: "Commands",
            targets: ["Commands"]
        ),
        .library(
            name: "WelcomeModule",
            targets: ["WelcomeModule"]
        ),
        .library(
            name: "StatusBar",
            targets: ["StatusBar"]
        ),
        .library(
            name: "TerminalEmulator",
            targets: ["TerminalEmulator"]
        ),
        .library(
            name: "Search",
            targets: ["Search"]
        ),
        .library(
            name: "ShellClient",
            targets: ["ShellClient"]
        ),
        .library(
            name: "AppPreferences",
            targets: ["AppPreferences"]
        ),
        .library(
            name: "CodeEditUI",
            targets: ["CodeEditUI"]
        ),
        .library(
            name: "CodeEditExtension",
            targets: ["CodeEditExtension"]
        ),
        .library(
            name: "ExtensionsStore",
            targets: ["ExtensionsStore"]
        ),
        .library(
            name: "Breadcrumbs",
            targets: ["Breadcrumbs"]
        ),
        .library(
            name: "Feedback",
            targets: ["Feedback"]
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
            name: "CodeFile",
            dependencies: [
                "AppPreferences",
                "CodeEditUtils",
                "CodeEditTextView",
            ],
            path: "Modules/CodeFile/src"
        ),
        .testTarget(
            name: "CodeFileTests",
            dependencies: [
                "CodeFile",
            ],
            path: "Modules/CodeFile/Tests"
        ),
        .target(
            name: "Commands",
            dependencies: [
                "Keybindings",
                "CodeEditUI",
            ],
            path: "Modules/Commands/src"
        ),
        .target(
            name: "WelcomeModule",
            dependencies: [
                "WorkspaceClient",
                "CodeEditUI",
                "Git",
                "AppPreferences",
                "Keybindings",
            ],
            path: "Modules/WelcomeModule/src",
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "WelcomeModuleTests",
            dependencies: [
                "WelcomeModule",
                "Git",
                "ShellClient",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Modules/WelcomeModule/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "StatusBar",
            dependencies: [
                "TerminalEmulator",
                "CodeFile",
                "CodeEditUI",
                "CodeEditSymbols",
            ],
            path: "Modules/StatusBar/src"
        ),
        .testTarget(
            name: "StatusBarTests",
            dependencies: [
                "StatusBar",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Modules/StatusBar/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "TerminalEmulator",
            dependencies: [
                "SwiftTerm",
                "AppPreferences"
            ],
            path: "Modules/TerminalEmulator/src"
        ),
        .target(
            name: "Search",
            dependencies: [
                "WorkspaceClient",
            ],
            path: "Modules/Search/src"
        ),
        .target(
            name: "ShellClient",
            path: "Modules/ShellClient/src"
        ),
        .target(
            name: "AppPreferences",
            dependencies: [
                "Preferences",
                "CodeEditUI",
                "Git",
                "Keybindings",
                "CodeEditUtils",
                "CodeEditSymbols",
                "CodeEditTextView",
                "Sparkle"
            ],
            path: "Modules/AppPreferences/src",
            resources: [.copy("Resources")]
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
            name: "CodeEditExtension",
            dependencies: [
                "CodeEditKit"
            ],
            path: "Modules/CodeEditExtension/src"
        ),
        .target(
            name: "ExtensionsStore",
            dependencies: [
                "CodeEditKit",
                "Light-Swift-Untar",
                .productItem(name: "GRDB", package: "GRDB.swift", condition: nil),
                "LSP"
            ],
            path: "Modules/ExtensionsStore/src"
        ),
        .target(
            name: "Breadcrumbs",
            dependencies: [
                "WorkspaceClient",
                "AppPreferences",
            ],
            path: "Modules/Breadcrumbs/src"
        ),
        .target(
            name: "Feedback",
            dependencies: [
                "Git",
                "CodeEditUI",
                "AppPreferences",
                "CodeEditUtils",
            ],
            path: "Modules/Feedback/src"
        ),
        .target(
            name: "LSP",
            path: "Modules/LSP/src"

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
