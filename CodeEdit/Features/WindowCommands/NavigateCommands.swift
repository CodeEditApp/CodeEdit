//
//  NavigateCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct NavigateCommands: Commands {
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

                Button("Show Previous Tab") {

                }
                .disabled(true)

                Button("Show Next Tab") {

                }
                .disabled(true)

                Divider()

                Button("Go Forward") {

                }
                .disabled(true)
            }

            Group {

                Button("Go Back") {

                }

                Divider()

                Button("Jump to Selection") {

                }
                .keyboardShortcut("l", modifiers: [.command, .option])

                Button("Jump to Definition") {

                }
                .keyboardShortcut("j")

                Button("Jump to Original Source") {

                }

                Button("Jump to Last Destination") {

                }

                Divider()

                Button("Jump to Next Issue") {

                }
                .keyboardShortcut("'")

                Button("Jump to Previous Issue") {

                }
                .keyboardShortcut("\"")
            }
            .disabled(true)
        }
    }
}
