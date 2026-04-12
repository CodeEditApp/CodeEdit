//
//  RegistryItem+AppExtensions.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 12/04/26.
//

import Foundation
import CodeEditDomain

extension RegistryItem: FuzzySearchable {
    var searchableString: String { name }
}

extension RegistryItem {
    /// The method for installation, parsed from this item's ``source`` parameter.
    var installMethod: InstallationMethod? {
        let sourceId = source.id
        if sourceId.hasPrefix("pkg:cargo/") {
            return PackageSourceParser.parseCargoPackage(self)
        } else if sourceId.hasPrefix("pkg:npm/") {
            return PackageSourceParser.parseNpmPackage(self)
        } else if sourceId.hasPrefix("pkg:pypi/") {
            return PackageSourceParser.parsePythonPackage(self)
        } else if sourceId.hasPrefix("pkg:gem/") {
            return PackageSourceParser.parseRubyGem(self)
        } else if sourceId.hasPrefix("pkg:golang/") {
            return PackageSourceParser.parseGolangPackage(self)
        } else if sourceId.hasPrefix("pkg:github/") {
            return PackageSourceParser.parseGithubPackage(self)
        } else {
            return nil
        }
    }
}
