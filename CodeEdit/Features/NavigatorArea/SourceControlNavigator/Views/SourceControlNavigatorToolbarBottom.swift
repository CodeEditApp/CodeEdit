//
//  SourceControlNavigatorToolbarBottom.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorToolbarBottom: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    @State private var text = ""

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
        } label: {}
        .background {
            Image(systemName: "ellipsis.circle")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .frame(maxWidth: 18, alignment: .center)
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
