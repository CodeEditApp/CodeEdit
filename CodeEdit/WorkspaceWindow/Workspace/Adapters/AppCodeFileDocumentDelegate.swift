//
//  AppCodeFileDocumentDelegate.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import CELSP
import AppKit
import CEEditor
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

    init(
        lspService: any LSPServiceProtocol,
        windowManager: WorkspaceWindowManaging,
        languageServices: LanguageServicesProvider,
        settingsStore: AppSettingsStore
    ) {
        self.settingsStore = settingsStore
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
        })
    }

    func documentDidOpen(_ document: CodeFileDocument) {
        lspService.openDocument(document)
    }

    func documentDidClose(at url: URL) {
        lspService.closeDocument(url)
    }
}
