//
//  CodeEditWindowController.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 18.03.22.
//

import Cocoa

class CodeEditWindowController: NSWindowController {
    
    var workspace: WorkspaceDocument?

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    @IBAction func saveDocument(_ sender: Any) {
        guard let id = workspace?.selectedId else { return }
        guard let item = workspace?.openFileItems.first(where: { item in
            return item.id == id
        }) else { return }
        guard let file = workspace?.openedCodeFiles[item] else { return }
        file.save(sender)
    }

}
