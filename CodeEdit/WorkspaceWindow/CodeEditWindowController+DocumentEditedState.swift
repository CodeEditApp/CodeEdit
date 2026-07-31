//
//  CodeEditWindowController+DocumentEditedState.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 31/07/26.
//

import SwiftUI
import Combine

extension CodeEditWindowController {
    // Listen to changes in all tabs/files
    internal func listenToDocumentEdited(workspace: Workspace) {
        let editorManager = workspace.editorManager
        editorManager.$activeEditor
            .flatMap({ editor in
                editor.$tabs
            })
            .compactMap({ tab in
                Publishers.MergeMany(tab.elements.map({ editorManager.documentPublisher(for: $0.file) }))
            })
            .switchToLatest()
            .compactMap({ fileDocument in
                fileDocument?.isDocumentEditedPublisher
            })
            .flatMap({ $0 })
            .sink { isDocumentEdited in
                if isDocumentEdited {
                    self.setDocumentEdited(true)
                    return
                }

                self.updateDocumentEdited(workspace: workspace)
            }
            .store(in: &cancellables)

        // Listen to change of tabs, if closed tab without saving content,
        // we also need to recalculate isDocumentEdited
        editorManager.$activeEditor
            .flatMap({ editor in
                editor.$tabs
            })
            .sink { _ in
                self.updateDocumentEdited(workspace: workspace)
            }
            .store(in: &cancellables)
    }

    // Recalculate documentEdited by checking if any tab/file is edited
    private func updateDocumentEdited(workspace: Workspace) {
        let editorManager = workspace.editorManager
        let hasEditedDocuments = !editorManager
            .editorLayout
            .gatherOpenFiles()
            .filter({ editorManager.document(for: $0)?.isDocumentEdited == true })
            .isEmpty
        self.setDocumentEdited(hasEditedDocuments)
    }
}
