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

    var subItems: [CodeEditCommand]?

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

    var isTopLevel: Bool {
        menuItem?.menu == NSApp.mainMenu
    }

    var isMenu: Bool {
        menuItem?.hasSubmenu ?? false
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
        guard let menuItem = NSApp.mainMenu![keyPath: keyPath],
              !CommandsOverlayViewModel.excludedTitles.contains(menuItem.title) else {
            return nil
        }
        if let id = menuItem.identifier, CommandsOverlayViewModel.excludedIdentifiers.contains(id) {
            return nil
        }
        
        self.keyPath = keyPath

        self.title = menuItem.title

        if !menuItem.keyEquivalent.isEmpty {
            self.shortcut = menuItem.keyEquivalentModifierMask.unicodeSymbol + " " + menuItem.keyEquivalent.uppercased()
        } else {
            self.shortcut = nil
        }

        updateSubmenus()
    }

    func runAction() {
        if let menuItem = menuItem {
            if let action = menuItem.action {
                NSApp.sendAction(action, to: menuItem.representedObject, from: nil)
            }
        }
    }

    var nestedCommands: [CodeEditCommand] {
        [self] + (subItems?.flatMap(\.nestedCommands) ?? [])
    }

    /// All submenus present in this NSMenu nested tree
    var nestedSubmenus: [NSMenu] {
        var menus = subItems?.flatMap(\.nestedSubmenus) ?? []
        if let menu = menuItem?.menu {
            menus.append(menu)
        }
        return menus
    }

    func matchingFilter(_ filter: String) -> Bool {
        self.title.lowercased().contains(filter.lowercased())
    }

    mutating func updateSubmenus() {
        self.subItems = menuItem?.submenu?.items
            .filter { !$0.isSeparatorItem }
            .compactMap {
                CodeEditCommand(keyPath.appending(path: \.?.submenu?.items[match: \.title, to: $0.title]))
            }
    }
}
