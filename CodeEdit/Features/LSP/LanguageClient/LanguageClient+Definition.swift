//
//  LanguageClient+Definition.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestGoToDefinition(
        for languageId: LanguageIdentifier,
        document documentURI: String,
        position: Position
    ) async throws -> DefinitionResponse {
        let cacheKey = CacheKey(uri: documentURI, requestType: "goToDefinition")
        if let cachedResponse: DefinitionResponse = lspCache.get(key: cacheKey) {
            return cachedResponse
        }

        let textDocumentIdentifier = TextDocumentIdentifier(uri: documentURI)
        let textDocumentPositionParams = TextDocumentPositionParams(
            textDocument: textDocumentIdentifier,
            position: position
        )
        let response = try await lspInstance.definition(textDocumentPositionParams)

        lspCache.set(key: cacheKey, value: response)
        return response
    }
}
