//
//  LanguageServer+DocumentColor.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// The document color request is sent from the client to the server to list all color
    /// references found in a given text document. Along with the range, a color value in RGB is returned.
    /// Clients can use the result to decorate color references in an editor. For example:
    ///     1. Color boxes showing the actual color next to the reference
    ///     2. Show a color picker when a color reference is edited
    func requestColor(for documentURI: String) async throws -> DocumentColorResponse {
        let params = DocumentColorParams(
            textDocument: TextDocumentIdentifier(uri: documentURI),
            workDoneToken: nil,
            partialResultToken: nil
        )
        do {
            return try await lspInstance.documentColor(params)
        } catch {
            logger.warning("requestDocumentColor: Error \(error)")
            throw error
        }
    }
}
