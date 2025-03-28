//
//  GithubPackageManager.swift
//  LSPInstallTest
//
//  Created by Abe Malla on 3/10/25.
//

import Foundation

final class GithubPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    internal let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    func initialize(in packagePath: URL) async throws {
        guard await isInstalled() else {
            throw PackageManagerError.packageManagerNotInstalled
        }

        do {
            try createDirectoryStructure(for: packagePath)
        } catch {
            throw PackageManagerError.initializationFailed(error.localizedDescription)
        }
    }

    func install(method: InstallationMethod) async throws {
        guard case .standardPackage(let source) = method else {
            throw PackageManagerError.invalidConfiguration
        }

        let packagePath = installationDirectory.appending(path: source.entryName)
        try await initialize(in: packagePath)

        switch method {
        case let .binaryDownload(source, url):
            try await downloadBinary(source, url)
        case let .sourceBuild(source, command):
            try await installFromSource(source, command)
        case .standardPackage, .unknown:
            throw PackageManagerError.invalidConfiguration
        }
    }

    func getBinaryPath(for package: String) -> String {
        return installationDirectory.appending(path: package).appending(path: "bin").path
    }

    func isInstalled() async -> Bool {
        do {
            let versionOutput = try await runCommand("git --version")
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output.contains("git version")
        } catch {
            print("Git version check failed: \(error)")
            return false
        }
    }

    private func downloadBinary(_ source: PackageSource, _ url: URL) async throws {
        _ = try await URLSession.shared.data(from: url)
        let fileName = url.lastPathComponent
        let downloadPath = installationDirectory.appending(path: source.entryName)
        let packagePath = downloadPath.appending(path: fileName)

        if !FileManager.default.fileExists(atPath: packagePath.path) {
            throw RegistryManagerError.downloadFailed(
                url: url,
                error: NSError(domain: "Coould not download package", code: -1)
            )
        }

        if fileName.hasSuffix(".tar") || fileName.hasSuffix(".zip") {
            try FileManager.default.unzipItem(at: packagePath, to: downloadPath)
        }
    }

    private func installFromSource(_ source: PackageSource, _ command: String) async throws {
        let installPath = installationDirectory.appending(path: source.entryName, directoryHint: .isDirectory)
        do {
            _ = try await executeInDirectory(in: installPath.path, ["git", "clone", source.repositoryUrl!])
            let repoPath = installPath.appending(path: source.pkgName, directoryHint: .isDirectory)
            _ = try await executeInDirectory(in: repoPath.path, [command])
        } catch {
            print("Failed to build from source: \(error)")
            throw PackageManagerError.installationFailed("Source build failed.")
        }
    }
}
