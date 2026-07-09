//
//  FilePreviewView.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 2026/07/09.
//

import SwiftUI
import CodeEditDocument
import CodeEditCore

struct FilePreviewView: View {
    private let item: CEWorkspaceFile

    @StateObject private var editorInstance: EditorInstance
    @StateObject private var document: CodeFileDocument
    @StateObject private var undoRegistration = UndoManagerRegistration()

    init(item: CEWorkspaceFile) {
        self.item = item
        let doc = try? CodeFileDocument(
            for: item.url,
            withContentsOf: item.url,
            ofType: item.contentType?.identifier ?? "public.source-code"
        )
        self._editorInstance = .init(wrappedValue: EditorInstance(findReplaceQuery: nil, file: item))
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
