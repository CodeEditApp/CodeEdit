//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate

    @StateObject var commandsManager = CommandsManager()

    init() {
        NSMenuItem.swizzle()
    }

    var body: some Scene {

        Settings {
            VStack {
                Text("Hello world!")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .defaultSize(width: 500, height: 500)
//        .commandsRemoved()
        .commands {
            CodeEditCommands()
            MainCommands(appDelegate: appdelegate)
        }
    }
}

class CommandsManager: ObservableObject {
    @Published var shown = true
    @Published var commands: [String] = []
}
