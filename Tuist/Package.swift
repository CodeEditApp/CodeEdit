// swift-tools-version:5.9

import PackageDescription

#if TUIST
    import ProjectDescription

let packageSettings = PackageSettings(baseSettings: .settings(configurations: [
    .debug(name: "Debug"),
    .release(name: "Release"),
    .release(name: "Alpha"),
    .release(name: "Pre"),
    .release(name: "Beta")
]))
#endif

let package = Package(
    name: "CodeEdit",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/CodeEditApp/CodeEditSymbols", exact: "0.2.2"),
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", exact: "1.2.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", exact: "2.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.14.2")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "5.2.0")),
        .package(url: "https://github.com/siteline/swiftui-introspect", .upToNextMajor(from: "0.2.3")),
        .package(url: "https://github.com/CodeEditApp/CodeEditKit", exact: "0.1.1"),
        .package(url: "https://github.com/CodeEditApp/CodeEditSourceEditor", .upToNextMajor(from: "0.7.3")),
        .package(url: "https://github.com/Wouter01/LogStream", .upToNextMajor(from: "1.3.0"))
    ]
)
