//
//  LanguageServer+Definition.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestGoToDefinition(for documentURI: String, position: Position) async throws -> DefinitionResponse {
        do {
            let cacheKey = CacheKey(
                uri: documentURI,
                requestType: "goToDefinition",
                extraData: NoExtraData()
            )
            if let cachedResponse: DefinitionResponse = lspCache.get(key: cacheKey, as: DefinitionResponse.self) {
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
        } catch {
            logger.warning("requestGoToDefinition: Error \(error)")
            throw error
        }
    }
}
