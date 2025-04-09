//
//  NPMPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

final class NPMPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    internal let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    /// Initializes the npm project if not already initialized
    func initialize(in packagePath: URL) async throws {
        guard await isInstalled() else {
            throw PackageManagerError.packageManagerNotInstalled
        }

        do {
            // Clean existing files
            let pkgJson = packagePath.appending(path: "package.json")
            if FileManager.default.fileExists(atPath: pkgJson.path) {
                try FileManager.default.removeItem(at: pkgJson)
            }
            let pkgLockJson = packagePath.appending(path: "package-lock.json")
            if FileManager.default.fileExists(atPath: pkgLockJson.path) {
                try FileManager.default.removeItem(at: pkgLockJson)
            }

            // Init npm directory with .npmrc file
            try createDirectoryStructure(for: packagePath)
            _ = try await executeInDirectory(
                in: packagePath.path, ["npm init --yes --scope=codeedit"]
            )

            let npmrcPath = packagePath.appending(path: ".npmrc")
            if !FileManager.default.fileExists(atPath: npmrcPath.path) {
                try "install-strategy=shallow".write(to: npmrcPath, atomically: true, encoding: .utf8)
            }
        } catch {
            throw PackageManagerError.initializationFailed(error.localizedDescription)
        }
    }

    /// Install a package using the new installation method
    func install(method: InstallationMethod) async throws {
        guard case .standardPackage(let source) = method else {
            throw PackageManagerError.invalidConfiguration
        }

        let packagePath = installationDirectory.appending(path: source.entryName)
        try await initialize(in: packagePath)

        do {
            var installArgs = ["npm", "install", "\(source.pkgName)@\(source.version)"]
            if let dev = source.options["dev"], dev.lowercased() == "true" {
                installArgs.append("--save-dev")
            }
            if let extraPackages = source.options["extraPackages"]?.split(separator: ",") {
                for pkg in extraPackages {
                    installArgs.append(String(pkg).trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }

            _ = try await executeInDirectory(in: packagePath.path, installArgs)
            try verifyInstallation(folderName: source.entryName, package: source.pkgName, version: source.version)
        } catch {
            let nodeModulesPath = packagePath.appending(path: "node_modules").path
            try? FileManager.default.removeItem(atPath: nodeModulesPath)
            throw error
        }
    }

    /// Get the path to the binary
    func getBinaryPath(for package: String) -> String {
        let binDirectory = installationDirectory
            .appending(path: package)
            .appending(path: "node_modules")
            .appending(path: ".bin")
        return binDirectory.appending(path: package).path
    }

    /// Checks if npm is installed
    func isInstalled() async -> Bool {
        do {
            let versionOutput = try await runCommand("npm --version")
            let versionPattern = #"^\d+\.\d+\.\d+$"#
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return output.range(of: versionPattern, options: .regularExpression) != nil
        } catch {
            return false
        }
    }

    /// Verify the installation was successful
    private func verifyInstallation(folderName: String, package: String, version: String) throws {
        let packagePath = installationDirectory.appending(path: folderName)
        let packageJsonPath = packagePath.appending(path: "package.json").path

        // Verify package.json contains the installed package
        guard let packageJsonData = FileManager.default.contents(atPath: packageJsonPath),
              let packageJson = try? JSONSerialization.jsonObject(with: packageJsonData, options: []),
              let packageDict = packageJson as? [String: Any],
              let dependencies = packageDict["dependencies"] as? [String: String],
              let installedVersion = dependencies[package] else {
            throw PackageManagerError.installationFailed("Package not found in package.json")
        }

        // Verify installed version matches requested version
        let normalizedInstalledVersion = installedVersion.trimmingCharacters(in: CharacterSet(charactersIn: "^~"))
        let normalizedRequestedVersion = version.trimmingCharacters(in: CharacterSet(charactersIn: "^~"))
        if normalizedInstalledVersion != normalizedRequestedVersion &&
           !installedVersion.contains(normalizedRequestedVersion) {
            throw PackageManagerError.installationFailed(
                "Version mismatch: Expected \(version), but found \(installedVersion)"
            )
        }

        // Verify the package exists in node_modules
        let packageDirectory = packagePath
            .appending(path: "node_modules")
            .appending(path: package)
        guard FileManager.default.fileExists(atPath: packageDirectory.path) else {
            throw PackageManagerError.installationFailed("Package not found in node_modules")
        }
    }
}
