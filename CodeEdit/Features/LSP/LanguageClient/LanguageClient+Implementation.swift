//
//  LanguageClient+Implementation.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Resolve the implementation location of a symbol at a given text document position
    func requestImplementation(document documentURI: String, _ position: Position) async -> ImplementationResponse {
        do {
            let params = TextDocumentPositionParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position
            )
            return try await lspInstance.implementation(params)
        } catch {
            print("requestImplementation Error \(error)")
        }
        return nil
    }
}
