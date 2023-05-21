//
//  MenuBarCommandsManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/05/2023.
//

import AppKit
import Combine

struct CodeEditCommand: Hashable, Identifiable, CustomDebugStringConvertible {

    let subItems: [CodeEditCommand]?

    let title: String

    let shortcut: String?

    let keyPath: KeyPath<NSMenu, NSMenuItem>

    var id: String {
        title
    }

    var menuItem: NSMenuItem {
        NSApp.mainMenu![keyPath: keyPath]
    }

    var debugDescription: String {
        if let subItems {
            return """
        Item: \(title)
            Children: \(subItems.debugDescription)
        """
        } else {
            return "Item: \(title)"
        }
    }

    init(_ keyPath: KeyPath<NSMenu, NSMenuItem>) {
        let menuItem = NSApp.mainMenu![keyPath: keyPath]
        self.keyPath = keyPath

        if let items = menuItem.submenu?.items {
            self.subItems = items
                .enumerated()
                .filter { !$1.isSeparatorItem }
                .map { index, _ in
                    CodeEditCommand(keyPath.appending(path: \.submenu!.items[index]))
                }
        } else {
            self.subItems = nil
        }

        self.title = menuItem.title

        if !menuItem.keyEquivalent.isEmpty {
            self.shortcut = menuItem.keyEquivalentModifierMask.unicodeSymbol + menuItem.keyEquivalent.uppercased()
        } else {
            self.shortcut = nil
        }
    }

    func runAction() {
        let menuItem = menuItem
        if let action = menuItem.action {
            NSApp.sendAction(action, to: menuItem.representedObject, from: nil)
        }
    }

    func matchingFilter(_ filter: String) -> [CodeEditCommand] {
        var commands: [CodeEditCommand] = []

        if filter.isEmpty || self.title.lowercased().contains(filter.lowercased()) {
            commands.append(self)
        }

        if let subItems {
            commands.append(contentsOf: subItems.map { $0.matchingFilter(filter) }.reduce([], +))
        }

        return commands
    }
}
