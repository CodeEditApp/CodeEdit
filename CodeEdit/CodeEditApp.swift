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

    init() {
        _ = CodeEditDocumentController.shared
        NSMenuItem.swizzle()
    }

    var body: some Scene {

        WelcomeWindow()

        AboutWindow()

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
