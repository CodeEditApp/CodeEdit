//
//  StatusBarToggleDrawerButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarToggleDrawerButton: View {
    @EnvironmentObject
    private var model: StatusBarViewModel

    let commandManager = CommandManager.shared

    var collapsed: Bool

    var toggleVisibility: () -> Void

    internal var body: some View {
        Button {
            commandManager.execute("workspace.toggle.debug.area")
        } label: {
            Image(systemName: "square.bottomthird.inset.filled")
        }
        .buttonStyle(.icon)
        .keyboardShortcut("Y", modifiers: [.command, .shift])
        .onHover { isHovering($0) }
    }
}
