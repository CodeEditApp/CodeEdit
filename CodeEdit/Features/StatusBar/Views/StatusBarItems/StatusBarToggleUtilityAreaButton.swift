//
//  StatusBarToggleUtilityAreaButton.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarToggleUtilityAreaButton: View {
    @Environment(\.controlActiveState)
    var controlActiveState

    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    internal var body: some View {
        Button {
            utilityAreaViewModel.togglePanel()
        } label: {
            Image(systemName: "square.bottomthird.inset.filled")
        }
        .buttonStyle(.icon)
        .keyboardShortcut("Y", modifiers: [.command, .shift])
        .help(utilityAreaViewModel.isCollapsed ? "Show the Utility area" : "Hide the Utility area")
        .onHover { isHovering($0) }
        .onChange(of: controlActiveState) { newValue in
            if newValue == .key {
                CommandManager.shared.addCommand(
                    name: "Toggle Utility Area",
                    title: "Toggle Utility Area",
                    id: "open.drawer",
                    command: { [weak utilityAreaViewModel] in utilityAreaViewModel?.togglePanel() }
                )
                CommandManager.shared.addCommand(
                    name: "Toggle Utility Area Without Animation",
                    title: "Toggle Utility Area Without Animation",
                    id: "open.drawer.no.animation",
                    command: { [weak utilityAreaViewModel] in utilityAreaViewModel?.togglePanel(animation: false) }
                )
            }
        }
        .onAppear {
            CommandManager.shared.addCommand(
                name: "Toggle Utility Area",
                title: "Toggle Utility Area",
                id: "open.drawer",
                command: { [weak utilityAreaViewModel] in utilityAreaViewModel?.togglePanel() }
            )
            CommandManager.shared.addCommand(
                name: "Toggle Utility Area Without Animation",
                title: "Toggle Utility Area Without Animation",
                id: "open.drawer.no.animation",
                command: { [weak utilityAreaViewModel] in utilityAreaViewModel?.togglePanel(animation: false) }
            )
        }
    }
}
