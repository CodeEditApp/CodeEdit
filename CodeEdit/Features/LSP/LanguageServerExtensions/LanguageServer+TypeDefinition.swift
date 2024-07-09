//
//  LanguageServer+TypeDefinition.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Resolve the type definition location of a symbol at a given text document position
    func requestTypeDefinition(document documentURI: String, _ position: Position) async -> TypeDefinitionResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.typeDefinition(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }
}
