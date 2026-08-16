//
//  AppCodeFileDocumentDelegate.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import CELSP
import AppKit
import CEEditor
import CodeEditCore
import SwiftUI
import CodeEditTextView
import CodeEditDocument

/// App-side implementation of ``CodeFileDocumentDelegate``. Bridges a packaged
/// `CodeFileDocument` back to the app's `Workspace` undo registry, Settings-injected
/// standalone-window view, and `LSPService` lifecycle notifications.
@MainActor
final class AppCodeFileDocumentDelegate: CodeFileDocumentDelegate {
    private let lspService: any LSPServiceProtocol
    private let windowManager: WorkspaceWindowManaging
    private let languageServices: LanguageServicesProvider

    /// The settings store, so the standalone hosting root below can inject the settings seam.
    private let settingsStore: AppSettingsStore

    /// The themes in effect. `CodeFileView` reads these as an `@EnvironmentObject`, which traps when
    /// missing — and the hosting root below is standalone, so nothing above it can supply them.
    private let activeTheme: ActiveTheme

    init(
        lspService: any LSPServiceProtocol,
        windowManager: WorkspaceWindowManaging,
        languageServices: LanguageServicesProvider,
        settingsStore: AppSettingsStore,
        activeTheme: ActiveTheme
    ) {
        self.settingsStore = settingsStore
        self.activeTheme = activeTheme
        self.lspService = lspService
        self.windowManager = windowManager
        self.languageServices = languageServices
    }

    func undoManager(forFile url: URL) -> CEUndoManager? {
        windowManager.workspace(containing: url)?.undoRegistration.managerIfExists(forFile: url)
    }

    func makeWindowContentView(for document: CodeFileDocument) -> NSView {
        NSHostingView(rootView: SettingsInjector(store: settingsStore) {
            WindowCodeFileView(codeFile: document)
                .environment(\.languageServices, languageServices)
                .environmentObject(activeTheme)
        })
    }

    func documentDidOpen(_ document: CodeFileDocument) {
        lspService.openDocument(document)
    }

    func documentDidClose(at url: URL) {
        lspService.closeDocument(url)
    }
}
