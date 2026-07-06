// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CodeEditServices",
    platforms: [.macOS(.v14)],
    products: [
        // Umbrella product: the app links this once; each service target is
        // its own module (`import ShellClient`, `import CEWorkspaceFileManager`).
        // Adding a service later is a manifest-only change.
        .library(name: "CodeEditServices", targets: ["ShellClient", "CEWorkspaceFileManager"])
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
