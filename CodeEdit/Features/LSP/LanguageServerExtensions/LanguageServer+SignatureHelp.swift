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
    func requestSignatureHelp(document documentURI: String, _ position: Position) async -> SignatureHelpResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.signatureHelp(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }
}
