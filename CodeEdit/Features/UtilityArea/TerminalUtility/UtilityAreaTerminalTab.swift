//
//  UtilityAreaTerminalTab.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/26/23.
//

import SwiftUI

struct UtilityAreaTerminalTab: View {

    @ObservedObject var group: TerminalGroup

    let onRemoveTerminal: ([TerminalEmulator]) -> Void

    init(group: TerminalGroup, onRemoveTerminal: @escaping ([TerminalEmulator]) -> Void) {
        self.group = group
        self.onRemoveTerminal = onRemoveTerminal
    }

    var body: some View {
        Group {
            if group.children.count == 1 {
                TerminalItem(terminal: group.children[0], onKill: onRemoveTerminal)
                    .tag(UtilityAreaTerminalSelection.terminal(group.children[0]))
                    .dropDestination(for: TerminalEmulator.self) { items, _ in
                        onRemoveTerminal(items)
                        for terminal in items {
                            terminal.move(to: group)
                        }
                        return true
                    }
                    .id(group.children[0])
            } else {
                DisclosureGroup(isExpanded: $group.isExpanded) {
                    ForEach(group.children) { terminal in
                        TerminalItem(terminal: terminal, onKill: onRemoveTerminal)
                            .tag(UtilityAreaTerminalSelection.terminal(terminal))
                    }
                    .onMove { indices, destination in
                        group.children.move(fromOffsets: indices, toOffset: destination)
                    }
                } label: {
                    TerminalGroupItem(group: group, onKill: onRemoveTerminal)
                        .tag(UtilityAreaTerminalSelection.group(group))
                        .dropDestination(for: TerminalGroup.self) { items, _ in
                            let terminals = items.flatMap(\.children)
                            onRemoveTerminal(terminals)
                            for terminal in terminals {
                                terminal.move(to: group)
                            }
                            return true
                        }
                }
            }
        }
    }
}

private struct TerminalItem: View {
    @ObservedObject var terminal: TerminalEmulator
    let onKill: ([TerminalEmulator]) -> Void

    @FocusState private var isRenaming: Bool

    private func kill() {
        onKill([terminal])
    }

    var body: some View {
        let title = Binding<String> {
            terminal.title
        } set: {
            let result = $0.trimmingCharacters(in: .whitespaces)
            if result.isEmpty {
                terminal.customTitle = nil
            } else {
                terminal.customTitle = result
            }
        }
        Label {
            if #available(macOS 14, *) {
                // Fix the icon misplacement issue introduced since macOS 14
                TextField("Name", text: title)
                    .focused($isRenaming)
            } else {
                // A padding is needed for macOS 13
                TextField("Name", text: title)
                    .focused($isRenaming)
                    .padding(.leading, -8)
            }
        } icon: {
            Image(systemName: "terminal")
        }
        .draggable(terminal)
        .contextMenu {
            Button("Rename...") {
                isRenaming = true
            }
            Button("Kill", role: .destructive, action: kill)
        }
    }
}

private struct TerminalGroupItem: View {
    @ObservedObject var group: TerminalGroup
    let onKill: ([TerminalEmulator]) -> Void

    @FocusState private var isRenaming: Bool

    private func kill() {
        onKill(group.children)
    }

    var body: some View {
        let title = Binding<String> {
            group.title
        } set: {
            let result = $0.trimmingCharacters(in: .whitespaces)
            group.customTitle = result.isEmpty ? nil : result
        }
        Label {
            if #available(macOS 14, *) {
                // Fix the icon misplacement issue introduced since macOS 14
                TextField("Name", text: title)
                    .focused($isRenaming)
            } else {
                // A padding is needed for macOS 13
                TextField("Name", text: title)
                    .focused($isRenaming)
                    .padding(.leading, -8)
            }
        } icon: {
            Image(systemName: "rectangle.split.2x1")
        }
        .contextMenu {
            Button("Rename...") {
                isRenaming = true
            }
            Button("Kill All", role: .destructive, action: kill)
        }
    }
}
