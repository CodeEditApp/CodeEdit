//
//  CodeEditDocumentController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Cocoa

class CodeEditDocumentController: NSDocumentController {
    override func openDocument(_ sender: Any?) {
        self.openDocument { document, documentWasAlreadyOpen in
            // TODO: handle errors

            guard let document = document else {
                print("Failed to unwrap document")
                return
            }

            print(document, documentWasAlreadyOpen)
        }
    }
}

extension NSDocumentController {
    func openDocument(completionHandler: @escaping (NSDocument?, Bool) -> Void) {
        let dialog = NSOpenPanel()

        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true

        dialog.begin { result in
            if result ==  NSApplication.ModalResponse.OK, let url = dialog.url {
                self.openDocument(withContentsOf: url, display: true) { document, documentWasAlreadyOpen, error in
                    // TODO: handle errors
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }

                    guard let document = document else {
                        print("Error: Failed to get document")
                        return
                    }
                    var recentProjectPaths: [String] = UserDefaults.standard.array(
                        forKey: "recentProjectPaths"
                    ) as? [String] ?? []
                    if let containedIndex = recentProjectPaths.firstIndex(of: url.path) {
                        recentProjectPaths.move(fromOffsets: IndexSet(integer: containedIndex), toOffset: 0)
                    } else {
                        recentProjectPaths.insert(url.path, at: 0)
                    }
                    UserDefaults.standard.set(recentProjectPaths, forKey: "recentProjectPaths")
                    completionHandler(document, documentWasAlreadyOpen)
                    print("Document:", document)
                    print("Was already open?", documentWasAlreadyOpen)
                }
            }
        }
    }
}
