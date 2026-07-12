//
//  SourceControlCommands.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/29/24.
//

import CESourceControl
import SwiftUI

struct SourceControlCommands: Commands {
    @State private var windowController: CodeEditWindowController?

    @State private var confirmDiscardChanges: Bool = false

    var sourceControlManager: SourceControlManager? {
        windowController?.workspace?.sourceControlManager
    }

    var sourceControlViewModel: SourceControlViewModel? {
        windowController?.workspace?.sourceControlViewModel
    }

    var body: some Commands {
        CommandMenu("Source Control") {
            Group {
                Button("Commit...") {
                    // TODO: Open Source Control Navigator to Changes tab
                }
                .disabled(true)

                Button("Push...") {
                    sourceControlViewModel?.pushSheetIsPresented = true
                }

                Button("Pull...") {
                    sourceControlViewModel?.pullSheetIsPresented = true
                }
                .keyboardShortcut("x", modifiers: [.command, .option])

                Button("Fetch Changes") {
                    sourceControlViewModel?.fetchSheetIsPresented = true
                }

                Divider()

                Button("Stage All Changes") {
                    guard let sourceControlManager else { return }
                    if sourceControlManager.changedFiles.isEmpty {
                        sourceControlViewModel?.noChangesToStageAlertIsPresented = true
                    } else {
                        Task {
                            do {
                                try await sourceControlManager.add(sourceControlManager.changedFiles.map { $0.fileURL })
                            } catch {
                                await sourceControlManager.showAlertForError(
                                    title: "Failed To Stage Changes",
                                    error: error
                                )
                            }
                        }
                    }
                }

                Button("Unstage All Changes") {
                    guard let sourceControlManager else { return }
                    if sourceControlManager.changedFiles.isEmpty {
                        sourceControlViewModel?.noChangesToUnstageAlertIsPresented = true
                    } else {
                        Task {
                            do {
                                try await sourceControlManager.reset(
                                    sourceControlManager.changedFiles.map { $0.fileURL }
                                )
                            } catch {
                                await sourceControlManager.showAlertForError(
                                    title: "Failed To Unstage Changes",
                                    error: error
                                )
                            }
                        }
                    }
                }

                Divider()

                Button("Cherry-Pick...") {
                    // TODO: Implementation Needed
                }
                .disabled(true)

                Button("Stash Changes...") {
                    if sourceControlManager?.changedFiles.isEmpty ?? false {
                        sourceControlViewModel?.noChangesToStashAlertIsPresented = true
                    } else {
                        sourceControlViewModel?.stashSheetIsPresented = true
                    }
                }

                Divider()

                Button("Discard All Changes...") {
                    if sourceControlManager?.changedFiles.isEmpty ?? false {
                        sourceControlViewModel?.noChangesToDiscardAlertIsPresented = true
                    } else {
                        sourceControlViewModel?.discardAllAlertIsPresented = true
                    }
                }

                Divider()

                Button("Add Exisiting Remote...") {
                    sourceControlViewModel?.addExistingRemoteSheetIsPresented = true
                }
            }
            .disabled(windowController?.workspace == nil)
            .observeWindowController($windowController)
        }
    }
}
