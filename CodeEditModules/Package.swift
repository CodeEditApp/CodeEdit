// swift-tools-version:5.5

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
            name: "About",
            targets: ["About"]
        ),
        .library(
            name: "Acknowledgements",
            targets: ["Acknowledgements"]
        ),
        .library(
            name: "QuickOpen",
            targets: ["QuickOpen"]
        ),
        .library(
            name: "CodeEditUI",
            targets: ["CodeEditUI"]
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
            name: "Highlightr",
            url: "https://github.com/lukepistrol/Highlightr.git",
            branch: "main"
        ),
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
        .package(
            name: "SwiftTerm",
            url: "https://github.com/migueldeicaza/SwiftTerm.git",
            from: "1.0.7"
        ),
        .package(
            name: "Preferences",
            url: "https://github.com/sindresorhus/Preferences.git",
            from: "2.5.0"
        ),
        .package(
            name: "CodeEditKit",
            url: "https://github.com/CodeEditApp/CodeEditKit",
            branch: "main"
        ),
        .package(
            name: "Light-Swift-Untar",
            url: "https://github.com/Light-Untar/Light-Swift-Untar",
            from: "1.0.4"
        ),
        .package(
            url: "https://github.com/groue/GRDB.swift.git",
            from: "5.22.2"
        ),
        .package(
            name: "CodeEditSymbols",
            url: "https://github.com/CodeEditApp/CodeEditSymbols",
            branch: "main"
        ),
        .package(
            name: "CodeEditTextView",
            url: "https://github.com/CodeEditApp/CodeEditTextView",
            branch: "main"
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
                "Highlightr",
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
            name: "WelcomeModule",
            dependencies: [
                "WorkspaceClient",
                "CodeEditUI",
                "Git",
                "AppPreferences",
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
                "SnapshotTesting",
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
                "SnapshotTesting"
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
                "CodeEditUtils",
                "CodeEditSymbols",
                "CodeEditTextView",
            ],
            path: "Modules/AppPreferences/src",
            resources: [.copy("Resources")]
        ),
        .target(
            name: "About",
            dependencies: [
                "Acknowledgements",
                "CodeEditUtils"
            ],
            path: "Modules/About/src"
        ),
        .target(
            name: "QuickOpen",
            dependencies: [
                "WorkspaceClient",
                "CodeFile",
                "CodeEditUI",
            ],
            path: "Modules/QuickOpen/src"
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
                "SnapshotTesting",
            ],
            path: "Modules/CodeEditUI/Tests",
            exclude: ["__Snapshots__"]
        ),
        .target(
            name: "Acknowledgements",
            path: "Modules/Acknowledgements/src"
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
