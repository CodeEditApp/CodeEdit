//
//  WorkspaceWindowManager.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 06.04.26.
//

import AppKit
import CodeEditSettings
import CEWorkspaceFileManager
import CodeEditCore
import CENotifications
import SwiftUI
import WelcomeWindow

/// Manages the lifecycle of workspace windows, replacing NSDocumentController for workspace management.
@MainActor
final class WorkspaceWindowManager: WorkspaceWindowManaging {

    private let dependencies: AppDependencies
    private var eventBus: EventBus { dependencies.eventBus }

    private let workspaceOpener: WorkspaceOpener
    private let workspaceCloser: WorkspaceCloser
    private lazy var documentOpener = DocumentOpener(windowManager: self)

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.workspaceOpener = WorkspaceOpener(dependencies: dependencies)
        self.workspaceCloser = WorkspaceCloser(lspService: dependencies.lspService)
    }

    /// All currently open workspaces.
    private(set) var openWorkspaces: [Workspace] = []

    /// Maps workspaces to their window controllers for lookup.
    private var windowControllers: [ObjectIdentifier: CodeEditWindowController] = [:]

    // MARK: - Open Workspace

    func openWorkspace(at url: URL) throws {
        // Check if this workspace is already open
        if let existing = openWorkspaces.first(where: { $0.fileURL.standardizedFileURL == url.standardizedFileURL }) {
            focusWorkspace(existing)
            return
        }

        let result = workspaceOpener.execute(url: url)

        openWorkspaces.append(result.workspace)
        windowControllers[ObjectIdentifier(result.workspace)] = result.windowController
        let notificationPanel = result.windowController.notificationPanel
        notificationPanel.windowController = result.windowController
        // App shell owns window-toolbar mutation; the package signals a refresh via this hook.
        notificationPanel.onToolbarUpdateRequested = { [weak notificationPanel] in
            notificationPanel?.updateToolbarItem()
        }

        result.window.makeKeyAndOrderFront(nil)

        RecentsStore.documentOpened(at: url)
    }

    // MARK: - Close Workspace

    func closeWorkspace(_ workspace: Workspace) {
        workspaceCloser.execute(workspace: workspace)

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
            workspace.workspaceFileManager.getFile(url.absolutePath, createIfNotFound: true) != nil
        }
    }

    /// Attempts to open a file URL in an existing workspace, finding the nearest workspace.
    /// Returns `true` if the file was opened in a workspace.
    func openFileInWorkspace(url: URL, asTemporary: Bool) -> Bool {
        guard !url.isFolder else { return false }

        for workspace in openWorkspaces.sorted(by: {
            $0.fileURL.sharedComponents(url) > $1.fileURL.sharedComponents(url)
        }) {
            if let newFile = workspace.workspaceFileManager.getFile(url.absolutePath, createIfNotFound: true) {
                workspace.editorManager.openTab(item: newFile, asTemporary: asTemporary)
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
        documentOpener.execute(url: url, onCompletion: onCompletion)
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
        switch dependencies.settingsAccessor.value(GeneralSettings.self).reopenWindowAfterClose {
        case .showWelcomeWindow:
            if let welcomeWindow = NSApp.findWindow(.welcome) {
                welcomeWindow.makeKeyAndOrderFront(nil)
            } else {
                // Publish event for AppDelegate to open the welcome window via SwiftUI's openWindow
                eventBus.publish(WelcomeWindowRequestedEvent())
            }
        case .quit:
            NSApplication.shared.terminate(nil)
        case .doNothing:
            break
        }
    }
}

extension URL {
    /// Compares this url with another, counting the number of shared path components. Stops counting once a
    /// different component is found.
    ///
    /// - Note: URL treats a leading `/` as a component, so `/Users` and `/` will return `1`.
    /// - Parameter other: The URL to compare against.
    /// - Returns: The number of shared components.
    func sharedComponents(_ other: URL) -> Int {
        var count = 0
        for (component, otherComponent) in zip(pathComponents, other.pathComponents) {
            if component == otherComponent {
                count += 1
            } else {
                return count
            }
        }
        return count
    }
}
