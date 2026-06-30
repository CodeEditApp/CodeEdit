//
//  CopilotInlineCompletionProvider.swift
//  CodeEdit
//
//  Created by Anas Khan on 6/30/26.
//

import AppKit
import CodeEditSourceEditor
import CodeEditTextView
import Foundation

/// Bridges the editor's ``InlineCompletionDelegate`` to the GitHub Copilot language server.
///
/// One provider is created per open document (held strongly by ``CopilotDocumentObjects`` so the controller's
/// weak `inlineCompletionDelegate` reference survives). On each request it synchronizes the document with the
/// server, maps the cursor to an LSP position, requests inline completions, and adapts the results into the
/// editor's ``InlineCompletionItem`` model (rendered as ghost text anchored at the caret).
@MainActor
final class CopilotInlineCompletionProvider: InlineCompletionDelegate {
    private var service: CopilotService { .shared }

    /// The document this provider serves. Held weakly; the document owns this provider.
    private weak var document: CodeFileDocument?

    /// Maps an emitted item id to the original server item so accept/show telemetry can reference its command.
    private var serverItems: [UUID: CopilotCompletionItem] = [:]

    /// Creates a provider. Marked `nonisolated` so it can be constructed as a stored property of a document.
    nonisolated init() {}

    /// Associates this provider with a document.
    func setUp(document: CodeFileDocument) {
        self.document = document
    }

    // MARK: - InlineCompletionDelegate

    func inlineCompletionsRequested(
        textView: TextViewController,
        cursorPosition: CursorPosition
    ) async -> [InlineCompletionItem] {
        guard service.isEnabled,
              let document,
              let uri = document.languageServerURI else {
            return []
        }

        await service.initializeIfNeeded()
        guard service.isSignedIn else { return [] }

        let text = textView.textView.string
        let languageId = document.getLanguage().lspLanguage?.rawValue ?? "plaintext"
        await service.syncDocument(uri: uri, languageId: languageId, text: text)

        let cursorOffset = cursorPosition.range.location
        guard cursorOffset != NSNotFound,
              let lspPosition = textView.textView.lspRangeFrom(
                  nsRange: NSRange(location: cursorOffset, length: 0)
              )?.start else {
            return []
        }

        let items = await service.requestInlineCompletion(
            uri: uri,
            position: CopilotPosition(line: lspPosition.line, character: lspPosition.character),
            tabWidth: textView.tabWidth
        )

        serverItems.removeAll()
        return items.compactMap { serverItem in
            mapItem(serverItem, cursorOffset: cursorOffset, text: text)
        }
    }

    func inlineCompletionDidShow(item: InlineCompletionItem) {
        guard let serverItem = serverItems[item.id] else { return }
        service.reportShown(item: serverItem)
    }

    func inlineCompletionDidAccept(item: InlineCompletionItem) {
        guard let serverItem = serverItems[item.id] else { return }
        service.reportAccepted(item: serverItem)
    }

    func inlineCompletionDidDismiss(item: InlineCompletionItem) {
        serverItems.removeValue(forKey: item.id)
    }

    // MARK: - Mapping

    /// Adapts a server completion item to the editor's ghost-text model.
    ///
    /// The editor renders `insertText` at the caret and replaces `range` on accept. Copilot may return an
    /// `insertText` that includes text the user has already typed, so the already-typed prefix is stripped and
    /// the accept range is anchored at the caret (extending to the end of the server range when it reaches past
    /// the cursor).
    private func mapItem(
        _ serverItem: CopilotCompletionItem,
        cursorOffset: Int,
        text: String
    ) -> InlineCompletionItem? {
        let normalized = normalizeNewlines(serverItem.insertText)
        let nsText = text as NSString

        var ghostText = normalized
        var replaceLength = 0

        if let range = serverItem.range {
            let startOffset = utf16Offset(line: range.start.line, character: range.start.character, in: nsText)
            let endOffset = utf16Offset(line: range.end.line, character: range.end.character, in: nsText)

            if startOffset <= cursorOffset, cursorOffset <= nsText.length {
                let prefixLength = cursorOffset - startOffset
                let prefix = nsText.substring(with: NSRange(location: startOffset, length: prefixLength))
                let normalizedNS = normalized as NSString
                if prefixLength > 0, normalizedNS.length >= prefixLength, normalizedNS.hasPrefix(prefix) {
                    ghostText = normalizedNS.substring(from: prefixLength)
                }
            }
            if endOffset > cursorOffset, endOffset <= nsText.length {
                replaceLength = endOffset - cursorOffset
            }
        }

        guard !ghostText.isEmpty else { return nil }

        let item = InlineCompletionItem(
            insertText: ghostText,
            range: NSRange(location: cursorOffset, length: replaceLength)
        )
        serverItems[item.id] = serverItem
        return item
    }

    /// Normalizes CRLF and CR line endings to LF.
    private func normalizeNewlines(_ string: String) -> String {
        string.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
    }

    /// Converts a zero-based LSP `(line, character)` position to a UTF-16 offset in `text`.
    private func utf16Offset(line: Int, character: Int, in text: NSString) -> Int {
        guard line >= 0 else { return 0 }
        var index = 0
        var currentLine = 0
        while currentLine < line, index < text.length {
            let lineRange = text.lineRange(for: NSRange(location: index, length: 0))
            index = NSMaxRange(lineRange)
            currentLine += 1
        }
        return min(index + max(character, 0), text.length)
    }
}
