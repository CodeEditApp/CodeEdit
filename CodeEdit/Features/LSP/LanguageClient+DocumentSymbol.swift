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
//        let cacheKey = CacheKey(uri: documentURI, requestType: "documentSymbols")
//        if let cachedResponse: DocumentSymbolResponse = lspCache.get(key: cacheKey) {
//            return cachedResponse
//        }

        let textDocumentIdentifier = TextDocumentIdentifier(uri: documentURI)
        let documentSymbolParams = DocumentSymbolParams(textDocument: textDocumentIdentifier)
        let response = try await lspInstance.documentSymbol(documentSymbolParams)

//        lspCache.set(key: cacheKey, value: response)
        return response
    }
}
