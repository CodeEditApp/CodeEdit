//
//  NavigateCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct NavigateCommands: Commands {

    @FocusedObject var tabgroup: TabGroupData?

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

                Button("Show Previous Tab") {

                }

                Button("Show Next Tab") {

                }

                Divider()

            }
            .disabled(true)

            Group {
                Button("Go Forward") {
                    tabgroup?.goToNextTab()
                }
                .disabled(!(tabgroup?.canGoToNextTab ?? false))

                Button("Go Back") {
                    tabgroup?.goToPreviousTab()
                }
                .disabled(!(tabgroup?.canGoToPreviousTab ?? false))
            }
            .disabled(tabgroup == nil)
        }
    }
}
