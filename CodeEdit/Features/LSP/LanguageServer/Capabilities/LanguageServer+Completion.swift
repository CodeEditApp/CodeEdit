//
//  LanguageServer+Completion.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestCompletion(for documentURI: String, position: Position) async throws -> CompletionResponse {
        do {
            let cacheKey = CacheKey(
                uri: documentURI,
                requestType: "completion",
                extraData: position
            )
            if let cachedResponse: CompletionResponse = lspCache.get(key: cacheKey, as: CompletionResponse.self) {
                return cachedResponse
            }
            let completionParams = CompletionParams(
                uri: documentURI,
                position: position,
                triggerKind: .invoked,
                triggerCharacter: nil
            )
            let response = try await lspInstance.completion(completionParams)

            lspCache.set(key: cacheKey, value: response)
            return response
        } catch {
            logger.warning("requestCompletion: Error \(error)")
            throw error
        }
    }
}
