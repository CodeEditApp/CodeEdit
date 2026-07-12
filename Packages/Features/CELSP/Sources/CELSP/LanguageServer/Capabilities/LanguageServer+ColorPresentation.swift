//
//  LanguageServer+ColorPresentation.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestColorPresentation(
        for documentURI: String,
        color: Color,
        range: LSPRange
    ) async throws -> ColorPresentationResponse {
        do {
            let params = ColorPresentationParams(
                workDoneToken: nil,
                partialResultToken: nil,
                textDocument: TextDocumentIdentifier(uri: documentURI),
                color: color,
                range: range
            )
            return try await lspInstance.colorPresentation(params)
        } catch {
            logger.warning("requestColorPresentation: Error \(error)")
            throw error
        }
    }
}
