//
//  LanguageServer+Implementation.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Resolve the implementation location of a symbol at a given text document position
    func requestImplementation(for documentURI: String, _ position: Position) async throws -> ImplementationResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.implementation(params)
        } catch {
            logger.warning("requestImplementation: Error \(error)")
            throw error
        }
    }
}
