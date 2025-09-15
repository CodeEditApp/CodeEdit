//
//  OpenQuicklyPreviewView.swift
//  CodeEditModules/QuickOpen
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI

struct OpenQuicklyPreviewView: View {

    private let queue = DispatchQueue(label: "app.codeedit.CodeEdit.quickOpen.preview")
    private let item: CEWorkspaceFile

    @StateObject var editorInstance: EditorInstance
    @StateObject var document: CodeFileDocument

    @StateObject var undoRegistration: UndoManagerRegistration = UndoManagerRegistration()

    init(item: CEWorkspaceFile) {
        self.item = item
        let doc = try? CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: item.contentType?.identifier ?? "public.source-code"
        )
        self._editorInstance = .init(wrappedValue: EditorInstance(workspace: nil, file: item))
        self._document = .init(wrappedValue: doc ?? .init())
    }

    var body: some View {
        if let utType = document.utType, utType.conforms(to: .text) {
            CodeFileView(editorInstance: editorInstance, codeFile: document, isEditable: false)
                .environmentObject(undoRegistration)
        } else {
            NonTextFileView(fileDocument: document)
        }
    }
}
