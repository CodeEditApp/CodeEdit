//
//  GithubPackageManager.swift
//  LSPInstallTest
//
//  Created by Abe Malla on 3/10/25.
//

import Foundation

final class GithubPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    let shellClient: ShellClient

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
        switch method {
        case let .binaryDownload(source, url):
            let packagePath = installationDirectory.appending(path: source.entryName)
            try await initialize(in: packagePath)
            try await downloadBinary(source, url)

        case let .sourceBuild(source, command):
            let packagePath = installationDirectory.appending(path: source.entryName)
            try await initialize(in: packagePath)
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
            return false
        }
    }

    private func downloadBinary(_ source: PackageSource, _ url: URL) async throws {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RegistryManagerError.downloadFailed(
                url: url,
                error: NSError(domain: "HTTP error", code: (response as? HTTPURLResponse)?.statusCode ?? -1)
            )
        }

        let fileName = url.lastPathComponent
        let downloadPath = installationDirectory.appending(path: source.entryName)
        let packagePath = downloadPath.appending(path: fileName)

        do {
            try data.write(to: packagePath, options: .atomic)
        } catch {
            throw RegistryManagerError.downloadFailed(
                url: url,
                error: error
            )
        }

        if !FileManager.default.fileExists(atPath: packagePath.path) {
            throw RegistryManagerError.downloadFailed(
                url: url,
                error: NSError(domain: "Could not download package", code: -1)
            )
        }

        if fileName.hasSuffix(".tar") || fileName.hasSuffix(".zip") {
            try FileManager.default.unzipItem(at: packagePath, to: downloadPath)
        }
    }

    private func installFromSource(_ source: PackageSource, _ command: String) async throws {
        let installPath = installationDirectory.appending(path: source.entryName, directoryHint: .isDirectory)
        do {
            guard let repoURL = source.repositoryUrl else {
                throw PackageManagerError.invalidConfiguration
            }

            _ = try await executeInDirectory(in: installPath.path, ["git", "clone", repoURL])
            let repoPath = installPath.appending(path: source.pkgName, directoryHint: .isDirectory)
            _ = try await executeInDirectory(in: repoPath.path, [command])
        } catch {
            throw PackageManagerError.installationFailed("Source build failed.")
        }
    }
}
