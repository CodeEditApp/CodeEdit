//
//  AppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import Combine
import SwiftUI
import Factory
import CodeEditCore
import CodeEditSymbols
import CodeEditSourceEditor
import OSLog

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "AppDelegate")
    private let updater = SoftwareUpdater()

    @Environment(\.openWindow)
    var openWindow

    @LazyInjected(\.lspService)
    var lspService

    @LazyInjected(\.workspaceWindowManager)
    var windowManager

    @LazyInjected(\.eventBus)
    var eventBus

    private let shutdownUseCase = ShutdownApplicationUseCase()

    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        CodeFileDocument.isAutoSaveOnProvider = {
            Settings.shared.preferences.general.isAutoSaveOn
        }
        enableWindowSizeSaveOnQuit()
        Settings.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()

        // Subscribe to the welcome window event published by WorkspaceWindowManager
        eventBus.subscribe(WelcomeWindowRequestedEvent.self)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.openWindow(sceneID: .welcome) }
            .store(in: &cancellables)

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

                    do {
                        try self.windowManager.openWorkspace(at: url)
                    } catch {
                        self.logger.error("Failed to open workspace at \(path): \(error.localizedDescription)")
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
        cancellables.removeAll()
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
            windowManager.openDocumentFromPanel()
        case .newDocument:
            windowManager.newDocumentFromPanel()
        }
    }

    /// Handle urls with the form `codeedit://file/{filepath}:{line}:{column}`
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            let file = URL(fileURLWithPath: url.path).path.split(separator: ":")
            let filePath = URL(fileURLWithPath: String(file[0]))
            let line = file.count > 1 ? Int(file[1]) ?? 0 : 0
            let column = file.count > 2 ? Int(file[2]) ?? 1 : 1

            do {
                if filePath.isFolder {
                    try windowManager.openWorkspace(at: filePath)
                } else if !windowManager.openFileInWorkspace(url: filePath) {
                    // Standalone file — open via NSDocumentController (for CodeFileDocument)
                    NSDocumentController.shared
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
            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }

    // MARK: - Should Terminate

    /// Defers the application terminate message until we've finished cleanup.
    ///
    /// All paths _must_ call `NSApplication.shared.reply(toApplicationShouldTerminate: true)` as soon as possible.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard shutdownUseCase.execute() else {
            return .terminateCancel
        }

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
                do {
                    try windowManager.openWorkspace(at: fileURL)
                } catch {
                    logger.error("Failed to open \(filePath): \(error.localizedDescription)")
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
                eventBus.publish(TaskNotificationEvent(.create(task)))
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

            eventBus.publish(TaskNotificationEvent(.delete(id: task.id)))
            NSApplication.shared.reply(toApplicationShouldTerminate: true)
        }
    }

}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}
