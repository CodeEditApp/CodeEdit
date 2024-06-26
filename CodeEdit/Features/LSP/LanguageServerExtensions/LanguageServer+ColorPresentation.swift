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
        document documentURI: String,
        _ color: Color,
        _ range: LSPRange
    ) async -> ColorPresentationResponse {
        let params = ColorPresentationParams(
            workDoneToken: nil,
            partialResultToken: nil,
            textDocument: TextDocumentIdentifier(uri: documentURI),
            color: color,
            range: range
        )
        do {
            return try await lspInstance.colorPresentation(params)
        } catch {
            // TODO: LOGGING
            print("requestColorPresentation: Error \(error)")
        }
        return []
    }
}
