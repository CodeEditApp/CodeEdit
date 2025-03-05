//
//  PackageSourceParser.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

/// Parser for package source IDs
enum PackageSourceParser {
    static func parse(_ sourceId: String, buildInstructions: [[String: Any]]? = nil) -> InstallationMethod {
        if sourceId.hasPrefix("pkg:cargo/") {
            return parseCargoPackage(sourceId)
        } else if sourceId.hasPrefix("pkg:npm/") {
            return parseNpmPackage(sourceId)
        } else if sourceId.hasPrefix("pkg:pypi/") {
            return parsePythonPackage(sourceId)
        } else if sourceId.hasPrefix("pkg:gem/") {
            return parseRubyGem(sourceId)
        } else if sourceId.hasPrefix("pkg:golang/") {
            return parseGolangPackage(sourceId)
        } else if sourceId.hasPrefix("pkg:github/") {
            return parseGithubPackage(sourceId, buildInstructions: buildInstructions)
        } else {
            return .unknown
        }
    }

    // MARK: - Private parsing methods for each package manager type

    private static func parseCargoPackage(_ sourceId: String) -> InstallationMethod {
        // Format: pkg:cargo/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:cargo/"
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
        var options: [String: String] = [:]
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
            } else if key == "branch" && value.lowercased() == "true" {
                gitReference = .branch(version)
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

    private static func parseNpmPackage(_ sourceId: String) -> InstallationMethod {
        // Format: pkg:npm/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:npm/"
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
        var options: [String: String] = [:]
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
            } else if key == "branch" && value.lowercased() == "true" {
                gitReference = .branch(version)
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

    private static func parsePythonPackage(_ sourceId: String) -> InstallationMethod {
        // Format: pkg:pypi/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:pypi/"
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
        var options: [String: String] = [:]
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
            } else if key == "branch" && value.lowercased() == "true" {
                gitReference = .branch(version)
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

    private static func parseRubyGem(_ sourceId: String) -> InstallationMethod {
        // Format: pkg:gem/PACKAGE@VERSION?PARAMS
        let pkgPrefix = "pkg:gem/"
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
        var options: [String: String] = [:]
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
            } else if key == "branch" && value.lowercased() == "true" {
                gitReference = .branch(version)
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

    private static func parseGolangPackage(_ sourceId: String) -> InstallationMethod {
        // Format: pkg:golang/PACKAGE@VERSION#SUBPATH?PARAMS
        let pkgPrefix = "pkg:golang/"
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
        var options: [String: String] = [:]
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
            } else if key == "branch" && value.lowercased() == "true" {
                gitReference = .branch(version)
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
            subpath: subpath,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference,
            options: options
        )
        return .standardPackage(source: source)
    }

    private static func parseGithubPackage(
        _ sourceId: String, buildInstructions: [[String: Any]]?
    ) -> InstallationMethod {
        // Format: pkg:github/OWNER/REPO@COMMIT_HASH
        let pkgPrefix = "pkg:github/"
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

        var options: [String: String] = [:]

        if let buildInstructions = buildInstructions, !buildInstructions.isEmpty {
            // Look at the build commands to determine the build tool
            if let firstInstruction = buildInstructions.first,
               let runCommands = firstInstruction["run"] as? String {

                if runCommands.contains("cargo ") {
                    options["buildTool"] = "cargo"
                } else if runCommands.contains("npm ") {
                    options["buildTool"] = "npm"
                } else if runCommands.contains("pip ") || runCommands.contains("python ") {
                    options["buildTool"] = "pip"
                } else if runCommands.contains("go ") {
                    options["buildTool"] = "golang"
                } else if runCommands.contains("gem ") {
                    options["buildTool"] = "gem"
                }
            }

            let source = PackageSource(
                sourceId: sourceId,
                type: .github,
                name: packageName,
                version: version,
                repositoryUrl: repositoryUrl,
                gitReference: gitReference,
                options: options
            )

            // Convert build instructions
            var instructions: [BuildInstructions] = []
            for instruction in buildInstructions {
                guard let target = instruction["target"] as? String,
                      let runCommands = instruction["run"] as? String,
                      let bin = instruction["bin"] as? String else {
                    continue
                }

                let commands = runCommands.split(separator: "\n").map { String($0) }
                instructions.append(BuildInstructions(
                    target: target,
                    commands: commands,
                    binaryPath: bin
                ))
            }
            return .sourceBuild(source: source, buildInstructions: instructions)
        }

        let source = PackageSource(
            sourceId: sourceId,
            type: .github,
            name: packageName,
            version: version,
            repositoryUrl: repositoryUrl,
            gitReference: gitReference
        )
        return .standardPackage(source: source)
    }
}
