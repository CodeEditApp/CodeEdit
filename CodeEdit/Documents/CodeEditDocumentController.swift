//
//  CodeEditDocumentController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 17.03.22.
//

import Cocoa

class CodeEditDocumentController: NSDocumentController {
    override func openDocument(_ sender: Any?) {
        print("Opening")
        
        let dialog = NSOpenPanel()

        dialog.title = "Open Workspace or File"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true

        dialog.begin { result in
            if result ==  NSApplication.ModalResponse.OK, let url = dialog.url {
                self.openDocument(withContentsOf: url, display: true) { document, documentWasAlreadyOpen, err in
                    // TODO: handle errors
                    
                    print(document, documentWasAlreadyOpen, err)
                }
            }
        }
    }
}
