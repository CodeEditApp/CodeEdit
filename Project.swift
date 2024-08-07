import ProjectDescription

let project = Project(name: "CodeEditTuist",
                      packages: [
                        .remote(url: "https://github.com/lukepistrol/SwiftLintPlugin", requirement: .upToNextMajor(from: "0.2.2"))
                      ],
                      settings: .settings(configurations: [
                        .debug(name: "Debug", xcconfig: "xcconfigs/Project.xcconfig"),
                        .release(name: "Release", xcconfig: "xcconfigs/Project.xcconfig"),
                        .release(name: "Alpha", xcconfig: "xcconfigs/Project.xcconfig"),
                        .release(name: "Pre", xcconfig: "xcconfigs/Project.xcconfig"),
                        .release(name: "Beta", xcconfig: "xcconfigs/Project.xcconfig")
                      ]),
                      targets: [
                        .target(name: "CodeEdit",
                                destinations: .macOS,
                                product: .app,
                                bundleId: "app.codeedit.CodeEdit",
                                infoPlist: .file(path: "CodeEdit/Info.plist"),
                                sources: .paths([
                                    "CodeEdit/**/*.swift"
                                ]),
                                resources: [
                                    .folderReference(path: "./DefaultThemes"),
                                    "./CodeEdit/Preview Content/Preview Assets.xcassets",
                                    "./CodeEdit/ShellIntegration/**/*",
                                    "./CodeEdit/Features/Keybindings/**/*",
                                    "./CodeEdit/Localization/**/*",
                                    "./.all-contributorsrc",
                                    "./CodeEdit/Assets.xcassets",
                                    "./CodeEdit/Features/Extensions/codeedit.extension.appextensionpoint"
                                ],
                                dependencies: [
                                    .target(name: "OpenWithCodeEdit"),
                                    .package(product: "SwiftLintPlugin", type: .plugin),
                                    .external(name: "CodeEditKit"),
                                    .external(name: "GRDB"),
                                    .external(name: "Sparkle"),
                                    .external(name: "CodeEditSourceEditor"),
                                    .external(name: "OrderedCollections"),
                                    .external(name: "LogStream"),
                                    .external(name: "CollectionConcurrencyKit"),
                                    .external(name: "SwiftTerm"),
                                    .external(name: "Introspect"),
                                    .external(name: "CodeEditSymbols"),
                                    .external(name: "DequeModule")
                                ],
                                settings: .settings(configurations: [
                                    .debug(name: "Debug", xcconfig: "xcconfigs/CodeEdit.xcconfig"),
                                    .release(name: "Release", xcconfig: "xcconfigs/CodeEdit.xcconfig"),
                                    .release(name: "Alpha", xcconfig: "xcconfigs/CodeEdit.xcconfig"),
                                    .release(name: "Pre", xcconfig: "xcconfigs/CodeEdit.xcconfig"),
                                    .release(name: "Beta", xcconfig: "xcconfigs/CodeEdit.xcconfig")
                                  ])
                               ),
                        .target(name: "CodeEditTests",
                                destinations: .macOS,
                                product: .unitTests,
                                bundleId: "app.codeedit.CodeEditTests",
                                sources: .paths([
                                    "CodeEditTests/**/*.swift"
                                ]),
                                resources: [
                                    "CodeEditTests/Features/CodeEditUI/__Snapshots__/UnitTests/**/*.png"
                                ],
                                dependencies: [
                                    .target(name: "CodeEdit"),
                                    .external(name: "SnapshotTesting")
                                ],
                                settings: .settings(configurations: [
                                    .debug(name: "Debug", xcconfig: "xcconfigs/CodeEditTests.xcconfig"),
                                    .release(name: "Release", xcconfig: "xcconfigs/CodeEditTests.xcconfig"),
                                    .release(name: "Alpha", xcconfig: "xcconfigs/CodeEditTests.xcconfig"),
                                    .release(name: "Pre", xcconfig: "xcconfigs/CodeEditTests.xcconfig"),
                                    .release(name: "Beta", xcconfig: "xcconfigs/CodeEditTests.xcconfig")
                                  ])
                               ),
                        .target(name: "OpenWithCodeEdit",
                                destinations: .macOS,
                                product: .appExtension,
                                bundleId: "app.codeedit.CodeEdit.OpenWithCodeEdit",
                                infoPlist: .file(path: "OpenWithCodeEdit/Info.plist"),
                                sources: .paths([
                                    "OpenWithCodeEdit/**/*.swift"
                                ]),
                                resources: [
                                    "OpenWithCodeEdit/Media.xcassets"
                                ],
                                dependencies: [],
                                settings: .settings(configurations: [
                                    .debug(name: "Debug", xcconfig: "xcconfigs/OpenWithCodeEdit.xcconfig"),
                                    .release(name: "Release", xcconfig: "xcconfigs/OpenWithCodeEdit.xcconfig"),
                                    .release(name: "Alpha", xcconfig: "xcconfigs/OpenWithCodeEdit.xcconfig"),
                                    .release(name: "Pre", xcconfig: "xcconfigs/OpenWithCodeEdit.xcconfig"),
                                    .release(name: "Beta", xcconfig: "xcconfigs/OpenWithCodeEdit.xcconfig")
                                  ])
                               )
                      ])


