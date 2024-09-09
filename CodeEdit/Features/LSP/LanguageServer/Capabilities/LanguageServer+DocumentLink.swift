//
//  LanguageServer+DocumentLink.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

// TODO: DocumentLinkParams IS MISSING `textDocument: TextDocumentIdentifier;` FIELD IN LSP LIBRARY

extension LanguageServer {
    @available(*, deprecated, message: "Not functional, see comment.")
    func requestLinkResolve(_ documentLink: DocumentLink) async throws -> DocumentLink? {
        do {
            return try await lspInstance.documentLinkResolve(documentLink)
        } catch {
            logger.warning("requestDocumentLinkResolve: Error \(error)")
            throw error
        }
    }
}
