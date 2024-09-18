//
//  LanguageServer+SignatureHelp.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Request signature information at a given cursor position
    func requestSignatureHelp(for documentURI: String, _ position: Position) async throws -> SignatureHelpResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.signatureHelp(params)
        } catch {
            logger.warning("requestInlayHint: Error \(error)")
            throw error
        }
    }
}
