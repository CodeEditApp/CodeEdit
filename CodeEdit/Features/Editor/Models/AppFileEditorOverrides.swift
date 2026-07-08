//
//  AppFileEditorOverrides.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditCore
import CodeEditLanguages
import CodeEditDocument

/// App-side `FileEditorOverrides` over a window's `EditorManager`. Reads and writes
/// the per-file overrides on the file's open `CodeFileDocument`, translating the
/// language override to/from `CodeLanguage.id.rawValue`.
final class AppFileEditorOverrides: FileEditorOverrides {
    private let editorManager: EditorManager

    @MainActor
    init(editorManager: EditorManager) {
        self.editorManager = editorManager
    }

    @MainActor
    func overrides(for file: CEWorkspaceFile) -> FileEditorOverrideValues {
        let document = editorManager.document(for: file)
        return FileEditorOverrideValues(
            indentOption: document?.indentOption,
            defaultTabWidth: document?.defaultTabWidth,
            wrapLines: document?.wrapLines,
            languageId: document?.language?.id.rawValue
        )
    }

    @MainActor
    func setIndentOption(_ value: IndentOption?, for file: CEWorkspaceFile) {
        editorManager.document(for: file)?.indentOption = value
    }

    @MainActor
    func setDefaultTabWidth(_ value: Int?, for file: CEWorkspaceFile) {
        editorManager.document(for: file)?.defaultTabWidth = value
    }

    @MainActor
    func setWrapLines(_ value: Bool?, for file: CEWorkspaceFile) {
        editorManager.document(for: file)?.wrapLines = value
    }

    @MainActor
    func setLanguageId(_ value: String?, for file: CEWorkspaceFile) {
        editorManager.document(for: file)?.language = value.flatMap { id in
            CodeLanguage.allLanguages.first { $0.id.rawValue == id }
        }
    }
}
