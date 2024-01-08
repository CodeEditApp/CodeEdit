//
//  AppDelegate.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import CodeEditSourceEditor
import CodeEditSymbols

final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private let updater = SoftwareUpdater()

    func applicationDidFinishLaunching(_ notification: Notification) {
        enableWindowSizeSaveOnQuit()
        Settings.shared.preferences.general.appAppearance.applyAppearance()
        checkForFilesToOpen()

        NSApp.closeWindow(.welcome, .about)

        DispatchQueue.main.async {
            let wereFilesOpened = CommandLine.openArgumentFiles()

            if !wereFilesOpened {
                self.handleOpen()
            }

            // Apply UI testing modifications
            #if DEBUG
            CommandLine.useUITestModifiers()
            #endif
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        }

        handleOpen()

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
                NSApp.openWindow(.welcome)
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
                        document.cursorPositions = [CursorPosition(line: line, column: column > 0 ? column : 1)]
                    }
                }
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let projects: [String] = CodeEditDocumentController.shared.documents
            .map { doc in
                (doc as? WorkspaceDocument)?.fileURL?.path
            }
            .filter { $0 != nil }
            .map { $0! }

        UserDefaults.standard.set(projects, forKey: AppDelegate.recoverWorkspacesKey)

        let areAllDocumentsClean = CodeEditDocumentController.shared.documents.allSatisfy { !$0.isDocumentEdited }
        guard areAllDocumentsClean else {
            CodeEditDocumentController.shared.closeAllDocuments(
                withDelegate: self,
                didCloseAllSelector: #selector(documentController(_:didCloseAll:contextInfo:)),
                contextInfo: nil
            )
            return .terminateLater
        }

        return .terminateNow
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // MARK: - Open windows

    @IBAction private func openWelcome(_ sender: Any) {
        NSApp.openWindow(.welcome)
    }

    @IBAction private func openAbout(_ sender: Any) {
        NSApp.openWindow(.about)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.checkForFilesToOpen()
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
        NSApplication.shared.reply(toApplicationShouldTerminate: didCloseAll)
    }
}

extension AppDelegate {
    static let recoverWorkspacesKey = "recover.workspaces"
}
