//
//  KeybindingManaging.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 11/04/26.
//

import Foundation

/// Protocol for managing keyboard shortcuts.
protocol KeybindingManaging: AnyObject {
    var keyboardShortcuts: [String: KeyboardShortcutWrapper] { get }
    func addNewShortcut(shortcut: KeyboardShortcutWrapper, name: String)
    func named(with name: String) -> KeyboardShortcutWrapper
}
