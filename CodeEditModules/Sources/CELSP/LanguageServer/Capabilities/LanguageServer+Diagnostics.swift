//
//  LanguageServer+Diagnostics.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestPullDiagnostics(document documentURI: String) async throws -> DocumentDiagnosticReport {
        do {
            let cacheKey = CacheKey(
                uri: documentURI,
                requestType: "diagnostics",
                extraData: NoExtraData()
            )
            if let cachedResponse: DocumentDiagnosticReport = lspCache.get(
                key: cacheKey, as: DocumentDiagnosticReport.self
            ) {
                return cachedResponse
            }

            let response = try await lspInstance.diagnostics(
                DocumentDiagnosticParams(
                    textDocument: TextDocumentIdentifier(uri: documentURI)
                )
            )
            lspCache.set(key: cacheKey, value: response)
            return response
        } catch {
            logger.warning("requestPullDiagnostics: Error \(error)")
            throw error
        }
    }
}
