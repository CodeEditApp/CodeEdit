//
//  PackageSourceParser+Golang.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/12/25.
//

extension PackageSourceParser {
    static func parseGolangPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:golang/PACKAGE@VERSION#SUBPATH?PARAMS
        let pkgPrefix = "pkg:golang/"
        let sourceId = entry.source.id.removingPercentEncoding ?? entry.source.id
        guard sourceId.hasPrefix(pkgPrefix) else { return .unknown }

        let pkgString = sourceId.dropFirst(pkgPrefix.count)

        // Extract subpath first if present
        let subpathComponents = pkgString.split(separator: "#", maxSplits: 1)
        let packageVersionParam = String(subpathComponents[0])
        let subpath = subpathComponents.count > 1 ? String(subpathComponents[1]) : nil

        // Then split into package@version and parameters
        let components = packageVersionParam.split(separator: "?", maxSplits: 1)
        let packageVersion = String(components[0])
        let parameters = components.count > 1 ? String(components[1]) : ""

        let packageVersionParts = packageVersion.split(separator: "@", maxSplits: 1)
        guard packageVersionParts.count >= 1 else { return .unknown }

        let packageName = String(packageVersionParts[0])
        let version = packageVersionParts.count > 1 ? String(packageVersionParts[1]) : "latest"

        // Parse parameters as options
        var options: [String: String] = ["buildTool": "golang"]
        options["subpath"] = subpath
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

        // For Go packages, the package name is often also the repository URL
        if repositoryUrl == nil {
            repositoryUrl = "https://\(packageName)"
        }

        let source = PackageSource(
            sourceId: sourceId,
            type: .golang,
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
