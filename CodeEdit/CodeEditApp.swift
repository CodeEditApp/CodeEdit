//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI
import CodeEditSettings
import CodeEditDocument
import CodeEditCore
import Factory
import WelcomeWindow
import AboutWindow

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate
    @ObservedObject var settings = Settings.shared

    let updater: SoftwareUpdater = SoftwareUpdater()

    init() {
        NSMenuItem.swizzle()
        NSSplitViewItem.swizzle()
        CodeFileDocument.delegateProvider = { [dependencies = appdelegate.dependencies] in
            dependencies.codeFileDocumentDelegate
        }
        SettingsData.TextEditingSettings.registerCommands(in: appdelegate.dependencies.commandManager)
        SettingsData.reconcileDefaultKeybindings(keybindingManager: appdelegate.dependencies.keybindingManager)
    }

    var body: some Scene {
        Group {
            WelcomeWindow(
                subtitleView: { WelcomeSubtitleView() },
                actions: { dismissWindow in
                    NewFileButton(
                        windowManager: appdelegate.dependencies.workspaceWindowManager,
                        dismissWindow: dismissWindow
                    )
                    GitCloneButton(
                        windowManager: appdelegate.dependencies.workspaceWindowManager,
                        shellClient: appdelegate.dependencies.shellClient,
                        dismissWindow: dismissWindow
                    )
                    OpenFileOrFolderButton(
                        windowManager: appdelegate.dependencies.workspaceWindowManager,
                        dismissWindow: dismissWindow
                    )
                },
                onDrop: { url, dismissWindow in
                    let windowManager = appdelegate.dependencies.workspaceWindowManager
                    Task {
                        do {
                            try windowManager.openWorkspace(at: url)
                            dismissWindow()
                        } catch {
                            print("Failed to open workspace: \(error)")
                        }
                    }
                },
                openHandler: { urls, dismissWindow in
                    let windowManager = appdelegate.dependencies.workspaceWindowManager
                    for url in urls {
                        windowManager.openDocument(at: url, onCompletion: {})
                    }
                    dismissWindow()
                }
            )

            ExtensionManagerWindow()

            AboutWindow(
                subtitleView: { AboutSubtitleView() },
                actions: {
                    AboutButton(title: "Contributors", destination: {
                        ContributorsView()
                    })
                    AboutButton(title: "Acknowledgements", destination: {
                        AcknowledgementsView()
                    })
                },
                footer: { AboutFooterView() }
            )

            SettingsWindow()
                .commands {
                    CodeEditCommands(dependencies: appdelegate.dependencies)
                }
        }
        .environment(\.settings, settings.preferences) // Add settings to each window environment
        .appServices(appdelegate.dependencies)
    }
}
