//
//  NavigateCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct NavigateCommands: Commands {

    @FocusedObject var editor: Editor?

    var body: some Commands {
        CommandMenu("Navigate") {
            Group {
                Button("Reveal in Project Navigator") {
                    NSApp.sendAction(#selector(ProjectNavigatorViewController.revealFile(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("j", modifiers: [.shift, .command])

                Button("Reveal Changes in Navigator") {

                }
                .keyboardShortcut("m", modifiers: [.shift, .command])
                .disabled(true)

                Button("Open in Next Editor") {

                }
                .keyboardShortcut(",", modifiers: [.option, .command])
                .disabled(true)

                Button("Open in...") {

                }
                .disabled(true)

                Divider()

            }
            Group {
                Button("Show Previous Tab") {
                    editor?.selectPreviousTab()
                }
                .keyboardShortcut("{", modifiers: [.command])
                .disabled(editor?.tabs.count ?? 0 <= 1)  // Disable if there's one or no tabs

                Button("Show Next Tab") {
                    editor?.selectNextTab()
                }
                .keyboardShortcut("}", modifiers: [.command])
                .disabled(editor?.tabs.count ?? 0 <= 1)  // Disable if there's one or no tabs
            }
            Group {
                Divider()

                Button("Go Forward") {
                    editor?.goForwardInHistory()
                }
                .disabled(!(editor?.canGoForwardInHistory ?? false))

                Button("Go Back") {
                    editor?.goBackInHistory()
                }
                .disabled(!(editor?.canGoBackInHistory ?? false))
            }
            .disabled(editor == nil)
        }
    }
}
