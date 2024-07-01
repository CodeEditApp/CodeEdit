//
//  LanguageServer+Hover.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// The hover request is sent from the client to the server to request hover
    /// information at a given text document position.
    func requestHover(document documentURI: String, _ position: Position) async -> HoverResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.hover(params)
        } catch {
            print("requestHover Error \(error)")
        }
        return nil
    }
}
