//
//  StatusBarClearButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Stef Kors on 12/04/2022.
//

import SwiftUI

struct StatusBarClearButton: View {
    @EnvironmentObject private var model: DebugAreaViewModel

    var body: some View {
        Button {
            model.terminals.forEach {
                if model.selectedTerminals.contains($0.id) {
                    $0.terminalEmulatorView.terminal.send(txt: "clear\n")
                }
            }
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .help("Clear terminal")
        .keyboardShortcut("k")
    }
}
