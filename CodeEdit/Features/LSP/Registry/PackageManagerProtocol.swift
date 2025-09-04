//
//  PackageManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

/// The protocol each package manager conforms to for creating ``PackageManagerInstallOperation``s.
protocol PackageManagerProtocol {
    var shellClient: ShellClient { get }

    /// Calls the shell commands to install a package
    func install(method installationMethod: InstallationMethod) throws -> [PackageManagerInstallStep]
    /// Gets the location of the binary that was installed
    func getBinaryPath(for package: String) -> String
    /// Checks if the shell commands for the package manager are available or not
    func isInstalled(method installationMethod: InstallationMethod) -> PackageManagerInstallStep
}
