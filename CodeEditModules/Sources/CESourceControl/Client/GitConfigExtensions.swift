//
//  GitConfigExtensions.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/16/24.
//

import Foundation

/// Conformance of `Bool` to `GitConfigRepresentable`
///
/// This enables `Bool` values to be represented in Git configuration as
/// `true` or `false`.
extension Bool: GitConfigRepresentable {
    public init?(configValue: String) {
        switch configValue.lowercased() {
        case "true": self = true
        case "false": self = false
        default: return nil
        }
    }

    public var asConfigValue: String {
        self ? "true" : "false"
    }
}

/// Conformance of `String` to `GitConfigRepresentable`
///
/// This enables `String` values to be represented in Git configuration,
/// automatically escaping them with quotes.
extension String: GitConfigRepresentable {
    public init?(configValue: String) {
        self = configValue
    }

    public var asConfigValue: String {
        "\"\(self)\""
    }
}
