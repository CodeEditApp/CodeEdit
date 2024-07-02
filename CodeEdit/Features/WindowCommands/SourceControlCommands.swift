//
//  SourceControlCommands.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/29/24.
//

import SwiftUI

struct SourceControlCommands: Commands {
    @State private var windowController: CodeEditWindowController?

    @State private var confirmDiscardChanges: Bool = false

    var sourceControlManager: SourceControlManager? {
        windowController?.workspace?.sourceControlManager
    }

    var body: some Commands {
        CommandMenu("Source Control") {
            Group {
                Button("Commit...") {
                    // TODO: Open Source Control Navigator to Changes tab
                }
                .disabled(true)

                Button("Push...") {
                    sourceControlManager?.pushSheetIsPresented = true
                }

                Button("Pull...") {
                    sourceControlManager?.pullSheetIsPresented = true
                }
                .keyboardShortcut("x", modifiers: [.command, .option])

                Button("Fetch Changes") {
                    sourceControlManager?.fetchSheetIsPresented = true
                }

                Divider()

                Button("Stage All Changes") {
                    guard let sourceControlManager else { return }
                    Task {
                        do {
                            try await sourceControlManager.add(sourceControlManager.changedFiles)
                        } catch {
                            await sourceControlManager.showAlertForError(title: "Failed To Stage Changes", error: error)
                        }
                    }
                }
                .disabled(true)

                Button("Unstage All Changes") {
                    guard let sourceControlManager else { return }
                    Task {
                        do {
                            try await sourceControlManager.reset(sourceControlManager.changedFiles)
                        } catch {
                            await sourceControlManager.showAlertForError(
                                title: "Failed To Unstage Changes",
                                error: error
                            )
                        }
                    }
                }
                .disabled(true)

                Divider()

                Button("Cherry-Pick...") {
                    // TODO: Implementation Needed
                }
                .disabled(true)

                Button("Stash Changes...") {
                    sourceControlManager?.stashSheetIsPresented = true
                }

                Divider()

                Button("Discard All Changes...") {
                    guard sourceControlManager != nil else { return }
                    let alert = NSAlert()
                    alert.alertStyle = .warning
                    alert.messageText = "Do you want to permanently delete all changes?"
                    alert.informativeText = "This action cannot be undone."
                    alert.addButton(withTitle: "Discard")
                    alert.addButton(withTitle: "Cancel")
                    alert.buttons.first?.hasDestructiveAction = true
                    guard alert.runModal() == .alertFirstButtonReturn else { return }
                    sourceControlManager?.discardAllChanges()
                }
            }
            .disabled(windowController?.workspace == nil)
            .observeWindowController($windowController)
        }
    }
}
