//
//  PackageSource.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/18/25.
//

/// Generic package source information that applies to all installation methods.
/// Takes all the necessary information from `RegistryItem`.
struct PackageSource: Equatable, Codable {
    /// The raw source ID string from the registry
    let sourceId: String
    /// The type of the package manager
    let type: PackageManagerType
    /// Package name
    let pkgName: String
    /// The name in the registry.json file. Used for the folder name when saved.
    let entryName: String
    /// Package version
    let version: String
    /// URL for repository or download link
    let repositoryUrl: String?
    /// Git reference type if this is a git based package
    let gitReference: GitReference?
    /// Additional possible options
    var options: [String: String]

    init(
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

    enum GitReference: Equatable, Codable {
        case tag(String)
        case revision(String)
    }
}
