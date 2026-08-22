//
//  RegistryItem.swift
//  CodeEdit
//
//  Created by Abe Malla on 1/29/25.
//

import Foundation

/// A `RegistryItem` represents an entry in the Registry that saves language servers, DAPs, linters and formatters.
public struct RegistryItem: Codable, Sendable {
    public let name: String
    public let description: String
    public let homepage: String
    public let licenses: [String]
    public let languages: [String]
    public let categories: [String]
    public let source: Source
    public let bin: [String: String]?

    public init(
        name: String,
        description: String,
        homepage: String,
        licenses: [String],
        languages: [String],
        categories: [String],
        source: Source,
        bin: [String: String]?
    ) {
        self.name = name
        self.description = description
        self.homepage = homepage
        self.licenses = licenses
        self.languages = languages
        self.categories = categories
        self.source = source
        self.bin = bin
    }

    public var sanitizedName: String {
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

    public var sanitizedDescription: String {
        description.replacingOccurrences(of: "\n", with: " ")
    }

    public var homepageURL: URL? {
        URL(string: homepage)
    }

    /// A pretty version of the homepage URL.
    /// Removes the schema (eg https) and leaves the path and domain.
    public var homepagePretty: String {
        guard let homepageURL else { return homepage }
        return (homepageURL.host(percentEncoded: false) ?? "") + homepageURL.path(percentEncoded: false)
    }

    /// Serializes back to JSON format
    public func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "ConversionError", code: 1)
        }
        return dictionary
    }
}
