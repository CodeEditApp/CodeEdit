//
//  DebugAreaTerminalTab.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/26/23.
//

import SwiftUI

struct DebugAreaTerminalTab: View {
    @Binding
    var terminal: DebugAreaTerminal

    var removeTerminals: (_ ids: Set<UUID>) -> Void

    var isSelected: Bool

    var selectedIDs: Set<UUID>

    @FocusState
    private var isFocused: Bool

    var body: some View {
        Label {
            TextField("Name", text: $terminal.title)
                .focused($isFocused)
                .padding(.leading, -8)
                .background {
                    if isSelected {
                        Button("Kill Terminal") {
                            removeTerminals(selectedIDs)
                        }
                        .keyboardShortcut(.delete, modifiers: [.command])
                        .frame(width: 0, height: 0)
                        .clipped()
                        .opacity(0)
                    }
                }
        } icon: {
            Image(systemName: "terminal")
        }
        .contextMenu {
            Button("Rename...") {
                isFocused = true
            }
            Button("Kill Terminal") {
                if isSelected { removeTerminals([terminal.id]) }
            }
            .keyboardShortcut(.delete, modifiers: [.command])
        }
    }
}
