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
                if let value = NSMenuItem.value {
                    openWindow(id: "Workspace", value: value)
                }
            }
        }
    }
}
