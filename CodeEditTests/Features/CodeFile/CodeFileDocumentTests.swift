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
import CodeEditDocument
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
    func delegateConsultedForUndoOnReread() throws {
        let mock = MockDelegate()
        let previousProvider = CodeFileDocument.delegateProvider
        CodeFileDocument.delegateProvider = { mock }
        defer { CodeFileDocument.delegateProvider = previousProvider }

        try withCodeFile { codeFile in
            // First read happened in `withCodeFile` (content now loaded). A second read
            // takes the re-read branch, which consults the delegate for an undo manager.
            let data = Data("different contents".utf8)
            try codeFile.read(from: data, ofType: "public.source-code")
            #expect(codeFile.fileURL != nil && mock.undoRequestedURLs.contains(codeFile.fileURL!))
        }
    }

    @MainActor
    @Test
    func delegateReceivesOpenAndCloseNotifications() throws {
        let mock = MockDelegate()
        let previousProvider = CodeFileDocument.delegateProvider
        CodeFileDocument.delegateProvider = { mock }
        defer { CodeFileDocument.delegateProvider = previousProvider }

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

    @MainActor
    private func withCodeFile(_ operation: (CodeFileDocument) throws -> Void) throws {
        try withFile { fileURL in
            try defaultString.write(to: fileURL, atomically: true, encoding: .utf8)
            let codeFile = try CodeFileDocument(contentsOf: fileURL, ofType: "public.source-code")
            try operation(codeFile)
        }
    }

    @MainActor
    @Test
    func autosavesInPlaceReflectsProvider() {
        let original = CodeFileDocument.isAutoSaveOnProvider
        defer { CodeFileDocument.isAutoSaveOnProvider = original }

        CodeFileDocument.isAutoSaveOnProvider = { true }
        #expect(CodeFileDocument.autosavesInPlace == true)

        CodeFileDocument.isAutoSaveOnProvider = { false }
        #expect(CodeFileDocument.autosavesInPlace == false)
    }

    @MainActor
    @Test
    func indentOptionOverrideUsesCoreType() {
        let codeFile = CodeFileDocument()
        codeFile.indentOption = CodeEditCore.IndentOption(indentType: .spaces, spaceCount: 2)
        #expect(codeFile.indentOption?.indentType == .spaces)
        #expect(codeFile.indentOption?.spaceCount == 2)
    }

    @MainActor
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

    @MainActor
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

    @MainActor
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

    // Deliberately NOT @MainActor: `presentedItemDidChange` is a file-presenter callback that
    // performs `DispatchQueue.main.sync` internally, so it must be invoked off the main thread
    // (as NSFileCoordinator does in production). The document itself is created on main.
    @Test
    func loadsExternalUpdatesWithNoOutstandingChanges() async throws {
        try await withTempDir { dir in
            let fileURL = dir.appending(path: "file.swift")
            try defaultString.write(to: fileURL, atomically: true, encoding: .utf8)
            let codeFile = try await MainActor.run {
                try CodeFileDocument(contentsOf: fileURL, ofType: "public.source-code")
            }

            // Update the modification date
            try "different contents".write(to: fileURL, atomically: true, encoding: .utf8)

            // Tell the file the disk representation changed (off-main, like a real presenter callback)
            codeFile.presentedItemDidChange()

            // The file should have reloaded (it was clean)
            await MainActor.run {
                #expect(codeFile.content?.string == "different contents")
                #expect(codeFile.isDocumentEdited == false)
            }
        }
    }
}
