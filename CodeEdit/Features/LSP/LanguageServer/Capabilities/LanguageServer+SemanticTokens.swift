//
//  LanguageServer+SemanticTokens.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Setup and test the validity of a rename operation at a given location
    func requestSemanticTokens(for documentURI: String) async throws -> SemanticTokensResponse {
        do {
            let params = SemanticTokensParams(
                textDocument: TextDocumentIdentifier(uri: documentURI)
            )
            return try await lspInstance.semanticTokensFull(params)
        } catch {
            logger.warning("requestSemanticTokens full: Error \(error)")
            throw error
        }
    }

    func requestSemanticTokens(
        for documentURI: String,
        forRange range: LSPRange
    ) async throws -> SemanticTokensResponse {
        do {
            let params = SemanticTokensRangeParams(textDocument: TextDocumentIdentifier(uri: documentURI), range: range)
            return try await lspInstance.semanticTokensRange(params)
        } catch {
            logger.warning("requestSemanticTokens range: Error \(error)")
            throw error
        }
    }

    func requestSemanticTokens(
        for documentURI: String,
        previousResultId: String
    ) async throws -> SemanticTokensDeltaResponse {
        do {
            let params = SemanticTokensDeltaParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                previousResultId: previousResultId
            )
            return try await lspInstance.semanticTokensFullDelta(params)
        } catch {
            logger.warning("requestSemanticTokens versioned: Error \(error)")
            throw error
        }
    }
}
