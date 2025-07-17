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
}
