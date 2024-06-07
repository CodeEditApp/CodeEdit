//
//  LanguageClient+DocumentSymbol.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestDocumentSymbols(
        for languageId: LanguageIdentifier,
        document documentURI: String
    ) async throws -> DocumentSymbolResponse {
        let textDocumentIdentifier = TextDocumentIdentifier(uri: documentURI)
        let documentSymbolParams = DocumentSymbolParams(textDocument: textDocumentIdentifier)
        return try await lspInstance.documentSymbol(documentSymbolParams)
    }
}
