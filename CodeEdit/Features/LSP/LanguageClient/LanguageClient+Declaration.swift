//
//  LanguageClient+Declaration.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestGoToDeclaration(document documentURI: String, _ position: Position) async -> DeclarationResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.declaration(params)
        } catch {
            print("requestGoToDeclaration Error \(error)")
        }

        return nil
    }
}
