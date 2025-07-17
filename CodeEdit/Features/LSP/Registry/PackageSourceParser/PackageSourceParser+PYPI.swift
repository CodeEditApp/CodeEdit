//
//  PackageSourceParser+PYPI.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/12/25.
//

extension PackageSourceParser {
    static func parsePythonPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:pypi/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:pypi/"
        let sourceId = entry.source.id
        guard sourceId.hasPrefix(pkgPrefix) else { return .unknown }

        let pkgString = sourceId.dropFirst(pkgPrefix.count)

        let components = pkgString.split(separator: "?", maxSplits: 1)
        let packageVersion = String(components[0])
        let parameters = components.count > 1 ? String(components[1]) : ""

        let packageVersionParts = packageVersion.split(separator: "@", maxSplits: 1)
        guard packageVersionParts.count >= 1 else { return .unknown }

        let packageName = String(packageVersionParts[0])
        let version = packageVersionParts.count > 1 ? String(packageVersionParts[1]) : "latest"

        // Parse parameters as options
        var options: [String: String] = ["buildTool": "pip"]
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
            type: .pip,
            pkgName: packageName,
            entryName: entry.name,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }
}
