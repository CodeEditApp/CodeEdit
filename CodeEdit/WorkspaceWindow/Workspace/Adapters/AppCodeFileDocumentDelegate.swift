//
//  AppCodeFileDocumentDelegate.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import AppKit
import CEEditor
import CELSP
import CodeEditCore
import CodeEditDocument
import CodeEditSettings
import CodeEditTextView
import SwiftUI

/// App-side implementation of ``CodeFileDocumentDelegate``. Bridges a packaged
/// `CodeFileDocument` back to the app's `Workspace` undo registry, Settings-injected
/// standalone-window view, and `LSPService` lifecycle notifications.
@MainActor
final class AppCodeFileDocumentDelegate: CodeFileDocumentDelegate {
    private let lspService: any LSPServiceProtocol
    private let windowManager: WorkspaceWindowManaging
    private let languageServices: LanguageServicesProvider

    /// The settings store, so the standalone hosting root below can inject the settings seam.
    private let settingsStore: PersistentSettingsStore

    /// The themes in effect. `CodeFileView` reads these as an `@EnvironmentObject`, which traps when
    /// missing — and the hosting root below is standalone, so nothing above it can supply them.
    private let activeTheme: ActiveTheme

    init(
        lspService: any LSPServiceProtocol,
        windowManager: WorkspaceWindowManaging,
        languageServices: LanguageServicesProvider,
        settingsStore: PersistentSettingsStore,
        activeTheme: ActiveTheme
    ) {
        self.settingsStore = settingsStore
        self.activeTheme = activeTheme
        self.lspService = lspService
        self.windowManager = windowManager
        self.languageServices = languageServices
    }

    /// The **workspace** undo manager for `url`, or `nil` — never a standalone window's.
    ///
    /// `CodeFileDocument` calls this to register an external change to an open file as one undo
    /// mutation. A file shown in a standalone single-file window has its own registry, private to
    /// `WindowCodeFileView`, which this cannot reach: there is no workspace to look it up through.
    ///
    /// Normally the two cannot disagree, because every route to a standalone window
    /// (`DocumentOpener`, `WorkspaceWindowManager`'s new-file path, `AppDelegate`'s open handler)
    /// tries `openFileInWorkspace(url:)` first and only falls through when it fails — and that check
    /// uses the same predicate as `workspace(containing:)`. So if a workspace holds the file there
    /// is no standalone window, and if none does this returns `nil` and nothing is registered.
    ///
    /// The guard is evaluated once, though. Open a loose file, *then* open its parent folder as a
    /// workspace, and the standalone window keeps its private registry while this starts finding
    /// the workspace's. An external change then registers onto a stack that window does not read.
    /// Editing undo inside the window is unaffected. Left as-is deliberately: migrating a window
    /// onto a workspace registry, or letting this search every registry, is more machinery than a
    /// three-step ordering edge case earns.
    func undoManager(forFile url: URL) -> CEUndoManager? {
        windowManager.workspace(containing: url)?.undoRegistry.managerIfExists(forFile: url)
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
