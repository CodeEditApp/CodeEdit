//
//  LanguageServer+DocumentSync.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    fileprivate func serverDocumentSyncSupport() -> TextDocumentSyncKind {
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
    
    /// Tells the language server we've opened a document and would like to begin working with it.
    /// - Parameter document: The code document to open.
    func openDocument(_ document: CodeFileDocument) async throws {
        do {
            guard serverSupportsOpenClose(),
                  let uri = await document.languageServerURI,
                  let language = await document.getLanguage().lspLanguage else {
                return
            }
            let content = await MainActor.run {
                let storage = document.content
                return storage?.string
            }
            guard let content else { return }
            logger.debug("Opening Document \(uri, privacy: .private)")

            self.openFiles.addDocument(document)

            let textDocument = TextDocumentItem(
                uri: uri,
                languageId: language,
                version: 0,
                text: content
            )
            try await lspInstance.textDocumentDidOpen(DidOpenTextDocumentParams(textDocument: textDocument))
        } catch {
            logger.warning("addDocument: Error \(error)")
            throw error
        }
    }

    /// Stops tracking a file and notifies the language server
    /// - Parameter uri: The URI of the document to close.
    func closeDocument(_ uri: String) async throws {
        do {
            guard serverSupportsOpenClose() else { return }
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
