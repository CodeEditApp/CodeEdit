//
//  PackageSource.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/18/25.
//

/// Generic package source information that applies to all installation methods.
/// Takes all the necessary information from `RegistryItem`.
public struct PackageSource: Equatable, Codable {
    /// The raw source ID string from the registry
    public let sourceId: String
    /// The type of the package manager
    public let type: PackageManagerType
    /// Package name
    public let pkgName: String
    /// The name in the registry.json file. Used for the folder name when saved.
    public let entryName: String
    /// Package version
    public let version: String
    /// URL for repository or download link
    public let repositoryUrl: String?
    /// Git reference type if this is a git based package
    public let gitReference: GitReference?
    /// Additional possible options
    public var options: [String: String]

    public init(
        sourceId: String,
        type: PackageManagerType,
        pkgName: String,
        entryName: String,
        version: String,
        repositoryUrl: String? = nil,
        gitReference: GitReference? = nil,
        options: [String: String] = [:]
    ) {
        self.sourceId = sourceId
        self.type = type
        self.pkgName = pkgName
        self.entryName = entryName
        self.version = version
        self.repositoryUrl = repositoryUrl
        self.gitReference = gitReference
        self.options = options
    }

    public enum GitReference: Equatable, Codable {
        case tag(String)
        case revision(String)
    }
}
