//
//  TerminalDropDelegate.swift
//  CodeEdit
//
//  Created by Gustavo Soré on 30/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// Handles drop interactions for a terminal inside a specific group,
/// allowing for reordering or moving between groups.
struct TerminalDropDelegate: DropDelegate {
    /// The ID of the group where the drop target resides.
    let groupID: UUID

    /// The shared view model managing terminal groups and selection state.
    let viewModel: UtilityAreaViewModel

    /// The ID of the terminal that is the drop destination, or `nil` if dropping at the end.
    let destinationTerminalID: UUID?

    /// Validates if the drop contains terminal data.
    ///
    /// - Parameter info: The current drop context.
    /// - Returns: `true` if the item conforms to the terminal type.
    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: [UTType.terminal.identifier])
    }

    /// Called when the drop enters a new target.
    /// Sets the drag state in the view model for UI feedback.
    ///
    /// - Parameter info: The drop context.
    func dropEntered(info: DropInfo) {
        guard let item = info.itemProviders(for: [UTType.terminal.identifier]).first else { return }

        item.loadDataRepresentation(forTypeIdentifier: UTType.terminal.identifier) { data, _ in
            guard let data = data,
                  let dragInfo = try? JSONDecoder().decode(TerminalDragInfo.self, from: data) else { return }

            DispatchQueue.main.async {
                withAnimation {
                    viewModel.draggedTerminalID = dragInfo.terminalID
                    viewModel.dragOverTerminalID = destinationTerminalID
                }
            }
        }
    }

    /// Called continuously as the drop is updated over the view.
    /// Updates drag-over visual feedback.
    ///
    /// - Parameter info: The drop context.
    /// - Returns: A drop proposal that defines the type of drop operation (e.g., move).
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.dragOverTerminalID = destinationTerminalID
            }
        }

        return DropProposal(operation: .move)
    }

    /// Called when the drop is performed.
    /// Decodes the dragged terminal and triggers its relocation in the model.
    ///
    /// - Parameter info: The drop context with the drag payload.
    /// - Returns: `true` if the drop was handled successfully.
    func performDrop(info: DropInfo) -> Bool {
        guard let item = info.itemProviders(for: [UTType.terminal.identifier]).first else { return false }

        item.loadDataRepresentation(forTypeIdentifier: UTType.terminal.identifier) { data, _ in
            guard let data = data,
                  let dragInfo = try? JSONDecoder().decode(TerminalDragInfo.self, from: data),
                  let terminal = viewModel.terminalGroups
                      .flatMap({ $0.terminals })
                      .first(where: { $0.id == dragInfo.terminalID }) else { return }

            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.finalizeMoveTerminal(
                        terminal,
                        toGroup: groupID,
                        before: destinationTerminalID
                    )
                    viewModel.dragOverTerminalID = nil
                    viewModel.draggedTerminalID = nil
                }
            }
        }

        return true
    }
}
