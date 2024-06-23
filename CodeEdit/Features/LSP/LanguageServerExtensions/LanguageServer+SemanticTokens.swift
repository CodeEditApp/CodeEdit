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
    func requestSemanticTokensFull(document documentURI: String) async -> SemanticTokensResponse {
        do {
            let params = SemanticTokensParams(
                textDocument: TextDocumentIdentifier(uri: documentURI)
            )
            return try await lspInstance.semanticTokensFull(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }

    func requestSemanticTokensRange(document documentURI: String, _ range: LSPRange) async -> SemanticTokensResponse {
        do {
            let params = SemanticTokensRangeParams(textDocument: TextDocumentIdentifier(uri: documentURI), range: range)
            return try await lspInstance.semanticTokensRange(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }

    func requestSemanticTokensFullDelta(
        document documentURI: String,
        _ previousResultId: String
    ) async -> SemanticTokensDeltaResponse {
        do {
            let params = SemanticTokensDeltaParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                previousResultId: previousResultId
            )
            return try await lspInstance.semanticTokensFullDelta(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }
}
