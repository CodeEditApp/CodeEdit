//
//  InstallationMethod.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/12/25.
//

import Foundation

/// Installation method enum with all supported types
public enum InstallationMethod: Equatable {
    /// For standard package manager installations
    case standardPackage(source: PackageSource)
    /// For packages that need to be built from source with custom build steps
    case sourceBuild(source: PackageSource, command: String)
    /// For direct binary downloads
    case binaryDownload(source: PackageSource, url: URL)
    /// For installations that aren't recognized
    case unknown

    public var packageName: String? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.pkgName
        case .unknown:
            return nil
        }
    }

    public var version: String? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.version
        case .unknown:
            return nil
        }
    }

    public var packageManagerType: PackageManagerType? {
        switch self {
        case .standardPackage(let source),
             .sourceBuild(let source, _),
             .binaryDownload(let source, _):
            return source.type
        case .unknown:
            return nil
        }
    }

    public var installerDescription: String {
        guard let packageManagerType else { return "Unknown" }
        switch packageManagerType {
        case .npm, .cargo, .golang, .pip, .sourceBuild, .github:
            return packageManagerType.userDescription
        case .nuget, .opam, .gem, .composer:
            return "(Unsupported) \(packageManagerType.userDescription)"
        }
    }

    public var packageDescription: String? {
        guard let packageName else { return nil }
        if let version {
            return "\(packageName)@\(version)"
        }
        return packageName
    }
}
