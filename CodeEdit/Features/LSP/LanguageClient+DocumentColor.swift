//
//  LanguageClient+DocumentColor.swift
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
    func requestDocumentColor(document documentURI: String) async -> DocumentColorResponse {
        do {
            let params = DocumentColorParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                workDoneToken: nil,
                partialResultToken: nil
            )
            return try await lspInstance.documentColor(params)
        } catch {
            print("requestDocumentColor Error \(error)")
        }
        return []
    }
}
