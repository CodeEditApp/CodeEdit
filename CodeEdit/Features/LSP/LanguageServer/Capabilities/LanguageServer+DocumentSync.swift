//
//  LanguageServer+DocumentSync.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Tells the language server we've opened a document and would like to begin working with it.
    /// - Parameter document: The code document to open.
    /// - Throws: Throws errors produced by the language server connection.
    func openDocument(_ document: DocumentType) async throws {
        do {
            guard resolveOpenCloseSupport(), let content = await getIsolatedDocumentContent(document) else {
                return
            }
            logger.debug("Opening Document \(content.uri, privacy: .private)")

            openFiles.addDocument(document, for: self)

            let textDocument = TextDocumentItem(
                uri: content.uri,
                languageId: content.language,
                version: 0,
                text: content.string
            )
            try await lspInstance.textDocumentDidOpen(DidOpenTextDocumentParams(textDocument: textDocument))

            await updateIsolatedDocument(document)
        } catch {
            logger.warning("addDocument: Error \(error)")
            throw error
        }
    }

    /// Stops tracking a file and notifies the language server.
    /// - Parameter uri: The URI of the document to close.
    /// - Throws: Throws errors produced by the language server connection.
    func closeDocument(_ uri: String) async throws {
        do {
            guard resolveOpenCloseSupport(), let document = openFiles.document(for: uri) else { return }
            logger.debug("Closing document \(uri, privacy: .private)")

            openFiles.removeDocument(for: uri)
            await clearIsolatedDocument(document)

            let params = DidCloseTextDocumentParams(textDocument: TextDocumentIdentifier(uri: uri))
            try await lspInstance.textDocumentDidClose(params)
        } catch {
            logger.warning("closeDocument: Error \(error)")
            throw error
        }
    }

    /// Represents a single document edit event.
    public struct DocumentChange: Sendable {
        let range: LSPRange
        let string: String

        init(replacingContentsIn range: LSPRange, with string: String) {
            self.range = range
            self.string = string
        }
    }

    /// Updates the document with the specified URI with new text and increments its version.
    ///
    /// This API accepts an array of changes to allow for grouping change notifications.
    /// This is advantageous for full document changes as we reduce the number of times we send the entire document.
    /// It also lowers some communication overhead when sending lots of changes very quickly due to sending them all in
    /// one request.
    ///
    /// - Parameters:
    ///   - uri: The URI of the document to update.
    ///   - changes: An array of accumulated changes. It's suggested to throttle change notifications and send them
    ///              in groups.
    /// - Throws: Throws errors produced by the language server connection.
    func documentChanged(uri: String, changes: [DocumentChange]) async throws {
        do {
            logger.debug("Document updated, \(uri, privacy: .private)")
            guard let document = openFiles.document(for: uri) else { return }

            switch resolveDocumentSyncKind() {
            case .full:
                guard let content = await getIsolatedDocumentContent(document) else {
                    logger.error("Failed to get isolated document content")
                    return
                }
                let changeEvent = TextDocumentContentChangeEvent(range: nil, rangeLength: nil, text: content.string)
                try await lspInstance.textDocumentDidChange(
                    DidChangeTextDocumentParams(uri: uri, version: 0, contentChange: changeEvent)
                )
            case .incremental:
                let fileVersion = openFiles.incrementVersion(for: uri)
                let changeEvents = changes.map {
                    // rangeLength is depreciated in the LSP spec.
                    TextDocumentContentChangeEvent(range: $0.range, rangeLength: nil, text: $0.string)
                }
                try await lspInstance.textDocumentDidChange(
                    DidChangeTextDocumentParams(uri: uri, version: fileVersion, contentChanges: changeEvents)
                )
            case .none:
                return
            }

            // Let the semantic token provider know about the update.
            // Note for future: If a related LSP object need notifying about document changes, do it here.
            try await document.languageServerObjects.highlightProvider.documentDidChange()
        } catch {
            logger.warning("closeDocument: Error \(error)")
            throw error
        }
    }

    // MARK: File Private Helpers

    /// Helper function for grabbing a document's content from the main actor.
    @MainActor
    private func getIsolatedDocumentContent(_ document: DocumentType) -> DocumentContent? {
        guard let uri = document.languageServerURI,
              let content = document.content?.string else {
            return nil
        }
        return DocumentContent(uri: uri, language: document.getLanguage().id.rawValue, string: content)
    }

    @MainActor
    private func updateIsolatedDocument(_ document: DocumentType) {
        document.languageServerObjects.setUp(server: self, document: document)
    }

    @MainActor
    private func clearIsolatedDocument(_ document: DocumentType) {
        document.languageServerObjects = LanguageServerDocumentObjects()
    }

    // swiftlint:disable line_length
    /// Determines the type of document sync the server supports.
    /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_synchronization_sc
    fileprivate func resolveDocumentSyncKind() -> TextDocumentSyncKind {
        // swiftlint:enable line_length
        var syncKind: TextDocumentSyncKind = .none
        switch serverCapabilities.textDocumentSync {
        case .optionA(let options): // interface TextDocumentSyncOptions
            syncKind = options.change ?? .none
        case .optionB(let kind): // interface TextDocumentSyncKind
            syncKind = kind
        default:
            syncKind = .none
        }
        return syncKind
    }

    /// Determines whether or not the server supports document tracking.
    fileprivate func resolveOpenCloseSupport() -> Bool {
        switch serverCapabilities.textDocumentSync {
        case .optionA(let options): // interface TextDocumentSyncOptions
            return options.openClose ?? false
        case .optionB: // interface TextDocumentSyncKind
            return true
        default:
            return true
        }
    }

    // Used to avoid a lint error (`large_tuple`) for the return type of `getIsolatedDocumentContent`
    fileprivate struct DocumentContent {
        let uri: String
        let language: String
        let string: String
    }
}
