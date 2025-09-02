//
//  CodeEditDocumentController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Cocoa
import SwiftUI
import WelcomeWindow

final class CodeEditDocumentController: NSDocumentController {
    @Environment(\.openWindow)
    private var openWindow

    @Service var lspService: LSPService

    private let fileManager = FileManager.default

    @MainActor
    func createAndOpenNewDocument(onCompletion: @escaping () -> Void) {
        guard let newDocumentUrl = self.newDocumentUrl else { return }

        let createdFile = self.fileManager.createFile(
            atPath: newDocumentUrl.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )

        guard createdFile else {
            print("Failed to create new document")
            return
        }

        self.openDocument(withContentsOf: newDocumentUrl, display: true) { _, _, _ in
            onCompletion()
        }
    }

    override func newDocument(_ sender: Any?) {
        guard let newDocumentUrl = self.newDocumentUrl else { return }

        let createdFile = self.fileManager.createFile(
            atPath: newDocumentUrl.path,
            contents: nil,
            attributes: [FileAttributeKey.creationDate: Date()]
        )
        guard createdFile else {
            print("Failed to create new document")
            return
        }

        self.openDocument(withContentsOf: newDocumentUrl, display: true) { _, _, _ in }
    }

    private var newDocumentUrl: URL? {
        let panel = NSSavePanel()
        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }

    override func openDocument(_ sender: Any?) {
        self.openDocument(onCompletion: { document, documentWasAlreadyOpen in
            // TODO: handle errors

            guard let document else {
                print("Failed to unwrap document")
                return
            }

            print(document, documentWasAlreadyOpen)
        }, onCancel: {})
    }

    override func openDocument(
        withContentsOf url: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void
    ) {
        guard !openFileInExistingWorkspace(url: url) else {
            return
        }

        super.openDocument(withContentsOf: url, display: displayDocument) { document, documentWasAlreadyOpen, error in
            MainActor.assumeIsolated {
                if let document {
                    self.addDocument(document)
                } else {
                    let errorMessage = error?.localizedDescription ?? "unknown error"
                    print("Unable to open document '\(url)': \(errorMessage)")
                }

                RecentsStore.documentOpened(at: url)
                completionHandler(document, documentWasAlreadyOpen, error)
            }
        }
    }

    /// Attempt to open the file URL in an open workspace, finding the nearest workspace to open it in if possible.
    /// - Parameter url: The file URL to open.
    /// - Returns: True, if the document was opened in a workspace.
    private func openFileInExistingWorkspace(url: URL) -> Bool {
        guard !url.isFolder else { return false }
        let workspaces = documents.compactMap({ $0 as? WorkspaceDocument })

        // Check open workspaces for the file being opened. Sorted by shared components with the url so we
        // open the nearest workspace possible.
        for workspace in workspaces.sorted(by: {
            ($0.fileURL?.sharedComponents(url) ?? 0) > ($1.fileURL?.sharedComponents(url) ?? 0)
        }) {
            // createIfNotFound will still return `nil` if the files don't share a common ancestor.
            if let newFile = workspace.workspaceFileManager?.getFile(url.absolutePath, createIfNotFound: true) {
                workspace.editorManager?.openTab(item: newFile)
                workspace.showWindows()
                return true
            }
        }
        return false
    }

    override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)

        if let workspace = document as? WorkspaceDocument, let path = workspace.fileURL?.absoluteURL.path() {
            lspService.closeWorkspace(path)
        }

        if CodeEditDocumentController.shared.documents.isEmpty {
            switch Settings[\.general].reopenWindowAfterClose {
            case .showWelcomeWindow:
                // Opens the welcome window
                openWindow(sceneID: .welcome)
            case .quit:
                // Quits CodeEdit
                NSApplication.shared.terminate(nil)
            case .doNothing: break
            }
        }
    }
}

extension NSDocumentController {
    final func openDocument(onCompletion: @escaping (NSDocument?, Bool) -> Void, onCancel: @escaping () -> Void) {
        let dialog = NSOpenPanel()

        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true

        dialog.begin { result in
            if result ==  NSApplication.ModalResponse.OK, let url = dialog.url {
                self.openDocument(withContentsOf: url, display: true) { document, documentWasAlreadyOpen, error in
                    if let error {
                        NSAlert(error: error).runModal()
                        return
                    }

                    guard let document else {
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString(
                            "Failed to get document",
                            comment: "Failed to get document"
                        )
                        alert.runModal()
                        return
                    }
                    onCompletion(document, documentWasAlreadyOpen)
                    print("Document:", document)
                    print("Was already open?", documentWasAlreadyOpen)
                }
            } else if result == NSApplication.ModalResponse.cancel {
                onCancel()
            }
        }
    }
}
