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

                }
                .keyboardShortcut("j", modifiers: [.shift, .command])

                Button("Reveal Changes in Navigator") {

                }
                .keyboardShortcut("m", modifiers: [.shift, .command])

                Button("Open in Next Editor") {

                }
                .keyboardShortcut(",", modifiers: [.option, .command])

                Button("Open in...") {

                }

                Divider()

            }
            .disabled(true)

            Group {
                Button("Show Previous Tab") {

                }

                Button("Show Next Tab") {

                }

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
