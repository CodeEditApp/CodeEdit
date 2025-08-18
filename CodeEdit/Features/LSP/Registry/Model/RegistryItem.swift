//
//  RegistryItem.swift
//  CodeEdit
//
//  Created by Abe Malla on 1/29/25.
//

import Foundation

/// A `RegistryItem` represents an entry in the Registry that saves language servers, DAPs, linters and formatters.
struct RegistryItem: Codable {
    let name: String
    let description: String
    let homepage: String
    let licenses: [String]
    let languages: [String]
    let categories: [String]
    let source: Source
    let bin: [String: String]?

    var sanitizedName: String {
        name.replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { word -> String in
                let str = String(word).lowercased()
                // Check for special cases
                if str == "ls" || str == "lsp" || str == "ci" || str == "cli" {
                    return str.uppercased()
                }
                return str.capitalized
            }
            .joined(separator: " ")
    }

    var sanitizedDescription: String {
        description.replacingOccurrences(of: "\n", with: " ")
    }

    var homepageURL: URL? {
        URL(string: homepage)
    }

    /// A pretty version of the homepage URL.
    /// Removes the schema (eg https) and leaves the path and domain.
    var homepagePretty: String {
        guard let homepageURL else { return homepage }
        return (homepageURL.host(percentEncoded: false) ?? "") + homepageURL.path(percentEncoded: false)
    }

    /// The method for installation, parsed from this item's ``source-swift.property`` parameter.
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

    /// Serializes back to JSON format
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "ConversionError", code: 1)
        }
        return dictionary
    }
}

extension RegistryItem: FuzzySearchable {
    var searchableString: String { name }
}
