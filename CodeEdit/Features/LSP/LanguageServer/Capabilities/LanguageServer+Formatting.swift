//
//  LanguageServer+Formatting.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

extension LanguageServer {
    func requestFormatting(
        for documentURI: String,
        withFormat formattingOptions: FormattingOptions
    ) async throws -> FormattingResult {
        do {
            let params = DocumentFormattingParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                options: formattingOptions
            )
            return try await lspInstance.formatting(params)
        } catch {
            logger.warning("requestFormatting: Error \(error)")
            throw error
        }
    }

    func requestRangeFormatting(
        for documentURI: String,
        _ range: LSPRange,
        withFormat formattingOptions: FormattingOptions
    ) async throws -> FormattingResult {
        do {
            let params = DocumentRangeFormattingParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                range: range,
                options: formattingOptions
            )
            return try await lspInstance.rangeFormatting(params)
        } catch {
            logger.warning("requestRangeFormatting: Error \(error)")
            throw error
        }
    }

    func requestOnTypeFormatting(
        for documentURI: String,
        _ position: Position,
        character char: String,
        withFormat formattingOptions: FormattingOptions
    ) async throws -> FormattingResult {
        do {
            let params = DocumentOnTypeFormattingParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                ch: char,
                options: formattingOptions
            )
            return try await lspInstance.onTypeFormatting(params)
        } catch {
            logger.warning("requestOnTypeFormatting: Error \(error)")
            throw error
        }
    }
}
