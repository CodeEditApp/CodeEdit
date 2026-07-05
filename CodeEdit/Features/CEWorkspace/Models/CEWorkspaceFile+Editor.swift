//
//  CEWorkspaceFile+Editor.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import SwiftUI
import Combine
import CodeEditCore

extension CEWorkspaceFile: EditorTabRepresentable {
    /// The `id` in `EditorTabID` form.
    var tabID: EditorTabID { .codeEditor(id) }

    /// The file's open document, if any. Bridges the Core type-erased ``fileDocumentObject``.
    var fileDocument: CodeFileDocument? {
        get { fileDocumentObject as? CodeFileDocument }
        set { fileDocumentObject = newValue }
    }

    /// Publisher for ``fileDocument``.
    var fileDocumentPublisher: AnyPublisher<CodeFileDocument?, Never> {
        fileDocumentObjectPublisher.map { $0 as? CodeFileDocument }.eraseToAnyPublisher()
    }

    /// Loads ``fileDocument`` with a new `CodeFileDocument`.
    func loadCodeFile() throws {
        let codeFile = try CodeFileDocument(contentsOf: resolvedURL, ofType: contentType?.identifier ?? "")
        self.fileDocument = codeFile
    }
}
