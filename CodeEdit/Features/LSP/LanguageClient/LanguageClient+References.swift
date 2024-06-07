//
//  LanguageClient+References.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Resolve project-wide references for the symbol denoted by the given text document position
    func requestFindReferences(
        document documentURI: String,
        _ position: Position,
        _ includeDeclaration: Bool = false
    ) async -> ReferenceResponse {
        do {
            let params = ReferenceParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                includeDeclaration: includeDeclaration
            )
            return try await lspInstance.references(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }
}
