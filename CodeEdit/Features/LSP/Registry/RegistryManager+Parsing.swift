//
//  RegistryManager+Parsing.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/14/25.
//

import Foundation

extension RegistryManager {
    /// Parse a registry entry and create the appropriate installation method
    internal static func parseRegistryEntry(_ entry: RegistryItem) -> InstallationMethod {
        let sourceId = entry.source.id
        if sourceId.hasPrefix("pkg:cargo/") {
            return PackageSourceParser.parseCargoPackage(entry)
        } else if sourceId.hasPrefix("pkg:npm/") {
            return PackageSourceParser.parseNpmPackage(entry)
        } else if sourceId.hasPrefix("pkg:pypi/") {
            return PackageSourceParser.parsePythonPackage(entry)
        } else if sourceId.hasPrefix("pkg:gem/") {
            return PackageSourceParser.parseRubyGem(entry)
        } else if sourceId.hasPrefix("pkg:golang/") {
            return PackageSourceParser.parseGolangPackage(entry)
        } else if sourceId.hasPrefix("pkg:github/") {
            return PackageSourceParser.parseGithubPackage(entry)
        } else {
            return .unknown
        }
    }
}
