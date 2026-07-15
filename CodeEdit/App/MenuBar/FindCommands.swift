//
//  FindCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct FindCommands: Commands {

    @FirstResponder var responder

    static let selector = #selector(NSTextView.performFindPanelAction(_:))

    var hasResponder: Bool {
        responder?.responds(to: Self.selector) ?? false
    }

    var body: some Commands {
        CommandMenu("Find") {
            Group {
                Button("Find...") {
                    send(.showFindPanel)
                }
                .keyboardShortcut("f")

                Button("Find and Replace...") {
                    send(.init(rawValue: 12)!)
                }
                .keyboardShortcut("f", modifiers: [.option, .command])

                Button("Find Next") {
                    send(.next)
                }
                .keyboardShortcut("g")

                Button("Find Previous") {
                    send(.previous)
                }
                .keyboardShortcut("g", modifiers: [.shift, .command])

                Button("Use Selection for Find") {
                    send(.setFindString)
                }
                .keyboardShortcut("e")

                Button("Jump to Selection") {
                    NSApp.sendAction(#selector(NSTextView.centerSelectionInVisibleArea(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("j")
            }
            .disabled(!hasResponder)
        }
    }

    func send(_ action: NSFindPanelAction) {
        let item = NSMenuItem()
        item.tag = Int(action.rawValue)
        responder?.perform(Self.selector, with: item)
    }
}
