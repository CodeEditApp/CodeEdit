// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CodeEditModules",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v11),
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
            ],
            path: "Modules/WelcomeModule/src"
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
            dependencies: ["SwiftTerm"],
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
    ]
)
