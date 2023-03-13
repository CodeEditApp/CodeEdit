//
//  WindowCommands.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/03/2023.
//

import SwiftUI

struct WindowCommands: Commands {

    @Environment(\.openWindow) var openWindow

    var body: some Commands {
        CommandGroup(after: .windowArrangement) {
            Button("OpenWindowAction") {
                guard let result = NSMenuItem.openWindowAction?() else {
                    return
                }
                switch result {
                case (.some(let id), .none):
                    openWindow(id: id)
                case (.none, .some(let data)):
                    openWindow(value: data)
                case (.some(let id), .some(let data)):
                    openWindow(id: id, value: data)
                default:
                    break
                }
            }
        }
    }
}
