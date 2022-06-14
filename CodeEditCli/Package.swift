// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "CodeEditCli",
    products: [
        .executable(name: "CodeEditCli", targets: ["CodeEditCli"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CodeEditCli"
        ),
    ]
)
