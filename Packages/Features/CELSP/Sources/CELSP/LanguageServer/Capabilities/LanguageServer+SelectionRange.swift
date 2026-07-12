//
//  LanguageServer+SelectionRange.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Setup and test the validity of a rename operation at a given location
    func requestSelectionRange(for documentURI: String, positions: [Position]) async throws -> SelectionRangeResponse {
        do {
            let params = SelectionRangeParams(
                workDoneToken: nil,
                textDocument: TextDocumentIdentifier(uri: documentURI),
                positions: positions
            )
            return try await lspInstance.selectionRange(params)
        } catch {
            logger.warning("requestSelectionRange: Error \(error)")
            throw error
        }
    }
}
