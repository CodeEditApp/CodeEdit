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
import WelcomeWindow
import AboutWindow

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate

    init() {
        NSMenuItem.swizzle()
        NSSplitViewItem.swizzle()
        let dependencies = appdelegate.dependencies
        CodeFileDocument.delegateProvider = {
            dependencies.codeFileDocumentDelegate
        }
        TextEditingSettings.registerCommands(
            in: dependencies.commandManager,
            settings: dependencies.settingsAccessor
        )
        KeybindingsSettings.reconcileDefaults(
            keybindingManager: dependencies.keybindingManager,
            settings: dependencies.settingsAccessor
        )
    }

    var body: some Scene {
        SettingsSceneInjector(store: appdelegate.dependencies.settingsStore) {
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

            SettingsWindow(updater: appdelegate.dependencies.softwareUpdater)
                .commands {
                    CodeEditCommands(dependencies: appdelegate.dependencies)
                }
        }
        .appServices(appdelegate.dependencies)
    }
}
