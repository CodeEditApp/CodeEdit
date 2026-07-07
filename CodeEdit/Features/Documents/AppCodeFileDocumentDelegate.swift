//
//  AppCodeFileDocumentDelegate.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import AppKit
import SwiftUI
import Factory
import CodeEditTextView

/// App-side implementation of ``CodeFileDocumentDelegate``. Bridges a packaged
/// `CodeFileDocument` back to the app's `Workspace` undo registry, Settings-injected
/// standalone-window view, and `LSPService` lifecycle notifications.
@MainActor
final class AppCodeFileDocumentDelegate: CodeFileDocumentDelegate {
    @LazyInjected(\.lspService) private var lspService

    /// `nonisolated` so the Factory registration closure can construct it from any context
    /// (e.g. a non-isolated test `setUp`); the init touches no main-actor state.
    nonisolated init() {}

    func undoManager(forFile url: URL) -> CEUndoManager? {
        url.findWorkspace()?.undoRegistration.managerIfExists(forFile: url)
    }

    func makeWindowContentView(for document: CodeFileDocument) -> NSView {
        NSHostingView(rootView: SettingsInjector {
            WindowCodeFileView(codeFile: document)
        })
    }

    func documentDidOpen(_ document: CodeFileDocument) {
        lspService.openDocument(document)
    }

    func documentDidClose(at url: URL) {
        lspService.closeDocument(url)
    }
}
