//
//  LanguageServer+Declaration.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestGoToDeclaration(for documentURI: String, position: Position) async throws -> DeclarationResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.declaration(params)
        } catch {
            logger.warning("requestGoToDeclaration: Error \(error)")
            throw error
        }
    }
}
