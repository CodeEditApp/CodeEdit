//
//  NavigateCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct NavigateCommands: Commands {

    @FocusedObject var tabGroup: TabGroupData?

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

                }
                .disabled(true)

                Button("Show Next Tab") {

                }
                .disabled(true)

                Divider()

                Button("Go Forward") {
                    tabGroup?.goForwardInHistory()
                }
                .disabled(!(tabGroup?.canGoForwardInHistory ?? false))

                Button("Go Back") {
                    tabGroup?.goBackInHistory()
                }
                .disabled(!(tabGroup?.canGoBackInHistory ?? false))
            }
            .disabled(tabGroup == nil)
        }
    }
}
