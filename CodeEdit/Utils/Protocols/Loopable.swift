//
//  Loopable.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 03.04.22.
//

import Foundation

/// Loopable protocol implements a method that will return all child
/// Properties and their associated values of a `Type`
protocol Loopable {
    func allProperties() throws -> [String: Any]
}

extension Loopable {

    /// Returns all child properties and their associated values of `self`
    ///
    /// **Example:**
    /// ```swift
    /// Struct Author: Loopable {
    ///   var name: String = "Steve"
    ///   var books: Int = 4
    /// }
    ///
    /// Let author = Author()
    /// Print(author.allProperties())
    ///
    /// // Returns
    /// ["name": "Steve", "books": 4]
    /// ```
    func allProperties() throws -> [String: Any] {
        var result: [String: Any] = [:]

        let mirror = Mirror(reflecting: self)

        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            // TODO: Throw a proper error
            throw NSError() // Swiftlint:disable:this discouraged_direct_init
        }

        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }

            result[property] = value
        }

        return result
    }
}
