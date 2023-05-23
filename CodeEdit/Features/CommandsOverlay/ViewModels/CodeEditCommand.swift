//
//  MenuBarCommandsManager.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 21/05/2023.
//

import AppKit
import Combine

extension [NSMenuItem] {
    subscript<T: Equatable>(match path: KeyPath<NSMenuItem, T>, to value: T) -> NSMenuItem? {
        first { $0[keyPath: path] == value }
    }
}

struct CodeEditCommand: Hashable, Identifiable, CustomDebugStringConvertible {

    let subItems: [CodeEditCommand]?

    let title: String

    let shortcut: String?

    let keyPath: KeyPath<NSMenu, NSMenuItem?>

    var id: String {
        title
    }

    var menuItem: NSMenuItem? {
        NSApp.mainMenu![keyPath: keyPath]
    }

    var isEnabled: Bool {
        menuItem?.isEnabled ?? false
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

    init?(_ keyPath: KeyPath<NSMenu, NSMenuItem?>) {
        guard let menuItem = NSApp.mainMenu![keyPath: keyPath] else {
            return nil
        }
        self.keyPath = keyPath

        if let items = menuItem.submenu?.items {
            self.subItems = items
                .filter { !$0.isSeparatorItem }
                .compactMap {
                    CodeEditCommand(keyPath.appending(path: \.?.submenu?.items[match: \.title, to: $0.title]))
                }
        } else {
            self.subItems = nil
        }

        self.title = menuItem.title

        if !menuItem.keyEquivalent.isEmpty {
            self.shortcut = menuItem.keyEquivalentModifierMask.unicodeSymbol + " " + menuItem.keyEquivalent.uppercased()
        } else {
            self.shortcut = nil
        }
    }

    func runAction() {
        if let menuItem = menuItem {
            if let action = menuItem.action {
                NSApp.sendAction(action, to: menuItem.representedObject, from: nil)
            }
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
