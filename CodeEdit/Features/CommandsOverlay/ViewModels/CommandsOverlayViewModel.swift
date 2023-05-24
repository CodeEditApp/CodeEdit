//
//  CommandsOverlayViewModel.swift
//  CodeEdit
//
//  Created by Alex on 25.05.2022.
//

import Combine
import SwiftUI

/// Simple state class for commands overlay view. Contains currently selected command,
/// query text and list of filtered commands
final class CommandsOverlayViewModel: ObservableObject {

    @Published
    var commandQuery: String = ""

    @Published
    var filteredMenuCommands: [CodeEditCommand] = []

    var menubarWatcher: AnyCancellable?

    var commands: [CodeEditCommand] = []

    var watchers: [AnyCancellable] = []

    /// Identifiers of menubar items that are excluded
    static var excludedIdentifiers: [NSUserInterfaceItemIdentifier] = [
        .init("makeKeyAndOrderFront:"), // Window list
        .init("orderFrontCharacterPalette:") // Emoji's & Symbols
    ]

    /// Titles of menubar items that are excluded
    static var excludedTitles: [String] = [
        "OpenWindowAction",
        "Services",
    ]

    init() {
        if let menu = NSApp.mainMenu {
            menubarWatcher = Publishers.MergeMany(
                NotificationCenter.default.publisher(for: NSMenu.didChangeItemNotification, object: menu),
                NotificationCenter.default.publisher(for: NSMenu.didAddItemNotification, object: menu),
                NotificationCenter.default.publisher(for: NSMenu.didRemoveItemNotification, object: menu)
            )
            .sink { [weak self] _ in
                self?.updateMenuBarCommands()
            }
        }

        updateMenuBarCommands()
    }

    func reset() {
        commandQuery = ""
    }

    func updateMenuBarCommands() {
        commands = Self.aggregateAllMenuBarCommands()

        watchers = commands
            .compactMap { item in
                if let menu: NSMenu = item.menuItem?.submenu {
                    return Publishers.MergeMany(
                        NotificationCenter.default.publisher(for: NSMenu.didChangeItemNotification, object: menu),
                        NotificationCenter.default.publisher(for: NSMenu.didAddItemNotification, object: menu),
                        NotificationCenter.default.publisher(for: NSMenu.didRemoveItemNotification, object: menu)
                    )
                    .throttle(for: .seconds(1), scheduler: RunLoop.main, latest: true)
                    .sink { [weak self] _ in
                        self?.updateMenuBarCommands()
                    }
                }
                return nil
            }
    }

    static func aggregateAllMenuBarCommands() -> [CodeEditCommand] {
        if let mainMenu = NSApp.mainMenu {
            return mainMenu
                .items
                .compactMap { CodeEditCommand(\.items[match: \.title, to: $0.title])?.nestedCommands }
                .reduce([], +)
        }
        return []
    }

    func fetchMatchingCommands(filter: String) {
        if filter.isEmpty {
            filteredMenuCommands = commands
            return
        }

        filteredMenuCommands = commands.filter { $0.matchingFilter(filter) }
    }
}
