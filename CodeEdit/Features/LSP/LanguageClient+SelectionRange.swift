//
//  LanguageClient+SelectionRange.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    /// Setup and test the validity of a rename operation at a given location
    func requestSelectionRange(document documentURI: String, _ positions: [Position]) async -> SelectionRangeResponse {
        do {
            let params = SelectionRangeParams(
                workDoneToken: nil,
                textDocument: TextDocumentIdentifier(uri: documentURI),
                positions: positions
            )
            return try await lspInstance.selectionRange(params)
        } catch {
            print("requestInlayHint Error \(error)")
        }
        return nil
    }
}
