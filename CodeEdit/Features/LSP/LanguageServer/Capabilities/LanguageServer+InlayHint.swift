//
//  LanguageServer+InlayHint.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Compute inlay hints for a given [text document, range] tuple that may be rendered in the
    /// editor in place with other text
    func requestInlayHint(for documentURI: String, _ range: LSPRange) async throws -> InlayHintResponse {
        do {
            let params = InlayHintParams(
                workDoneToken: nil,
                textDocument: TextDocumentIdentifier(uri: documentURI),
                range: range
            )
            return try await lspInstance.inlayHint(params)
        } catch {
            logger.warning("requestInlayHint: Error \(error)")
            throw error
        }
    }

    /// The request is sent from the client to the server to resolve additional information for a given inlay hint.
    /// This is usually used to compute the tooltip, location or command properties of an inlay hint’s label part
    /// to avoid its unnecessary computation during the textDocument/inlayHint request.
    func requestInlayHintResolve(_ inlayHint: InlayHint) async throws -> InlayHint? {
        do {
            return try await lspInstance.inlayHintResolve(inlayHint)
        } catch {
            logger.warning("requestInlayHintResolve: Error \(error)")
            throw error
        }
    }
}
