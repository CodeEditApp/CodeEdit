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
        )
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
                "Highlightr"
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
            dependencies: [
                "WorkspaceClient"
            ],
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
			name: "StatusBar",
            dependencies: [
                "GitClient",
				"TerminalEmulator"
            ],
			path: "Modules/StatusBar/src"
		),
        .target(
            name: "Overlays",
            path: "Modules/Overlays/src"
        ),
        .target(
            name: "GitClient",
            path: "Modules/GitClient/src"
        ),
        .target(
          name: "TerminalEmulator",
          dependencies: ["SwiftTerm"],
          path: "Modules/TerminalEmulator/src"
        ),
        .target(
            name: "Search",
            dependencies: [
                "WorkspaceClient"
            ],
            path: "Modules/Search/src"
        ),
        .target(
            name: "GitClone",
//            dependencies: ["GitClient"],
            path: "Modules/GitClone/src"
        )
    ]
)
