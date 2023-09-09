//
//  StatusBarToggleUtilityAreaButton.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarToggleUtilityAreaButton: View {
    @Environment(\.controlActiveState)
    var controlActiveState

    @EnvironmentObject private var model: UtilityAreaViewModel

    internal var body: some View {
        Button {
            model.togglePanel()
        } label: {
            Image(systemName: "square.bottomthird.inset.filled")
        }
        .buttonStyle(.icon)
        .keyboardShortcut("Y", modifiers: [.command, .shift])
        .help(model.isCollapsed ? "Show the Utility area" : "Hide the Utility area")
        .onHover { isHovering($0) }
        .onChange(of: controlActiveState) { newValue in
            if newValue == .key {
                CommandManager.shared.addCommand(
                    name: "Toggle Utility Area",
                    title: "Toggle Utility Area",
                    id: "open.drawer",
                    command: CommandClosureWrapper.init(closure: model.togglePanel)
                )
            }
        }
        .onAppear {
            CommandManager.shared.addCommand(
                name: "Toggle Utility Area",
                title: "Toggle Utility Area",
                id: "open.drawer",
                command: CommandClosureWrapper.init(closure: model.togglePanel)
            )
        }
    }
}
