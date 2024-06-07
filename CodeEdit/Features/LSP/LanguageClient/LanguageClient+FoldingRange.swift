//
//  LanguageClient+FoldingRange.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestFoldingRange(document documentURI: String) async -> FoldingRangeResponse {
        do {
            let params = FoldingRangeParams(textDocument: TextDocumentIdentifier(uri: documentURI))
            return try await lspInstance.foldingRange(params)
        } catch {
            // TODO: LOGGING
            print("requestFoldingRange Error: \(error)")
        }
        return nil
    }
}
