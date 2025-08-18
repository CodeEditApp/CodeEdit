//
//  InstallationMethod.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/12/25.
//

import Foundation

/// Installation method enum with all supported types
enum InstallationMethod: Equatable {
    /// For standard package manager installations
    case standardPackage(source: PackageSource)
    /// For packages that need to be built from source with custom build steps
    case sourceBuild(source: PackageSource, command: String)
    /// For direct binary downloads
    case binaryDownload(source: PackageSource, url: URL)
    /// For installations that aren't recognized
    case unknown

    var packageName: String? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.pkgName
        case .unknown:
            return nil
        }
    }

    var version: String? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.version
        case .unknown:
            return nil
        }
    }

    var packageManagerType: PackageManagerType? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.type
        case .unknown:
            return nil
        }
    }

    func packageManager(installPath: URL) -> PackageManagerProtocol? {
        switch packageManagerType {
        case .npm:
            return NPMPackageManager(installationDirectory: installPath)
        case .cargo:
            return CargoPackageManager(installationDirectory: installPath)
        case .pip:
            return PipPackageManager(installationDirectory: installPath)
        case .golang:
            return GolangPackageManager(installationDirectory: installPath)
        case .github, .sourceBuild:
            return GithubPackageManager(installationDirectory: installPath)
        case .nuget, .opam, .gem, .composer:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        default:
            return nil
        }
    }

    var installerDescription: String {
        guard let packageManagerType else { return "Unknown" }
        switch packageManagerType {
        case .npm, .cargo, .golang, .pip, .sourceBuild, .github:
            return packageManagerType.userDescription
        case .nuget, .opam, .gem, .composer:
            return "(Unsupported) \(packageManagerType.userDescription)"
        }
    }

    var packageDescription: String? {
        guard let packageName else { return nil }
        if let version {
            return "\(packageName)@\(version)"
        }
        return packageName
    }
}
