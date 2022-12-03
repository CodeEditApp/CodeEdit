//
//  CodeEditDocumentController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Cocoa

final class CodeEditDocumentController: NSDocumentController {
    override func openDocument(_ sender: Any?) {
        self.openDocument(onCompletion: { document, documentWasAlreadyOpen in
            // TODO: handle errors

            guard let document = document else {
                print("Failed to unwrap document")
                return
            }

            print(document, documentWasAlreadyOpen)
        }, onCancel: {})
    }

    override func openDocument(withContentsOf url: URL,
                               display displayDocument: Bool,
                               completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        super.openDocument(withContentsOf: url, display: displayDocument) { document, documentWasAlreadyOpen, error in

            if let document = document {
                self.addDocument(document)
            }
            self.updateRecent(url)
            completionHandler(document, documentWasAlreadyOpen, error)
        }
    }

    override func removeDocument(_ document: NSDocument) {
        super.removeDocument(document)

        if CodeEditDocumentController.shared.documents.isEmpty {
            WelcomeWindowView.openWelcomeWindow()
        }
    }

    override func clearRecentDocuments(_ sender: Any?) {
        super.clearRecentDocuments(sender)
        UserDefaults.standard.set([], forKey: "recentProjectPaths")
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
                    if let error = error {
                        NSAlert(error: error).runModal()
                        return
                    }

                    guard let document = document else {
                        let alert = NSAlert()
                        alert.messageText = NSLocalizedString("Failed to get document",
                                                              comment: "Failed to get document")
                        alert.runModal()
                        return
                    }
                    self.updateRecent(url)
                    onCompletion(document, documentWasAlreadyOpen)
                    print("Document:", document)
                    print("Was already open?", documentWasAlreadyOpen)
                }
            } else if result == NSApplication.ModalResponse.cancel {
                onCancel()
            }
        }
    }

    final func updateRecent(_ url: URL) {
        var recentProjectPaths: [String] = UserDefaults.standard.array(
            forKey: "recentProjectPaths"
        ) as? [String] ?? []
        if let containedIndex = recentProjectPaths.firstIndex(of: url.path) {
            recentProjectPaths.move(fromOffsets: IndexSet(integer: containedIndex), toOffset: 0)
        } else {
            recentProjectPaths.insert(url.path, at: 0)
        }
        UserDefaults.standard.set(recentProjectPaths, forKey: "recentProjectPaths")
    }
}
