//
//  CursorLocation.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 11.05.22.
//

import Foundation

/// The location (line, column) of the cursor in the editor view
///
/// - Note: Not yet implemented
public struct CursorLocation {
    /// The current line the cursor is located at.
    public var line: Int
    /// The current column the cursor is located at.
    public var column: Int
}
