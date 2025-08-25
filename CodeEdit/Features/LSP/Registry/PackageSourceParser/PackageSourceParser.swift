//
//  PackageSourceParser.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/3/25.
//

import Foundation

/// Parser for package source IDs
enum PackageSourceParser {
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
        let gitReference: PackageSource.GitReference = isCommitHash ? .revision(version) : .tag(version)

        // Is this going to be built from source or downloaded
        let isSourceBuild = if entry.source.asset == nil {
            true
        } else {
            false
        }

        let source = PackageSource(
            sourceId: sourceId,
            type: isSourceBuild ? .sourceBuild : .github,
            pkgName: packageName,
            entryName: entry.name,
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

        let downloadURL = URL(string: "\(repoURL)/releases/download/\(gitTag)/\(fileName)")!
        return .binaryDownload(source: pkgSource, url: downloadURL)
    }

    private static func parseGithubSourceBuild(
        _ pkgSource: PackageSource,
        _ entry: RegistryItem
    ) -> InstallationMethod {
        guard let build = entry.source.build,
              let command = build.getUnixBuildCommand()
        else {
            return .unknown
        }
        return .sourceBuild(source: pkgSource, command: command)
    }
}
