//
//  SourceControlToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlToolbarBottom: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    var body: some View {
        SourceControlSearchToolbar()
            .safeAreaInset(edge: .leading, spacing: 2) {
                sourceControlMenu
            }
        .frame(height: 29, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
        .overlay(alignment: .top) {
            Divider()
                .opacity(0)
        }
    }

    private var sourceControlMenu: some View {
        Menu {
            Button("Discard All Changes...") {
                if discardChangesDialog() {
                    workspace.sourceControlManager?.discardAllChanges()
                }
            }
            Button("Stash Changes...") {}
                .disabled(true) // TODO: Implementation Needed
            Button("Commit...") {}
                .disabled(true) // TODO: Implementation Needed
            Button("Create Pull Request...") {}
                .disabled(true) // TODO: Implementation Needed
        } label: {
            Image(systemName: "ellipsis.circle")
                .frame(width: 30, alignment: .center)
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 22, alignment: .center)
    }

    /// Renders a Discard Changes Dialog
    func discardChangesDialog() -> Bool {
        let alert = NSAlert()

        alert.messageText = "Do you want to discard all uncommitted, local changes?"
        alert.informativeText = "This operation cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Discard")
        alert.addButton(withTitle: "Cancel")

        return alert.runModal() == .alertFirstButtonReturn
    }
}
