//
//  LanguageServer+DocumentSync.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    // MARK: - API

    /// Tells the language server we've opened a document and would like to begin working with it.
    /// - Parameter document: The code document to open.
    func openDocument(_ document: CodeFileDocument) async throws {
        do {
            guard serverSupportsOpenClose(), let content = await getIsolatedDocumentContent(document) else {
                return
            }
            logger.debug("Opening Document \(content.uri, privacy: .private)")

            self.openFiles.addDocument(document)

            let textDocument = TextDocumentItem(
                uri: content.uri,
                languageId: content.language,
                version: 0,
                text: content.string
            )
            try await lspInstance.textDocumentDidOpen(DidOpenTextDocumentParams(textDocument: textDocument))
            await setCoordinatorServer(for: document)
        } catch {
            logger.warning("addDocument: Error \(error)")
            throw error
        }
    }

    /// Stops tracking a file and notifies the language server.
    /// - Parameter uri: The URI of the document to close.
    func closeDocument(_ uri: String) async throws {
        do {
            guard serverSupportsOpenClose() && openFiles.document(for: uri) != nil else { return }
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
    /// - Returns: `true` if the document was successfully updated, `false`
    func documentChanged(
        uri: String,
        replacedContentIn range: LSPRange,
        with string: String
    ) async throws {
        do {
            logger.debug("Document updated, \(uri, privacy: .private)")
            switch serverDocumentSyncSupport() {
            case .full:
                guard let document = openFiles.document(for: uri),
                      let content = await getIsolatedDocumentContent(document) else {
                    return
                }
                let changeEvent = TextDocumentContentChangeEvent(range: nil, rangeLength: nil, text: content.string)
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

    // MARK: - Helpers

    // swiftlint:disable line_length
    /// Determines the type of document sync the server supports.
    /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_synchronization_sc
    fileprivate func serverDocumentSyncSupport() -> TextDocumentSyncKind {
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

    fileprivate func serverSupportsOpenClose() -> Bool {
        switch serverCapabilities.textDocumentSync {
        case .optionA(let options):
            return options.openClose ?? false
        case .optionB:
            return true
        default:
            return true
        }
    }

    // Avoids a lint error
    fileprivate struct DocumentContent {
        let uri: String
        let language: LanguageIdentifier
        let string: String
    }

    /// Helper function for grabbing a document's content from the main actor.
    @MainActor
    fileprivate func getIsolatedDocumentContent(_ document: CodeFileDocument) -> DocumentContent? {
        guard let uri = document.languageServerURI,
              let language = document.getLanguage().lspLanguage,
              let content = document.content?.string else {
            return nil
        }
        return DocumentContent(uri: uri, language: language, string: content)
    }

    /// Small helper, removed from the main function to make async syntax more straightforward.
    @MainActor
    fileprivate func setCoordinatorServer(for document: CodeFileDocument) {
        document.lspCoordinator.languageServer = self
    }
}
