//
//  CodeFileDocumentTests.swift
//  CodeEditModules/CodeFileTests
//
//  Created by Marco Carnevali on 18/03/22.
//

import Foundation
import SwiftUI
import AppKit
import Testing
import CodeEditCore
import Factory
import CodeEditTextView
@testable import CodeEdit

@Suite
struct CodeFileDocumentTests {
    let defaultString = "func test() { }"

    @MainActor
    final class MockDelegate: CodeFileDocumentDelegate {
        var openedDocuments: [CodeFileDocument] = []
        var closedURLs: [URL] = []
        var undoRequestedURLs: [URL] = []
        func undoManager(forFile url: URL) -> CEUndoManager? {
            undoRequestedURLs.append(url)
            return nil
        }
        func makeWindowContentView(for document: CodeFileDocument) -> NSView { NSView() }
        func documentDidOpen(_ document: CodeFileDocument) { openedDocuments.append(document) }
        func documentDidClose(at url: URL) { closedURLs.append(url) }
    }

    @MainActor
    @Test
    func delegateReceivesOpenAndCloseNotifications() throws {
        let mock = MockDelegate()
        Container.shared.codeFileDocumentDelegate.register { mock }
        defer { Container.shared.codeFileDocumentDelegate.reset() }

        try withCodeFile { codeFile in
            #expect(mock.openedDocuments.contains { $0 === codeFile })
            let url = codeFile.fileURL
            codeFile.close()
            #expect(url != nil && mock.closedURLs.contains(url!))
        }
    }

    private func withFile(_ operation: (URL) throws -> Void) throws {
        try withTempDir { dir in
            let fileURL = dir.appending(path: "file.swift")
            try operation(fileURL)
        }
    }

    private func withCodeFile(_ operation: (CodeFileDocument) throws -> Void) throws {
        try withFile { fileURL in
            try defaultString.write(to: fileURL, atomically: true, encoding: .utf8)
            let codeFile = try CodeFileDocument(contentsOf: fileURL, ofType: "public.source-code")
            try operation(codeFile)
        }
    }

    @Test
    func autosavesInPlaceReflectsProvider() {
        let original = CodeFileDocument.isAutoSaveOnProvider
        defer { CodeFileDocument.isAutoSaveOnProvider = original }

        CodeFileDocument.isAutoSaveOnProvider = { true }
        #expect(CodeFileDocument.autosavesInPlace == true)

        CodeFileDocument.isAutoSaveOnProvider = { false }
        #expect(CodeFileDocument.autosavesInPlace == false)
    }

    @Test
    func indentOptionOverrideUsesCoreType() {
        let codeFile = CodeFileDocument()
        codeFile.indentOption = CodeEditCore.IndentOption(indentType: .spaces, spaceCount: 2)
        #expect(codeFile.indentOption?.indentType == .spaces)
        #expect(codeFile.indentOption?.spaceCount == 2)
    }

    @Test
    func testLoadUTF8Encoding() throws {
        try withFile { fileURL in
            try defaultString.write(to: fileURL, atomically: true, encoding: .utf8)
            let codeFile = try CodeFileDocument(
                for: fileURL,
                withContentsOf: fileURL,
                ofType: "public.source-code"
            )
            #expect(codeFile.content?.string == defaultString)
            #expect(codeFile.sourceEncoding == .utf8)
        }
    }

    @Test
    func testWriteUTF8Encoding() throws {
        try withFile { fileURL in
            let codeFile = CodeFileDocument()
            codeFile.content = NSTextStorage(string: defaultString)
            codeFile.sourceEncoding = .utf8
            try codeFile.write(to: fileURL, ofType: "public.source-code")

            let data = try Data(contentsOf: fileURL)
            var nsString: NSString?
            let fileEncoding = NSString.stringEncoding(
                for: data,
                encodingOptions: [
                    .suggestedEncodingsKey: FileEncoding.allCases.map { $0.nsValue },
                    .useOnlySuggestedEncodingsKey: true
                ],
                convertedString: &nsString,
                usedLossyConversion: nil
            )

            #expect(codeFile.content?.string as NSString? == nsString)
            #expect(fileEncoding == NSUTF8StringEncoding)
        }
    }

    @Test
    func ignoresExternalUpdatesWithOutstandingChanges() throws {
        try withCodeFile { codeFile in
            // Mark the file dirty
            codeFile.updateChangeCount(.changeDone)

            // Update the modification date
            try "different contents".write(to: codeFile.fileURL!, atomically: true, encoding: .utf8)

            // Tell the file the disk representation changed
            codeFile.presentedItemDidChange()

            // The file should not have reloaded
            #expect(codeFile.content?.string == defaultString)
            #expect(codeFile.isDocumentEdited == true)
        }
    }

    @Test
    func loadsExternalUpdatesWithNoOutstandingChanges() throws {
        try withCodeFile { codeFile in
            // Update the modification date
            try "different contents".write(to: codeFile.fileURL!, atomically: true, encoding: .utf8)

            // Tell the file the disk representation changed
            codeFile.presentedItemDidChange()

            // The file should have reloaded (it was clean)
            #expect(codeFile.content?.string == "different contents")
            #expect(codeFile.isDocumentEdited == false)
        }
    }
}
