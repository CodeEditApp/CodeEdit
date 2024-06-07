//
//  LanguageClient+DocumentHighlight.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// The document highlight request is sent from the client to the server to resolve document
    /// highlights for a given text document position. For programming languages this usually
    /// highlights all references to the symbol scoped to this file.
    func requestDocumentHighlight(
        document documentURI: String,
        _ position: Position
    ) async -> DocumentHighlightResponse {
        do {
            let params = DocumentHighlightParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                workDoneToken: nil,
                partialResultToken: nil
            )
            return try await lspInstance.documentHighlight(params)
        } catch {
            print("requestDocumentHighlight Error: \(error)")
        }

        return nil
    }
}
