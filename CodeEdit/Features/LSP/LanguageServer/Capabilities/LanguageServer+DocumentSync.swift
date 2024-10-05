//
//  LanguageServer+DocumentSync.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    // swiftlint:disable line_length
    /// Determines the type of document sync the server supports.
    /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_synchronization_sc
    fileprivate func resolveDocumentSyncKind() -> TextDocumentSyncKind {
        // swiftlint:enable line_length
        var syncKind: TextDocumentSyncKind = .none
        switch serverCapabilities.textDocumentSync {
        case .optionA(let options):
            syncKind = options.change ?? .none
        case .optionB(let kind):
            syncKind = kind
        default:
            syncKind = .none
        }
        return syncKind
    }

    /// Determines whether or not the server supports document tracking.
    fileprivate func resolveOpenCloseSupport() -> Bool {
        switch serverCapabilities.textDocumentSync {
        case .optionA(let options):
            return options.openClose ?? false
        case .optionB:
            return true
        default:
            return true
        }
    }

    // Used to avoid a lint error (`large_tuple`) for the return type of `getIsolatedDocumentContent`
    fileprivate struct DocumentContent {
        let uri: String
        let language: LanguageIdentifier
        let content: String
    }

    /// Tells the language server we've opened a document and would like to begin working with it.
    /// - Parameter document: The code document to open.
    /// - Throws: Throws errors produced by the language server connection.
    func openDocument(_ document: CodeFileDocument) async throws {
        do {
            guard resolveOpenCloseSupport(), let content = await getIsolatedDocumentContent(document) else {
                return
            }
            logger.debug("Opening Document \(content.uri, privacy: .private)")

            self.openFiles.addDocument(document)

            let textDocument = TextDocumentItem(
                uri: content.uri,
                languageId: content.language,
                version: 0,
                text: content.content
            )
            try await lspInstance.textDocumentDidOpen(DidOpenTextDocumentParams(textDocument: textDocument))
        } catch {
            logger.warning("addDocument: Error \(error)")
            throw error
        }
    }

    /// Helper function for grabbing a document's content from the main actor.
    @MainActor
    private func getIsolatedDocumentContent(_ document: CodeFileDocument) -> DocumentContent? {
        guard let uri = document.languageServerURI,
              let language = document.getLanguage().lspLanguage,
              let content = document.content?.string else {
            return nil
        }
        return DocumentContent(uri: uri, language: language, content: content)
    }

    /// Stops tracking a file and notifies the language server.
    /// - Parameter uri: The URI of the document to close.
    /// - Throws: Throws errors produced by the language server connection.
    func closeDocument(_ uri: String) async throws {
        do {
            guard resolveOpenCloseSupport() && openFiles.document(for: uri) != nil else { return }
            logger.debug("Closing document \(uri, privacy: .private)")
            openFiles.removeDocument(for: uri)
            let params = DidCloseTextDocumentParams(textDocument: TextDocumentIdentifier(uri: uri))
            try await lspInstance.textDocumentDidClose(params)
        } catch {
            logger.warning("closeDocument: Error \(error)")
            throw error
        }
    }

    /// Updates the document with the specified URI with new text and increments its version.
    /// - Parameters:
    ///   - uri: The URI of the document to update.
    ///   - range: The range being replaced.
    ///   - string: The string being inserted into the replacement range.
    /// - Throws: Throws errors produced by the language server connection.
    func documentChanged(
        uri: String,
        replacedContentIn range: LSPRange,
        with string: String
    ) async throws {
        do {
            logger.debug("Document updated, \(uri, privacy: .private)")
            switch resolveDocumentSyncKind() {
            case .full:
                guard let file = openFiles.document(for: uri) else { return }
                let content = await MainActor.run {
                    let storage = file.content
                    return storage?.string
                }
                guard let content else { return }
                let changeEvent = TextDocumentContentChangeEvent(range: nil, rangeLength: nil, text: content)
                try await lspInstance.textDocumentDidChange(
                    DidChangeTextDocumentParams(uri: uri, version: 0, contentChange: changeEvent)
                )
            case .incremental:
                let fileVersion = openFiles.incrementVersion(for: uri)
                // rangeLength is depreciated in the LSP spec.
                let changeEvent = TextDocumentContentChangeEvent(range: range, rangeLength: nil, text: string)
                try await lspInstance.textDocumentDidChange(
                    DidChangeTextDocumentParams(uri: uri, version: fileVersion, contentChange: changeEvent)
                )
            case .none:
                return
            }
        } catch {
            logger.warning("closeDocument: Error \(error)")
            throw error
        }
    }
}
