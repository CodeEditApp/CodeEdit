//
//  PackageSourceParser+NPM.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/12/25.
//

extension PackageSourceParser {
    static func parseNpmPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:npm/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:npm/"
        let sourceId = entry.source.id.removingPercentEncoding ?? entry.source.id
        guard sourceId.hasPrefix(pkgPrefix) else { return .unknown }

        let pkgString = sourceId.dropFirst(pkgPrefix.count)

        // Split into package@version and parameters
        let components = pkgString.split(separator: "?", maxSplits: 1)
        let packageVersion = String(components[0])
        let parameters = components.count > 1 ? String(components[1]) : ""

        let (packageName, version) = parseNPMPackageNameAndVersion(packageVersion)

        // Parse parameters as options
        var options: [String: String] = ["buildTool": "npm"]
        var repositoryUrl: String?
        var gitReference: PackageSource.GitReference?

        let paramPairs = parameters.split(separator: "&")
        for pair in paramPairs {
            let keyValue = pair.split(separator: "=", maxSplits: 1)
            guard keyValue.count == 2 else { continue }

            let key = String(keyValue[0])
            let value = String(keyValue[1])

            if key == "repository_url" {
                repositoryUrl = value
            } else if key == "rev" && value.lowercased() == "true" {
                gitReference = .revision(version)
            } else if key == "tag" && value.lowercased() == "true" {
                gitReference = .tag(version)
            } else {
                options[key] = value
            }
        }

        let source = PackageSource(
            sourceId: sourceId,
            type: .npm,
            pkgName: packageName,
            entryName: entry.name,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

    private static func parseNPMPackageNameAndVersion(_ packageVersion: String) -> (String, String) {
        var packageName: String
        var version: String = "latest"

        if packageVersion.contains("@") && !packageVersion.hasPrefix("@") {
            // Regular package with version: package@1.0.0
            let parts = packageVersion.split(separator: "@", maxSplits: 1)
            packageName = String(parts[0])
            if parts.count > 1 {
                version = String(parts[1])
            }
        } else if packageVersion.hasPrefix("@") {
            // Scoped package: @org/package@1.0.0
            if let atIndex = packageVersion[
                packageVersion.index(after: packageVersion.startIndex)...
            ].firstIndex(of: "@") {
                packageName = String(packageVersion[..<atIndex])
                version = String(packageVersion[packageVersion.index(after: atIndex)...])
            } else {
                packageName = packageVersion
            }
        } else {
            packageName = packageVersion
        }

        return (packageName, version)
    }
}
