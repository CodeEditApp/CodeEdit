//
//  NPMPackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

final class NPMPackageManager: PackageManagerProtocol {
    private let installationDirectory: URL

    let shellClient: ShellClient

    init(installationDirectory: URL) {
        self.installationDirectory = installationDirectory
        self.shellClient = .live()
    }

    func install(method installationMethod: InstallationMethod) throws -> [PackageManagerInstallStep] {
        guard case .standardPackage(let source) = installationMethod else {
            throw PackageManagerError.invalidConfiguration
        }

        let packagePath = installationDirectory.appending(path: source.entryName)
        return [
            initialize(in: packagePath),
            runNpmInstall(source, in: installationDirectory),
            verifyInstallation(source, installDir: installationDirectory)
        ]


    }

    // MARK: - Is Installed

    /// Checks if npm is installed
    func isInstalled(method installationMethod: InstallationMethod) -> PackageManagerInstallStep {
        PackageManagerInstallStep(
            name: "",
            confirmation: .required(
                message: "This package requires npm to install. Allow CodeEdit to run npm commands?"
            )
        ) { model in
            let versionOutput = try await model.runCommand("npm --version")
            let versionPattern = #"^\d+\.\d+\.\d+$"#
            let output = versionOutput.reduce(into: "") {
                $0 += $1.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            guard output.range(of: versionPattern, options: .regularExpression) != nil else {
                throw PackageManagerError.packageManagerNotInstalled
            }
        }
    }

    // MARK: - Initialize

    /// Initializes the npm project if not already initialized
    func initialize(in packagePath: URL) -> PackageManagerInstallStep {
        PackageManagerInstallStep(name: "Initialize Directory Structure", confirmation: .none) { model in
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
            try await model.createDirectoryStructure(for: packagePath)
            _ = try await model.executeInDirectory(
                in: packagePath.path, ["npm init --yes --scope=codeedit"]
            )

            let npmrcPath = packagePath.appending(path: ".npmrc")
            if !FileManager.default.fileExists(atPath: npmrcPath.path) {
                try "install-strategy=shallow".write(to: npmrcPath, atomically: true, encoding: .utf8)
            }
        }
    }

    func runNpmInstall(_ source: PackageSource, in packagePath: URL) -> PackageManagerInstallStep {
        PackageManagerInstallStep(
            name: "Install Package Using npm",
            // TODO: Confirm
            confirmation: .required(message: "")
        ) { model in
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

                _ = try await model.executeInDirectory(in: packagePath.path, installArgs)
            } catch {
                let nodeModulesPath = packagePath.appending(path: "node_modules").path
                try? FileManager.default.removeItem(atPath: nodeModulesPath)
                throw error
            }
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

    /// Verify the installation was successful
    private func verifyInstallation(
        _ source: PackageSource,
        installDir installationDirectory: URL
    ) -> PackageManagerInstallStep {
        let folderName = source.entryName
        let package = source.pkgName
        let version = source.version

        return PackageManagerInstallStep(
            name: "Verify Installation",
            confirmation: .none
        ) { model in
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
}
