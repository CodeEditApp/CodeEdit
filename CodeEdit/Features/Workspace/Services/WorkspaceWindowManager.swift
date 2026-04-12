//
//  WorkspaceWindowManager.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import AppKit
import SwiftUI
import Factory
import WelcomeWindow

extension Notification.Name {
    static let openWelcomeWindow = Notification.Name("CodeEdit.openWelcomeWindow")
}

/// Manages the lifecycle of workspace windows, replacing NSDocumentController for workspace management.
@MainActor
final class WorkspaceWindowManager: WorkspaceWindowManaging {

    @LazyInjected(\.lspService)
    var lspService

    /// All currently open workspaces.
    private(set) var openWorkspaces: [Workspace] = []

    /// Maps workspaces to their window controllers for lookup.
    private var windowControllers: [ObjectIdentifier: CodeEditWindowController] = [:]

    // MARK: - Open Workspace

    func openWorkspace(at url: URL) throws {
        // Check if this workspace is already open
        if let existing = openWorkspaces.first(where: { $0.fileURL?.standardizedFileURL == url.standardizedFileURL }) {
            focusWorkspace(existing)
            return
        }

        let workspace = Workspace(url: url)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1400, height: 900),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let windowController = CodeEditWindowController(
            window: window,
            workspace: workspace
        )

        if let rectString = workspace.statePersistence?.get(.workspaceWindowSize) as? String {
            window.setFrame(NSRectFromString(rectString), display: true, animate: false)
        } else {
            window.setFrame(NSRect(x: 0, y: 0, width: 1400, height: 900), display: true, animate: false)
            window.center()
        }

        window.setAccessibilityIdentifier("workspace")
        window.setAccessibilityDocument(workspace.fileURL?.absoluteString)

        openWorkspaces.append(workspace)
        windowControllers[ObjectIdentifier(workspace)] = windowController
        workspace.notificationPanel.windowController = windowController

        window.makeKeyAndOrderFront(nil)

        RecentsStore.documentOpened(at: url)
    }

    // MARK: - Close Workspace

    func closeWorkspace(_ workspace: Workspace) {
        if let path = workspace.fileURL?.absoluteURL.path() {
            lspService.closeWorkspace(path)
        }

        workspace.tearDown()

        let id = ObjectIdentifier(workspace)
        windowControllers.removeValue(forKey: id)
        openWorkspaces.removeAll { $0 === workspace }

        if openWorkspaces.isEmpty {
            handleLastWorkspaceClosed()
        }
    }

    // MARK: - Query

    func workspace(containing url: URL) -> Workspace? {
        openWorkspaces.first { workspace in
            workspace.workspaceFileManager?.getFile(url.absolutePath, createIfNotFound: true) != nil
        }
    }

    /// Attempts to open a file URL in an existing workspace, finding the nearest workspace.
    /// Returns `true` if the file was opened in a workspace.
    func openFileInWorkspace(url: URL) -> Bool {
        guard !url.isFolder else { return false }

        for workspace in openWorkspaces.sorted(by: {
            ($0.fileURL?.sharedComponents(url) ?? 0) > ($1.fileURL?.sharedComponents(url) ?? 0)
        }) {
            if let newFile = workspace.workspaceFileManager?.getFile(url.absolutePath, createIfNotFound: true) {
                workspace.editorManager?.openTab(item: newFile)
                focusWorkspace(workspace)
                return true
            }
        }
        return false
    }

    // MARK: - Window Controller Access

    func windowController(for workspace: Workspace) -> CodeEditWindowController? {
        windowControllers[ObjectIdentifier(workspace)]
    }

    // MARK: - Open Panel

    func openDocumentFromPanel() {
        let dialog = NSOpenPanel()
        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true

        dialog.begin { [weak self] result in
            guard let self, result == .OK, let url = dialog.url else { return }
            self.openDocument(at: url, onCompletion: {})
        }
    }

    func newDocumentFromPanel() {
        let panel = NSSavePanel()
        guard panel.runModal() == .OK, let url = panel.url else { return }

        let created = FileManager.default.createFile(
            atPath: url.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
        guard created else {
            print("Failed to create new document")
            return
        }

        if !openFileInWorkspace(url: url) {
            NSDocumentController.shared.openDocument(
                withContentsOf: url,
                display: true
            ) { _, _, error in
                if let error { NSAlert(error: error).runModal() }
            }
        }
    }

    // MARK: - Convenience Openers

    /// Opens a workspace or file at the given URL, calling the completion handler on success.
    func openDocument(at url: URL, onCompletion: @escaping () -> Void) {
        do {
            if url.isFolder {
                try openWorkspace(at: url)
                onCompletion()
            } else if openFileInWorkspace(url: url) {
                onCompletion()
            } else {
                NSDocumentController.shared.openDocument(
                    withContentsOf: url, display: true
                ) { _, _, error in
                    if error == nil { onCompletion() }
                }
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    /// Opens a dialog to choose a file or folder, with optional configuration.
    func openDocumentWithDialog(
        canChooseFiles: Bool = true,
        canChooseDirectories: Bool = true,
        onDialogPresented: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        let dialog = NSOpenPanel()
        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = canChooseFiles
        dialog.canChooseDirectories = canChooseDirectories

        onDialogPresented?()

        dialog.begin { [weak self] result in
            guard let self else { return }
            if result == .OK, let url = dialog.url {
                self.openDocument(at: url, onCompletion: {})
            } else if result == .cancel {
                onCancel?()
            }
        }
    }

    // MARK: - Private

    private func focusWorkspace(_ workspace: Workspace) {
        if let controller = windowControllers[ObjectIdentifier(workspace)] {
            controller.window?.makeKeyAndOrderFront(nil)
        }
    }

    private func handleLastWorkspaceClosed() {
        switch Settings[\.general].reopenWindowAfterClose {
        case .showWelcomeWindow:
            if let welcomeWindow = NSApp.findWindow(.welcome) {
                welcomeWindow.makeKeyAndOrderFront(nil)
            } else {
                // Post notification for AppDelegate to open the welcome window via SwiftUI's openWindow
                NotificationCenter.default.post(name: .openWelcomeWindow, object: nil)
            }
        case .quit:
            NSApplication.shared.terminate(nil)
        case .doNothing:
            break
        }
    }
}
