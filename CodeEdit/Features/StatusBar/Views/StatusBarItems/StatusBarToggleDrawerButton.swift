//
//  StatusBarToggleDrawerButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarToggleDrawerButton: View {
    @EnvironmentObject private var model: DebugAreaViewModel

    init() {
        CommandManager.shared.addCommand(
            name: "Toggle Drawer",
            title: "Toggle Drawer",
            id: "open.drawer",
            command: CommandClosureWrapper.init(closure: togglePanel)
        )
    }

    func togglePanel() {
        withAnimation {
            model.isCollapsed.toggle()
        }
    }

    internal var body: some View {
        Button {
            togglePanel()
        } label: {
            Image(systemName: "square.bottomthird.inset.filled")
        }
        .buttonStyle(.icon)
        .keyboardShortcut("Y", modifiers: [.command, .shift])
        .onHover { isHovering($0) }
    }
}
