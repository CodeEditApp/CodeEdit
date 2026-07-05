//
//  FindNavigatorConfiguration.swift
//  Search
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import Foundation

/// Layout preferences supplied by the app (derived from Settings, which the
/// Search package cannot import).
public struct FindNavigatorConfiguration: Equatable, Sendable {
    /// Row height for file rows and minimum height for match rows.
    public var rowHeight: Double
    /// Maximum number of preview lines for a match row.
    public var matchDetailLineLimit: Int

    public init(rowHeight: Double, matchDetailLineLimit: Int) {
        self.rowHeight = rowHeight
        self.matchDetailLineLimit = matchDetailLineLimit
    }
}
