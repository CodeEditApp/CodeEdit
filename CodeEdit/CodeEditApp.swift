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

        WelcomeWindow()

        Window("", id: "About") {
            AboutView()
        }
        .defaultSize(width: 530, height: 220)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        Window("Extensions", id: "Extensions") {
            NavigationSplitView {

            } detail: {
                VStack {
                    Text("Extensions")
                }
            }
        }
        .keyboardShortcut("2", modifiers: [.command, .shift])

        Settings {
            VStack {
                Text("Hello world!")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .defaultSize(width: 500, height: 500)
        .commands {
            CodeEditCommands()
        }
    }
}

class CommandsManager: ObservableObject {
    @Published var shown = true
    @Published var commands: [String] = []
}
