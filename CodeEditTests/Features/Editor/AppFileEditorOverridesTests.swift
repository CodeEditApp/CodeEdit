//
//  AppFileEditorOverridesTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Testing
import CodeEditCore
import CEWorkspaceFileManager
import CodeEditDocument
@testable import CEEditor
import CodeEditLanguages
@testable import CodeEdit

@Suite
struct AppFileEditorOverridesTests {
    @MainActor
    @Test
    func readsAndWritesDocumentOverrides() {
        let editorManager = EditorManager()
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/a.swift"))
        let document = CodeFileDocument()
        editorManager.documents.setDocument(document, for: file)

        let overrides = AppFileEditorOverrides(editorManager: editorManager)

        // No overrides set yet.
        #expect(overrides.overrides(for: file).indentOption == nil)

        // Writes propagate to the document.
        let indent = IndentOption(indentType: .spaces, spaceCount: 8)
        overrides.setIndentOption(indent, for: file)
        overrides.setDefaultTabWidth(3, for: file)
        overrides.setWrapLines(true, for: file)
        #expect(document.indentOption == indent)
        #expect(document.defaultTabWidth == 3)
        #expect(document.wrapLines == true)

        // Reads reflect the document.
        let values = overrides.overrides(for: file)
        #expect(values.indentOption == indent)
        #expect(values.defaultTabWidth == 3)
        #expect(values.wrapLines == true)

        _ = document // registry holds documents weakly; keep alive for the test
    }

    @MainActor
    @Test
    func languageIdRoundTrips() {
        let editorManager = EditorManager()
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/a.swift"))
        let document = CodeFileDocument()
        editorManager.documents.setDocument(document, for: file)
        let overrides = AppFileEditorOverrides(editorManager: editorManager)

        guard let swift = CodeLanguage.allLanguages.first(where: { $0.id.rawValue == "swift" }) else {
            Issue.record("swift language not found in allLanguages")
            return
        }

        overrides.setLanguageId(swift.id.rawValue, for: file)
        #expect(document.language?.id.rawValue == "swift")
        #expect(overrides.overrides(for: file).languageId == "swift")

        overrides.setLanguageId(nil, for: file)
        #expect(document.language == nil)
        #expect(overrides.overrides(for: file).languageId == nil)

        _ = document
    }

    @MainActor
    @Test
    func noDocumentYieldsEmptyOverridesAndNoOpWrites() {
        let editorManager = EditorManager()
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/none.swift"))
        let overrides = AppFileEditorOverrides(editorManager: editorManager)

        #expect(overrides.overrides(for: file) == FileEditorOverrideValues())
        overrides.setIndentOption(IndentOption(indentType: .tab), for: file) // no crash
        #expect(overrides.overrides(for: file).indentOption == nil)
    }
}
