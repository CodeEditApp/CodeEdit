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

    @Binding var collapsed: Bool

    init(collapsed: Binding<Bool>) {
        self._collapsed = collapsed
        CommandManager.shared.addCommand(
            name: "Toggle Drawer",
            title: "Toggle Drawer",
            id: "open.drawer",
            command: CommandClosureWrapper.init(closure: togglePanel)
        )
    }

    func togglePanel() {
        withAnimation {
            model.isExpanded.toggle()
            collapsed.toggle()
        }
        self.model.saveIsExpandedToState()
    }

    internal var body: some View {
        Button {
            togglePanel()
            // Show/hide terminal window
        } label: {
            Image(systemName: "rectangle.bottomthird.inset.filled")
                .imageScale(.medium)
        }
        .tint(collapsed ? .primary : .accentColor)
        .keyboardShortcut("Y", modifiers: [.command, .shift])
        .buttonStyle(.borderless)
        .onHover { isHovering($0) }
    }
}
