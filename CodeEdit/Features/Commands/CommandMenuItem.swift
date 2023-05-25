//
//  CommandMenuItem.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/24/23.
//

import SwiftUI

struct CommandMenuItem: View {
    @ObservedObject
    var commandManager: CommandManager = .shared

    var id: String
    var label: String?

    init(_ id: String, label: String?) {
        self.id = id
        self.label = label
    }

    var body: some View {
        Button(label ?? commandManager.get(id)?.label ?? "") {
            commandManager.execute(id)
        }
        .keyboardShortcut(commandManager.get(id)?.keyboardShortcut ?? nil)
    }
}
