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
        Container.shared.codeFileDocumentDelegate.register { AppCodeFileDocumentDelegate() }
        Container.shared.workspaceNavigator.register { AppWorkspaceNavigator() }
        Container.shared.fileRelocator.register { AppFileRelocator() }
        Container.shared.languageServicesProvider.register { @MainActor in AppLanguageServicesProvider() }
        SettingsData.TextEditingSettings.registerCommands()
        SettingsData.reconcileDefaultKeybindings()
    }

    var body: some Scene {
        Group {
            WelcomeWindow(
                subtitleView: { WelcomeSubtitleView() },
                actions: { dismissWindow in
                    NewFileButton(dismissWindow: dismissWindow)
                    GitCloneButton(dismissWindow: dismissWindow)
                    OpenFileOrFolderButton(dismissWindow: dismissWindow)
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
                    CodeEditCommands()
                }
        }
        .environment(\.settings, settings.preferences) // Add settings to each window environment
    }
}
