// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditServices",
    platforms: [.macOS(.v14)],
    products: [
        // One product per service: every consumer's manifest names exactly the
        // services it links (decided 2026-07-12; replaced the single umbrella).
        .library(name: "ShellClient", targets: ["ShellClient"]),
        .library(name: "CEWorkspaceFileManager", targets: ["CEWorkspaceFileManager"])
    ],
    dependencies: [
        .package(path: "../../Foundation/CodeEditCore")
    ],
    targets: [
        // Tier rule: service targets depend on CodeEditCore ONLY —
        // never on sibling targets, CodeEditUI, features, or Factory.
        .target(
            name: "ShellClient",
            dependencies: [.product(name: "CodeEditCore", package: "CodeEditCore")]
        ),
        .target(
            name: "CEWorkspaceFileManager",
            dependencies: [.product(name: "CodeEditCore", package: "CodeEditCore")]
        )
    ]
)
