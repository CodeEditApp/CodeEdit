//
//  AppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import CodeEditSymbols
import CodeEditSourceEditor
import OSLog

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AppDelegate")
    private let updater = SoftwareUpdater()

    @Environment(\.openWindow)
    var openWindow

    @LazyService var lspService: LSPService

    func applicationDidFinishLaunching(_ notification: Notification) {
        enableWindowSizeSaveOnQuit()
        Settings.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()

        NSApp.closeWindow(.welcome, .about)

        DispatchQueue.main.async {
            var needToHandleOpen = true

            // If no windows were reopened by NSQuitAlwaysKeepsWindows, do default behavior.
            // Non-WindowGroup SwiftUI Windows are still in NSApp.windows when they are closed,
            // So we need to think about those.
            if NSApp.windows.count > NSApp.openSwiftUIWindows {
                needToHandleOpen = false
            }

            for index in 0..<CommandLine.arguments.count {
                if CommandLine.arguments[index] == "--open" && (index + 1) < CommandLine.arguments.count {
                    let path = CommandLine.arguments[index+1]
                    let url = URL(fileURLWithPath: path)

                    CodeEditDocumentController.shared.reopenDocument(
                        for: url,
                        withContentsOf: url,
                        display: true
                    ) { document, _, _ in
                        document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                    }

                    needToHandleOpen = false
                }
            }

            if needToHandleOpen {
                self.handleOpen()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard flag else {
            handleOpen()
            return false
        }

        /// Check if all windows are either miniaturized or not visible.
        /// If so, attempt to find the first miniaturized window and deminiaturize it.
        guard sender.windows.allSatisfy({ $0.isMiniaturized || !$0.isVisible }) else { return false }
        sender.windows.first(where: { $0.isMiniaturized })?.deminiaturize(sender)
        return false
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func handleOpen() {
        let behavior = Settings.shared.preferences.general.reopenBehavior
        switch behavior {
        case .welcome:
            if !tryFocusWindow(id: .welcome) {
                openWindow(sceneID: .welcome)
            }
        case .openPanel:
            CodeEditDocumentController.shared.openDocument(self)
        case .newDocument:
            CodeEditDocumentController.shared.newDocument(self)
        }
    }

    /// Handle urls with the form `codeedit://file/{filepath}:{line}:{column}`
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            let file = URL(fileURLWithPath: url.path).path.split(separator: ":")
            let filePath = URL(fileURLWithPath: String(file[0]))
            let line = file.count > 1 ? Int(file[1]) ?? 0 : 0
            let column = file.count > 2 ? Int(file[2]) ?? 1 : 1

            CodeEditDocumentController.shared
                .openDocument(withContentsOf: filePath, display: true) { document, _, error in
                    if let error {
                        NSAlert(error: error).runModal()
                        return
                    }
                    if line > 0, let document = document as? CodeFileDocument {
                        document.openOptions = CodeFileDocument.OpenOptions(
                            cursorPositions: [CursorPosition(line: line, column: column > 0 ? column : 1)]
                        )
                    }
                }
        }
    }

    // MARK: - Should Terminate

    /// Defers the application terminate message until we've finished cleanup.
    ///
    /// All paths _must_ call `NSApplication.shared.reply(toApplicationShouldTerminate: true)` as soon as possible.
    ///
    /// The two things needing deferring are:
    /// - Language server cancellation
    /// - Outstanding document changes.
    ///
    /// Things that don't need deferring (happen immediately):
    /// - Task termination.
    /// These are called immediately if no documents need closing, and are called by
    /// ``documentController(_:didCloseAll:contextInfo:)`` if there are documents we need to defer for.
    ///
    /// See ``terminateLanguageServers()`` and ``documentController(_:didCloseAll:contextInfo:)`` for deferring tasks.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let projects: [String] = CodeEditDocumentController.shared.documents
            .compactMap { ($0 as? WorkspaceDocument)?.fileURL?.path }

        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)

        let areAllDocumentsClean = CodeEditDocumentController.shared.documents.allSatisfy { !$0.isDocumentEdited }
        guard areAllDocumentsClean else {
            CodeEditDocumentController.shared.closeAllDocuments(
                withDelegate: self,
                didCloseAllSelector: #selector(documentController(_:didCloseAll:contextInfo:)),
                contextInfo: nil
            )
            // `documentController(_:didCloseAll:contextInfo:)` will call `terminateLanguageServers()`
            return .terminateLater
        }

        terminateTasks()
        terminateLanguageServers()
        return .terminateLater
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Open windows

    @IBAction private func openWelcome(_ sender: Any) {
        openWindow(sceneID: .welcome)
    }

    @IBAction private func openAbout(_ sender: Any) {
        openWindow(sceneID: .about)
    }

    @IBAction func openFeedback(_ sender: Any) {
        if tryFocusWindow(of: FeedbackView.self) { return }

        FeedbackView().showWindow()
    }

    @IBAction private func checkForUpdates(_ sender: Any) {
        updater.checkForUpdates()
    }

    /// Tries to focus a window with specified view content type.
    /// - Parameter type: The type of viewContent which hosted in a window to be focused.
    /// - Returns: `true` if window exist and focused, otherwise - `false`
    private func tryFocusWindow<T: View>(of type: T.Type) -> Bool {
        guard let window = NSApp.windows.filter({ ($0.contentView as? NSHostingView<T>) != nil }).first
        else { return false }

        window.makeKeyAndOrderFront(self)
        return true
    }

    /// Tries to focus a window with specified sceneId
    /// - Parameter type: Id of a window to be focused.
    /// - Returns: `true` if window exist and focused, otherwise - `false`
    private func tryFocusWindow(id: SceneID) -> Bool {
        guard let window = NSApp.windows.filter({ $0.identifier?.rawValue == id.rawValue }).first
        else { return false }

        window.makeKeyAndOrderFront(self)
        return true
    }

    // MARK: - Open With CodeEdit (Extension) functions
    private func checkForFilesToOpen() {
        guard let defaults = UserDefaults.init(
            suiteName: "app.codeedit.CodeEdit.shared"
        ) else {
            print("Failed to get/init shared defaults")
            return
        }

        // Register enableOpenInCE (enable Open In CodeEdit
        defaults.register(defaults: ["enableOpenInCE": true])

        if let filesToOpen = defaults.string(forKey: "openInCEFiles") {
            let files = filesToOpen.split(separator: ";")

            for filePath in files {
                let fileURL = URL(fileURLWithPath: String(filePath))
                CodeEditDocumentController.shared.reopenDocument(
                    for: fileURL,
                    withContentsOf: fileURL,
                    display: true
                ) { document, _, _ in
                    document?.windowControllers.first?.synchronizeWindowTitleWithDocumentName()
                }
            }

            defaults.removeObject(forKey: "openInCEFiles")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.checkForFilesToOpen()
        }
    }

    /// Enable window size restoring on app relaunch after quitting.
    private func enableWindowSizeSaveOnQuit() {
        // This enables window restoring on normal quit (instead of only on force-quit).
        UserDefaults.standard.setValue(true, forKey: "NSQuitAlwaysKeepsWindows")
    }

    // MARK: NSDocumentController delegate

    @objc
    func documentController(_ docController: NSDocumentController, didCloseAll: Bool, contextInfo: Any) {
        if didCloseAll {
            terminateTasks()
            terminateLanguageServers()
        }
    }

    /// Terminates running language servers. Used during app termination to ensure resources are freed.
    private func terminateLanguageServers() {
        Task { @MainActor in
            let task = TaskNotificationModel(
                id: "appdelegate.terminate_language_servers",
                title: "Stopping Language Servers",
                message: "Stopping running language server processes...",
                isLoading: true
            )

            if !lspService.languageClients.isEmpty {
                TaskNotificationHandler.postTask(action: .create, model: task)
            }

            try? await withTimeout(
                duration: .seconds(2.0),
                onTimeout: {
                    // Stop-gap measure to ensure we don't hang on CMD-Q
                    await self.lspService.killAllServers()
                },
                operation: {
                    await self.lspService.stopAllServers()
                }
            )

            TaskNotificationHandler.postTask(action: .delete, model: task)
            NSApplication.shared.reply(toApplicationShouldTerminate: true)
        }
    }

    /// Terminates all running tasks. Used during app termination to ensure resources are freed.
    private func terminateTasks() {
        let task = TaskNotificationModel(
            id: "appdelegate.terminate_tasks",
            title: "Terminating Tasks",
            message: "Interrupting all running tasks before quitting...",
            isLoading: true
        )

        let taskManagers = CodeEditDocumentController.shared.documents
            .compactMap({ $0 as? WorkspaceDocument })
            .compactMap({ $0.taskManager })

        if taskManagers.reduce(0, { $0 + $1.activeTasks.count }) > 0 {
            TaskNotificationHandler.postTask(action: .create, model: task)
        }

        taskManagers.forEach { manager in
            manager.stopAllTasks()
        }

        TaskNotificationHandler.postTask(action: .delete, model: task)
    }
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}
