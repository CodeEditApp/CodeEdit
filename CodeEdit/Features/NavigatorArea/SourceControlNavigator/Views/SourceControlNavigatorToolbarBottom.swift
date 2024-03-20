//
//  SourceControlNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorToolbarBottom: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State private var text = ""
    @State private var stashChangesIsPresented = false
    @State private var noChangesToStashIsPresented = false
    @State private var noDiscardChangesIsPresented = false

    var body: some View {
        HStack(spacing: 5) {
            sourceControlMenu
            PaneTextField(
                "Filter",
                text: $text,
                leadingAccessories: {
                    Image(
                        systemName: text.isEmpty
                        ? "line.3.horizontal.decrease.circle"
                        : "line.3.horizontal.decrease.circle.fill"
                    )
                    .foregroundStyle(
                        text.isEmpty
                        ? Color(nsColor: .secondaryLabelColor)
                        : Color(nsColor: .controlAccentColor)
                    )
                    .padding(.leading, 4)
                },
                clearable: true
            )
        }
        .frame(height: 28, alignment: .center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 5)
        .overlay(alignment: .top) {
            Divider()
                .opacity(0)
        }
    }

    private var sourceControlMenu: some View {
        Menu {
            Button("Discard All Changes...") {
                guard let sourceControlManager = workspace.sourceControlManager else { return }
                if sourceControlManager.changedFiles.isEmpty {
                    noDiscardChangesIsPresented = true
                    return
                }
                if discardChangesDialog() {
                    workspace.sourceControlManager?.discardAllChanges()
                }
            }
            Button("Stash Changes...") {
                if sourceControlManager.changedFiles.isEmpty {
                    noChangesToStashIsPresented = true
                } else {
                    stashChangesIsPresented = true
                }
            }
        } label: {}
        .background {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
        .sheet(isPresented: $stashChangesIsPresented) {
            SourceControlStashChangesView()
        }
        .alert("Cannot Stash Changes", isPresented: $noChangesToStashIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("There are no uncommitted changes in the local repository for this project.")
        }
        .alert("Cannot Discard Changes", isPresented: $noDiscardChangesIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("There are no uncommitted changes in the local repository for this project.")
        }
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
