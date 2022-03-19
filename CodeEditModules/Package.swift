// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CodeEditModules",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v11)
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
             name: "CodeEditor",
             targets: ["CodeEditor"]
         )
    ],
    dependencies: [
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
        .package(
            url: "https://github.com/raspu/Highlightr",
            from: "2.1.2"
        )
    ],
    targets: [
        .target(
            name: "WorkspaceClient",
            path: "Modules/WorkspaceClient/src"
        ),
        .testTarget(
            name: "WorkspaceClientTests",
            dependencies: [
                "WorkspaceClient"
            ],
            path: "Modules/WorkspaceClient/Tests"
        ),
        .target(
            name: "CodeFile",
            dependencies: [
                "CodeEditor"
            ],
            path: "Modules/CodeFile/src"
        ),
        .testTarget(
            name: "CodeFileTests",
            dependencies: [
                "CodeFile"
            ],
            path: "Modules/CodeFile/Tests"
        ),
        .target(
            name: "WelcomeModule",
            path: "Modules/WelcomeModule/src"
        ),
        .testTarget(
            name: "WelcomeModuleTests",
            dependencies: [
                "WelcomeModule",
                "SnapshotTesting"
            ],
            path: "Modules/WelcomeModule/Tests"
        ),
        .target(
            name: "CodeEditor",
            dependencies: [
                "Highlightr"
            ],
            path: "Modules/CodeEditor"
        )
    ]
)
