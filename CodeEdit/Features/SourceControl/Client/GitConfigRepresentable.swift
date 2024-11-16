//
//  GitConfigRepresentable.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/16/24.
//

/// A protocol that provides a mechanism to represent and parse Git configuration values.
///
/// Conforming types must be able to initialize from a Git configuration string
/// and convert their value back to a Git-compatible string representation.
protocol GitConfigRepresentable {
    /// Initializes a new instance from a Git configuration value string.
    /// - Parameter configValue: The configuration value string.
    init?(configValue: String)

    /// Converts the value to a Git-compatible configuration string.
    var asConfigValue: String { get }
}
