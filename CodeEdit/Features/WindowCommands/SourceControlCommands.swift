//
//  SourceControlCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct SourceControlCommands: Commands {
    var body: some Commands {
        CommandMenu("Source Control") {
            Group {
                // Could be done with git commit or with a view
                Button("Commit...") {

                }
                .keyboardShortcut("c", modifiers: [.option, .command])

                // Could be done with git push or with a view
                Button("Push...") {

                }

                Button("Pull...") {

                }
                .keyboardShortcut("x", modifiers: [.option, .command])

                Button("Fetch Changes") {

                }

                Button("Refresh File Status") {

                }

                Divider()

                Button("Cherry-Pick...") {

                }

                Button("Stash changes...") {

                }

                Button("Discard All Changes...") {

                }

                Divider()
            }
            .disabled(true)

            Group {
                // Could be done with git pull or a view
                Button("Create Pull Request...") {

                }

                Divider()

                Button("Add Selected Files") {

                }

                Button("Discard Changes in Selected Files...") {

                }

                Button("Mark Selected Files as Resolved") {

                }

                Divider()

                Button("New Git Repositories") {

                }

                Divider()

                // Could be done with GitCloneView
                Button("Clone...") {

                }
            }
            .disabled(true)
        }
    }
}
