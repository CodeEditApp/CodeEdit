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
            name: "Overlays",
            targets: ["Overlays"]
        ),
        .library(
            name: "GitClient",
            targets: ["GitClient"]
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
            name: "GitClone",
            targets: ["GitClone"]
        ),
        .library(
            name: "FontPicker",
            targets: ["FontPicker"]
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
            name: "Accounts",
            targets: ["Accounts"]
        ),
        .library(
            name: "About",
            targets: ["About"]
        ),
        .library(
            name: "QuickOpen",
            targets: ["QuickOpen"]
        ),
        .library(
            name: "Design",
            targets: ["Design"]
        ),
        .library(
            name: "ExtensionsStore",
            targets: ["ExtensionsStore"]
        ),
        .library(
            name: "Breadcrumbs",
            targets: ["Breadcrumbs"]
        ),
    ],
    dependencies: [
        .package(
            name: "Highlightr",
            url: "https://github.com/raspu/Highlightr.git",
            from: "2.1.2"
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
            name: "Introspect",
            url: "https://github.com/siteline/SwiftUI-Introspect",
            from: "0.1.4"
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
    ],
    targets: [
        .target(
            name: "WorkspaceClient",
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
                "AppPreferences"
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
                "Design",
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
                "SnapshotTesting",
            ],
            path: "Modules/WelcomeModule/Tests"
        ),
        .target(
            name: "StatusBar",
            dependencies: [
                "GitClient",
                "TerminalEmulator",
                "CodeFile",
            ],
            path: "Modules/StatusBar/src"
        ),
        .target(
            name: "Overlays",
            path: "Modules/Overlays/src"
        ),
        .target(
            name: "GitClient",
            dependencies: [
                "ShellClient",
            ],
            path: "Modules/GitClient/src"
        ),
        .testTarget(
            name: "GitClientTests",
            dependencies: [
                "GitClient",
                "ShellClient",
            ],
            path: "Modules/GitClient/Tests"
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
            name: "GitClone",
            dependencies: [
                "GitClient",
                "ShellClient"
            ],
            path: "Modules/GitClone/src"
        ),
        .target(
            name: "FontPicker",
            path: "Modules/FontPicker/src"
        ),
        .target(
            name: "ShellClient",
            path: "Modules/ShellClient/src"
        ),
        .target(
            name: "AppPreferences",
            dependencies: [
                "Preferences",
                "FontPicker",
            ],
            path: "Modules/AppPreferences/src"
        ),
        .target(
            name: "Accounts",
            path: "Modules/Accounts/src"
        ),
        .target(
            name: "About",
            path: "Modules/About/src"
        ),
        .target(
            name: "QuickOpen",
            dependencies: [
                "WorkspaceClient",
                "CodeFile",
                "Design",
            ],
            path: "Modules/QuickOpen/src"
        ),
        .target(
            name: "Design",
            dependencies: [
                "Introspect",
            ],
            path: "Modules/Design/src"
        ),
        .target(
            name: "ExtensionsStore",
            dependencies: [
                "CodeEditKit",
                "Light-Swift-Untar",
                .productItem(name: "GRDB", package: "GRDB.swift", condition: nil)
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
    ]
)
