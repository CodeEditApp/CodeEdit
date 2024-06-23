//
//  LanguageServer+DocumentUtil.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    mutating func addDocument(_ fileURL: URL) async -> Bool {
        do {
            let docContent = try String(contentsOf: fileURL)
            let textDocument = TextDocumentItem(
                uri: fileURL.absoluteString,
                languageId: .rust,
                version: 0,
                text: docContent
            )
            return await self.addDocument(textDocument)
        } catch {
            print("addDocument: An error occurred: \(error)")
        }

        return false
    }

    /// Adds a TextDocumentItem to the tracked files and notifies the language server
    mutating func addDocument(_ document: TextDocumentItem) async -> Bool {
        do {
            // Keep track of the document
            trackedDocuments[document.uri] = document

            // Send notification to server about our opened file
            let params = DidOpenTextDocumentParams(textDocument: document)
            try await lspInstance.textDocumentDidOpen(params)
            return true
        } catch {
            print("addDocument: An error occurred: \(error)")
        }

        return false
    }

    /// Stops tracking a file and notifies the language server
    mutating func closeDocument(_ uri: String) async -> Bool {
        guard let document = trackedDocuments.removeValue(forKey: uri) else { return false }

        do {
            let params = DidCloseTextDocumentParams(textDocument:
                                                    TextDocumentIdentifier(uri: document.uri))
            try await lspInstance.textDocumentDidClose(params)
            return true
        } catch {
            print("closeDocument: An error occurred: \(error)")
        }
        return false
    }

    /// Updates the document with the specified URI with new text and increments its version.
    /// - Parameters:
    ///   - uri: The URI of the document to update.
    ///   - newText: The new text to be set for the document.
    /// - Returns: `true` if the document was successfully updated, `false`
    mutating func updateDocument(
        withUri uri: String,
        newText: String,
        range: LSPRange,
        rangeLength: Int
    ) async -> Bool {
        // Update the document objects values, including the version
        guard let currentDocument = trackedDocuments[uri],
              let nsRange = convertLSPRangeToNSRange(range, in: currentDocument.text),
              let stringRange = currentDocument.text.range(from: nsRange) else {
            // TODO: LOG HERE
            return false
        }

        // Update the document's content and increment the version.
        var updatedText = currentDocument.text
        updatedText.replaceSubrange(stringRange, with: newText)
        let updatedVersion = currentDocument.version + 1
        let updatedDocument = TextDocumentItem(
            uri: currentDocument.uri,
            languageId: currentDocument.languageId,
            version: updatedVersion,
            text: updatedText
        )
        trackedDocuments[uri] = updatedDocument

        // Notify the server
        do {
            let change = TextDocumentContentChangeEvent(
                range: range,
                rangeLength: rangeLength,
                text: newText
            )
            let params = DidChangeTextDocumentParams(
                textDocument: VersionedTextDocumentIdentifier(uri: uri, version: updatedVersion),
                contentChanges: [change]
            )
            try await lspInstance.textDocumentDidChange(params)
        } catch {
            print("updateDocument: An error occurred: \(error)")
        }
        return true
    }
}

fileprivate extension String {
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard let range = Range(nsRange, in: self) else { return nil }
        return range
    }
}

private func applyEditsToDocument(document: TextDocumentItem, edits: [TextEdit]) -> TextDocumentItem {
    // Sort edits in reverse order to prevent offset issues
    let sortedEdits = edits.sorted { $0.range.start > $1.range.start }
    var updatedText = document.text
    for edit in sortedEdits {
        // Apply each edit to the document text
        guard let nsRange = convertLSPRangeToNSRange(edit.range, in: updatedText),
              let range = updatedText.range(from: nsRange) else { continue }
        updatedText.replaceSubrange(range, with: edit.newText)
    }

    return TextDocumentItem(
        uri: document.uri,
        languageId: document.languageId,
        version: document.version,
        text: updatedText
    )
}

private func updateDocumentWithChanges(
    document: TextDocumentItem,
    changes: [TextDocumentContentChangeEvent]
) -> TextDocumentItem {
    var updatedText = document.text

    for change in changes {
        // Apply changes with range to the document text
        if let lspRange = change.range,
           let nsRange = convertLSPRangeToNSRange(lspRange, in: updatedText),
           let range = updatedText.range(from: nsRange) {
            updatedText.replaceSubrange(range, with: change.text)
        } else {
            // Replace the entire document text
            updatedText = change.text
        }
    }

    return TextDocumentItem(
        uri: document.uri,
        languageId: document.languageId,
        version: document.version,
        text: updatedText
    )
}

private func convertLSPRangeToNSRange(_ range: LSPRange, in text: String) -> NSRange? {
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)

    // Calculate the start index
    let startLineIndex = min(range.start.line, lines.count - 1)
    let startCharacterIndex = min(range.start.character, lines[startLineIndex].count)
    let startIndex = lines.prefix(startLineIndex).reduce(0, { $0 + $1.count + 1 }) + startCharacterIndex

    // Calculate the end index
    let endLineIndex = min(range.end.line, lines.count - 1)
    let endCharacterIndex = min(range.end.character, lines[endLineIndex].count)
    let endIndex = lines.prefix(endLineIndex).reduce(0, { $0 + $1.count + 1 }) + endCharacterIndex

    // Ensure the range is valid
    guard startIndex <= endIndex else { return nil }

    return NSRange(location: startIndex, length: endIndex - startIndex)
}
