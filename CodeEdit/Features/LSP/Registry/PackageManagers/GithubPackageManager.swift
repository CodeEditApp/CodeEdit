//
//  GithubPackageManager.swift
//  LSPInstallTest
//
//  Created by Abe Malla on 3/10/25.
//

import Foundation

class GithubPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    internal let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    func initialize(in packagePath: URL) async throws { }

    func install(method: InstallationMethod) async throws {
        switch method {
        case let .binaryDownload(source, url):
            downloadBinary(source, url)
            break
        case let .sourceBuild(source, command):
            installFromSource(source, command)
            break
        case .standardPackage(_), .unknown:
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
    
    private func downloadBinary(_ source: PackageSource, _ url: String) {
        
    }
    
    private func installFromSource(_ source: PackageSource, _ command: String) {
        
    }
}
