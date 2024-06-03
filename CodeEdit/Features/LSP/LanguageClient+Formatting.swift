//
//  LanguageClient+Formatting.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import Foundation
import LanguageServerProtocol

// TODO: LOGGING

extension LanguageServer {
    func requestFormatting(
        document documentURI: String,
        withFormat formattingOptions: FormattingOptions
    ) async -> FormattingResult {
        do {
            let params = DocumentFormattingParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                options: formattingOptions
            )
            return try await lspInstance.formatting(params)
        } catch {
            print("requestFormatting Error \(error)")
        }
        return []
    }

    func requestRangeFormatting(
        document documentURI: String,
        _ range: LSPRange,
        withFormat formattingOptions: FormattingOptions
    ) async -> FormattingResult {
        do {
            let params = DocumentRangeFormattingParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                range: range,
                options: formattingOptions
            )
            return try await lspInstance.rangeFormatting(params)
        } catch {
            print("requestRangeFormatting Error \(error)")
        }
        return []
    }

    func requestOnTypeFormatting(
        document documentURI: String,
         _ position: Position,
         character ch: String,
         withFormat formattingOptions: FormattingOptions
    ) async -> FormattingResult {
        do {
            let params = DocumentOnTypeFormattingParams(
                textDocument: TextDocumentIdentifier(uri: documentURI),
                position: position,
                ch: ch,
                options: formattingOptions
            )
            return try await lspInstance.onTypeFormatting(params)
        } catch {
            print("requestOnTypeFormatting Error \(error)")
        }
        return []
    }
}
