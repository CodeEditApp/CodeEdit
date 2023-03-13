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

    @Environment(\.dismiss) var dismiss

    var body: some Scene {

        Window("Welcome To CodeEdit", id: "Welcome") {
            NavigationSplitView {

            } detail: {
                VStack {
                    Text("Welcome")
                }
            }
            //                .task {
            //                    dismiss()
            //                }
        }

        Window("Extensions", id: "Extensions") {
            NavigationSplitView {

            } detail: {
                VStack {
                    Text("Extensions")
                }
            }
            //                .task {
            //                    dismiss()
            //                }
        }

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
