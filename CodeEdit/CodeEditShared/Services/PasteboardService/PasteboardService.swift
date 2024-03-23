//
//  PasteboardService.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/20/24.
//

protocol PasteboardProvider {
    static func clear()
    static func string() -> String?
    static func setString(_ string: String)
    static func setStrings(_ strings: [String])
}

/// A service for interacting with the pasteboard
final class PasteboardService {
    private let pasteboard: PasteboardProvider.Type

    init() {
        // Initialize a provider based on platform
#if os(macOS)
        self.pasteboard = NSPasteboardProvider.self
#elseif os(iOS)
        self.pasteboard = UIPasteboardProvider.self
#endif
    }

    /// Clears the pasteboard
    func clear() {
        self.pasteboard.clear()
    }

    /// Copies a string to the pasteboard
    /// - Parameter string: The string to copy
    func copy(_ string: String) {
        self.pasteboard.setString(string)
    }

    /// Copies an array of strings to the pasteboard
    /// - Parameter strings: The strings to copy
    func copy(_ strings: [String]) {
        self.pasteboard.setStrings(strings)
    }

    /// Pastes a string from the pasteboard
    func paste() -> String? {
        self.pasteboard.string()
    }
}
