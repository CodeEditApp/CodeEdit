//
//  NewGroupDropDelegate.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 30/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// Drop delegate responsible for handling the case when a terminal is dropped
/// outside of any existing group — i.e., it should create a new group with the dropped terminal.
struct NewGroupDropDelegate: DropDelegate {
    /// The view model that manages terminal groups and selection state.
    let viewModel: UtilityAreaViewModel

    /// Validates whether the drop operation includes terminal data that this delegate can handle.
    ///
    /// - Parameter info: The drop information provided by the system.
    /// - Returns: `true` if the drop contains a valid terminal item type.
    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.terminal.identifier])
    }

    /// Performs the drop by creating a new group and moving the terminal into it.
    ///
    /// - Parameter info: The drop information containing the dragged item.
    /// - Returns: `true` if the drop was successfully handled.
    func performDrop(info: DropInfo) -> Bool {
        // Extract the first item provider that conforms to the terminal type.
        guard let item = info.itemProviders(for: [UTType.terminal.identifier]).first else {
            return false
        }

        // Load and decode the terminal drag information.
        item.loadDataRepresentation(forTypeIdentifier: UTType.terminal.identifier) { data, _ in
            guard let data = data,
                  let dragInfo = try? JSONDecoder().decode(TerminalDragInfo.self, from: data),
                  let terminal = viewModel.terminalGroups
                      .flatMap({ $0.terminals })
                      .first(where: { $0.id == dragInfo.terminalID }) else {
                return
            }

            // Perform the group creation and terminal movement on the main thread.
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    // Optional logic to clean up old location (if needed).
                    viewModel.finalizeMoveTerminal(terminal, toGroup: UUID(), before: nil)

                    // Create a new group containing the dropped terminal.
                    viewModel.createGroup(with: [terminal])

                    // Reset drag-related state.
                    viewModel.dragOverTerminalID = nil
                    viewModel.draggedTerminalID = nil
                }
            }
        }

        return true
    }
}
