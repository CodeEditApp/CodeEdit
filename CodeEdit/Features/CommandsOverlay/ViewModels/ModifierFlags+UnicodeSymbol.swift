//
//  ModifierFlags+UnicodeSymbol.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/05/2023.
//

import AppKit

extension NSEvent.ModifierFlags {
    var unicodeSymbol: String {
        var symbols: [String] = []

        if self.contains(.command) {
            symbols.append("⌘") // Command symbol
        }

        if self.contains(.control) {
            symbols.append("⌃") // Control symbol
        }

        if self.contains(.option) {
            symbols.append("⌥") // Option symbol
        }

        if self.contains(.shift) {
            symbols.append("⇧") // Shift symbol
        }

        if self.contains(.function) {
            symbols.append("fn") // Function symbol
        }

        return symbols.joined()
    }
}
