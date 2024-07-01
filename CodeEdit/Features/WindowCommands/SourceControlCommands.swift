//
//  SourceControlCommands.swift
//  CodeEdit
//
//  Created by Austin Condiff on 6/29/24.
//

import SwiftUI

struct SourceControlCommands: Commands {
    @FocusedObject var scm: SourceControlManager?

    var body: some Commands {
        CommandMenu("Source Control") {
            if let scm = scm {
                Button("Commit...") {
                    // TODO: Open Source Control Navigator to Changes tab
                }
                .disabled(true)
                Button("Push...") {
                    scm.pushSheetIsPresented = true
                }
                Button("Pull...") {
                    scm.pullSheetIsPresented = true
                }
                .keyboardShortcut("x", modifiers: [.command, .option])
                Button("Fetch Changes") {
//                    scm.fetchSheetIsPresented = true
                }
                Divider()
                Button("Stage All Changes") {
//                    scm.stageAllChanges()
                }
                Button("Unstage All Changes") {
//                    scm.unstageAllChanges()
                }
                Divider()
                Button("Cherry-Pick...") {
                    //                scm.cherryPickSheetIsPresented = true
                }
                Button("Stash Changes...") {
                    //                scm.stashSheetIsPresented = true
                }
                Divider()
                Button("Discard All Changes...") {
                    //                scm.discardAllChangesSheetIsPresented = true
                }
            }
        }
    }
}
