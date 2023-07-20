//
//  DebugAreaTerminalTab.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/26/23.
//

import SwiftUI

struct DebugAreaTerminalTab: View {
    @Binding var terminal: DebugAreaTerminal

    var removeTerminals: (_ ids: Set<UUID>) -> Void

    var isSelected: Bool

    var selectedIDs: Set<UUID>

    @FocusState private var isFocused: Bool

    var body: some View {
        let terminalTitle = Binding<String>(
            get: {
                self.terminal.title
            }, set: {
                if $0.trimmingCharacters(in: .whitespaces) == "" && !isFocused {
                    self.terminal.title = self.terminal.terminalTitle
                    self.terminal.customTitle = false
                } else {
                    self.terminal.title = $0
                    self.terminal.customTitle = true
                }
            }
        )

        Label {
            TextField("Name", text: terminalTitle)
                .focused($isFocused)
                .padding(.leading, -8)
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
        }
    }
}
