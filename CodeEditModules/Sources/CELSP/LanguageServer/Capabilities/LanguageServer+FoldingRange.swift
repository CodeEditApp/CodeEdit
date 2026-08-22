//
//  LanguageServer+FoldingRange.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestFoldingRange(for documentURI: String) async throws -> FoldingRangeResponse {
        do {
            let params = FoldingRangeParams(textDocument: TextDocumentIdentifier(uri: documentURI))
            return try await lspInstance.foldingRange(params)
        } catch {
            logger.warning("requestFoldingRange: Error \(error)")
            throw error
        }
    }
}
