//
//  KeyboardShortcutManager.swift
//  CodeEdit
//
//  Created by Alexander Sinelnikov on 24.04.2022.
//

import SwiftUI

public final class KeyboardShortcutManager {
    init() {
        self.keyboardShortcuts = ["recentProjectsViewCopyPath":
                                    KeyboardShortcutWrapper(keyboardShortcut: KeyboardShortcut.init("C",
                                                                                               modifiers: [.command]),
                                                            name: "Copy Path",
                                                            context: "recentProjects")]
    }

    static public let shared = KeyboardShortcutManager()

    // We need this fallback shortcut because optional shortcuts available only from 12.3, while we have target of 12.0x
    var fallbackShortcut = KeyboardShortcutWrapper(keyboardShortcut: .init("?", modifiers: [.command, .shift]),
                                                   name: "Fallback",
                                                   context: "Fallback")

    public var keyboardShortcuts: [String: KeyboardShortcutWrapper]

    public func addNewShortcut(shortcut: KeyboardShortcutWrapper, name: String) {
        KeyboardShortcutManager.shared.keyboardShortcuts[name] = (shortcut)
    }

    public func named(with name: String) -> KeyboardShortcutWrapper {
        let foundElement = keyboardShortcuts[name]
        return foundElement != nil ? foundElement! : fallbackShortcut
    }

}

public struct KeyboardShortcutWrapper {
    public var keyboardShortcut: KeyboardShortcut
    var name: String
    var description: String?
    var context: String
}
