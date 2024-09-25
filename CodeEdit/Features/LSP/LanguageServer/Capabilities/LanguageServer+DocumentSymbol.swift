//
//  LanguageServer+DocumentSymbol.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestSymbols(for documentURI: String) async throws -> DocumentSymbolResponse {
        do {
            let textDocumentIdentifier = TextDocumentIdentifier(uri: documentURI)
            let documentSymbolParams = DocumentSymbolParams(textDocument: textDocumentIdentifier)
            return try await lspInstance.documentSymbol(documentSymbolParams)
        } catch {
            logger.warning("requestSymbols: Error \(error)")
            throw error
        }
    }
}
