//
//  PackageSourceParser.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

/// Parser for package source IDs
enum PackageSourceParser {
    static func parseCargoPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:cargo/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:cargo/"
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
        var options: [String: String] = ["buildTool": "cargo"]
        var repositoryUrl: String?
        var gitReference: GitReference?

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

        // If we have a repository URL but no git reference specified,
        // default to tag for versions and revision for commit hashes
        if repositoryUrl != nil, gitReference == nil {
            if version.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil {
                gitReference = .revision(version)
            } else {
                gitReference = .tag(version)
            }
        }

        let source = PackageSource(
            sourceId: sourceId,
            type: .cargo,
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

    static func parseNpmPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:npm/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:npm/"
        let sourceId = entry.source.id
        guard sourceId.hasPrefix(pkgPrefix) else { return .unknown }

        let pkgString = sourceId.dropFirst(pkgPrefix.count)

        // Split into package@version and parameters
        let components = pkgString.split(separator: "?", maxSplits: 1)
        let packageVersion = String(components[0])
        let parameters = components.count > 1 ? String(components[1]) : ""

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

        // Parse parameters as options
        var options: [String: String] = ["buildTool": "npm"]
        var repositoryUrl: String?
        var gitReference: GitReference?

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
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

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
        var gitReference: GitReference?

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
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

    static func parseRubyGem(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:gem/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:gem/"
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
        var options: [String: String] = ["buildTool": "gem"]
        var repositoryUrl: String?
        var gitReference: GitReference?

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
            type: .gem,
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

    static func parseGolangPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:golang/PACKAGE@VERSION#SUBPATH?PARAMS
        let pkgPrefix = "pkg:golang/"
        let sourceId = entry.source.id
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
        var gitReference: GitReference?

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
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

    static func parseGithubPackage(_ entry: RegistryItem) -> InstallationMethod {
        // Format: pkg:github/OWNER/REPO@COMMIT_HASH
        let pkgPrefix = "pkg:github/"
        let sourceId = entry.source.id
        guard sourceId.hasPrefix(pkgPrefix) else { return .unknown }

        let pkgString = sourceId.dropFirst(pkgPrefix.count)
        let packagePathVersion = pkgString.split(separator: "@", maxSplits: 1)
        guard packagePathVersion.count >= 1 else { return .unknown }

        let packagePath = String(packagePathVersion[0])
        let version = packagePathVersion.count > 1 ? String(packagePathVersion[1]) : "main"

        let pathComponents = packagePath.split(separator: "/")
        guard pathComponents.count >= 2 else { return .unknown }

        let owner = String(pathComponents[0])
        let repo = String(pathComponents[1])
        let packageName = repo
        let repositoryUrl = "https://github.com/\(owner)/\(repo)"

        let isCommitHash = version.range(of: "^[0-9a-f]{40}$", options: .regularExpression) != nil
        let gitReference: GitReference = isCommitHash ? .revision(version) : .tag(version)

        // Is this going to be built from source or downloaded
        let isSourceBuild = if case .none? = entry.source.asset {
            true
        } else {
            false
        }

        let source = PackageSource(
            sourceId: sourceId,
            type: isSourceBuild ? .sourceBuild : .github,
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: [:]
        )
        if isSourceBuild {
            return parseGithubSourceBuild(source, entry)
        } else {
            return parseGithubBinaryDownload(source, entry)
        }
    }

    private static func parseGithubBinaryDownload(
        _ pkgSource: PackageSource,
        _ entry: RegistryItem
    ) -> InstallationMethod {
        guard let assetContainer = entry.source.asset,
              let repoURL = pkgSource.repositoryUrl,
              case .tag(let gitTag) = pkgSource.gitReference,
              var fileName = assetContainer.getDarwinFileName(),
              !fileName.isEmpty
        else {
            return .unknown
        }

        do {
            var registryInfo = try entry.toDictionary()
            registryInfo["version"] = pkgSource.version
            fileName = try RegistryItemTemplateParser.process(
                template: fileName, with: registryInfo
            )
        } catch {
            return .unknown
        }

        let downloadURL = "\(repoURL)/releases/download/\(gitTag)/\(fileName)"
        return .binaryDownload(source: pkgSource, url: downloadURL)
    }

    private static func parseGithubSourceBuild(
        _ pkgSource: PackageSource,
        _ entry: RegistryItem
    ) -> InstallationMethod {
        guard let build = entry.source.build,
              var command = build.getUnixBuildCommand()
        else {
            return .unknown
        }
        return .sourceBuild(source: pkgSource, command: command)
    }
}
