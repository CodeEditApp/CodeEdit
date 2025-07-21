//
//  TerminalCache.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/27/24.
//

import Foundation
import SwiftTerm

/// Stores a mapping of ID -> terminal view for reusing terminal views.
/// This allows terminal views to continue to receive data even when not in the view hierarchy.
final class TerminalCache {
    static let shared: TerminalCache = TerminalCache()

    /// The cache of terminal views.
    private var terminals: [UUID: CELocalShellTerminalView]

    private init() {
        terminals = [:]
    }

    /// Get a cached terminal view.
    /// - Parameter id: The ID of the terminal.
    /// - Returns: The existing terminal, if it exists.
    func getTerminalView(_ id: UUID) -> CELocalShellTerminalView? {
        terminals[id]
    }

    /// Store a terminal view for reuse.
    /// - Parameters:
    ///   - id: The ID of the terminal.
    ///   - view: The view representing the terminal's contents.
    func cacheTerminalView(for id: UUID, view: CELocalShellTerminalView) {
        terminals[id] = view
    }

    /// Remove any view associated with the terminal id.
    /// - Parameter id: The ID of the terminal.
    func removeCachedView(_ id: UUID) {
        terminals[id] = nil
    }
}
