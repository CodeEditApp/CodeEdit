//
//  AutoCompleteCoordinator.swift
//  CodeEdit
//
//  Created by Abe Malla on 9/20/24.
//

import AppKit
import SwiftTreeSitter
import CodeEditTextView
import CodeEditSourceEditor
import LanguageServerProtocol

class AutoCompleteCoordinator {
    /// A reference to the file we are working with, to be able to query file information
    private weak var file: CEWorkspaceFile?

    /// The current TreeSitter node that the main cursor is at
    private var currentNode: SwiftTreeSitter.Node?
    /// The current filter text based on partial token input
    private var currentFilterText: String = ""
    /// Stores the unfiltered completion items
    private var completionItems: [AutoCompleteItem] = []
    /// Set to true when the server sends an incomplete list, indicating that we should not filter client-side.
    private var receivedIncompleteCompletionItems: Bool = false

    init(_ file: CEWorkspaceFile) {
        self.file = file
    }

    private func fetchCompletions(position: Position) async -> [AutoCompleteItem] {
        let workspace = await file?.fileDocument?.findWorkspace()
        guard let file,
              let workspacePath = workspace?.fileURL?.absoluteURL.path(),
              let language = await file.fileDocument?.getLanguage().lspLanguage else {
            return []
        }

        @Service var lspService: LSPService
        guard let client = await lspService.languageClient(
            for: language,
            workspacePath: workspacePath
        ) else {
            return []
        }

        do {
            let completions = try await client.requestCompletion(
                for: file.url.lspURI,
                position: position
            )

            // Extract the completion items list
            switch completions {
            case .optionA(let completionItems):
                return completionItems.map { AutoCompleteItem($0) }.sorted()
            case .optionB(let completionList):
                receivedIncompleteCompletionItems = receivedIncompleteCompletionItems || completionList.isIncomplete
                return completionList.items.map { AutoCompleteItem($0) }.sorted()
            case .none:
                return []
            }
        } catch {
            return []
        }
    }

    /// Filters completion items based on the current partial token input
    private func filterCompletionItems(_ items: [AutoCompleteItem]) -> [AutoCompleteItem] {
        guard !currentFilterText.isEmpty, !receivedIncompleteCompletionItems else {
            return items.sorted()
        }

        let items = items
            .map { ($0.fuzzyMatch(query: currentFilterText), $0) }
            .compactMap { $0.0.weight > 0 ? $0.1 : nil }

        return items.sorted()
    }
}

extension AutoCompleteCoordinator: CodeSuggestionDelegate {
    @MainActor
    func completionSuggestionsRequested(
        textView: TextViewController,
        cursorPosition: CursorPosition
    ) async -> (windowPosition: CursorPosition, items: [CodeSuggestionEntry])? {
        currentFilterText = ""
        let tokenSubstringCount = findTreeSitterNodeAtPosition(textView: textView, cursorPosition: cursorPosition)

        let textPosition = Position(line: cursorPosition.start.line - 1, character: cursorPosition.start.column - 1)

        // If we are asking for completions in the middle of a token, then
        // query the language server for completion items at the start of the token
        // but *only* if we haven't received an incomplete response.
        let queryPosition = if currentNode != nil && !receivedIncompleteCompletionItems {
            Position(
                line: cursorPosition.start.line - 1,
                character: cursorPosition.start.column - tokenSubstringCount - 1
            )
        } else {
            textPosition
        }
        completionItems = await fetchCompletions(position: queryPosition)

        if receivedIncompleteCompletionItems && queryPosition != textPosition {
            // We need to re-request this. We've requested the wrong location and since know that the server
            // returns incomplete items (meaning we can't filter them ourselves).
            return await completionSuggestionsRequested(textView: textView, cursorPosition: cursorPosition)
        }

        // If we can detect that we're in a node, we still want to adjust the panel to be in the correct position
        let cursorPosition: CursorPosition = if currentNode != nil {
            CursorPosition(
                line: cursorPosition.start.line,
                column: cursorPosition.start.column - tokenSubstringCount
            )
        } else {
            CursorPosition(
                line: queryPosition.line + 1,
                column: queryPosition.character + 1
            )
        }

        return (cursorPosition, filterCompletionItems(completionItems))
    }

    func findTreeSitterNodeAtPosition(textView: TextViewController, cursorPosition: CursorPosition) -> Int {
        var tokenSubstringCount = 0
        let prefixRange = NSRange(location: cursorPosition.range.location - 1, length: 1)
        guard prefixRange.location >= 0 else { return 0 }
        do {
            if let token = try textView.treeSitterClient?.nodesAt(range: prefixRange).first,
               token.node.isNamed {
                currentNode = token.node

                // Get the string from the start of the token to the location of the cursor
                if cursorPosition.range.location > token.node.range.location {
                    let selectedRange = NSRange(
                        location: token.node.range.location,
                        length: cursorPosition.range.location - token.node.range.location
                    )
                    if let tokenSubstring = textView.textView.textStorage?.substring(from: selectedRange) {
                        currentFilterText = tokenSubstring
                        tokenSubstringCount = tokenSubstring.count
                    }
                }
            }
        } catch {
            print("Error getting TreeSitter node: \(error)")
        }
        return tokenSubstringCount
    }

    func completionOnCursorMove(
        textView: TextViewController,
        cursorPosition: CursorPosition
    ) -> [CodeSuggestionEntry]? {
        guard var currentNode = currentNode, !completionItems.isEmpty, !receivedIncompleteCompletionItems else {
            return nil
        }
        _ = findTreeSitterNodeAtPosition(textView: textView, cursorPosition: cursorPosition)
        guard let refreshedNode = self.currentNode else { return nil }
        if refreshedNode.range.intersection(currentNode.range) == nil {
            return nil
        }
        currentNode = refreshedNode

        // Moving to a new token requires a new call to the language server
        // We extend the range so that the `contains` can include the end value of
        // the token, since its check is exclusive.
        if !currentNode.range.contains(cursorPosition.range.location)
            && currentNode.range.max != cursorPosition.range.location {
            return nil
        }

        // Check if cursor is at the start of the token
        if cursorPosition.range.location == currentNode.range.location {
            currentFilterText = ""
            return completionItems
        }

        // Filter through the completion items based on how far the cursor is in the token
        if cursorPosition.range.location > currentNode.range.location {
            let selectedRange = NSRange(
                location: currentNode.range.location,
                length: cursorPosition.range.location - currentNode.range.location
            )
            if let tokenSubstring = textView.textView.textStorage?.substring(from: selectedRange) {
                currentFilterText = tokenSubstring
                return filterCompletionItems(completionItems)
            }
        }

        return nil
    }

    /// Takes a `CompletionItem` and modifies the text view with the new string
    func completionWindowApplyCompletion(
        item: CodeSuggestionEntry,
        textView: TextViewController,
        cursorPosition: CursorPosition?
    ) {
        guard let cursorPosition, let item = item as? AutoCompleteItem else { return }

        // Make the updates
        let replacementRange = currentNode?.range ?? cursorPosition.range
        let insertText = LSPCompletionItemsUtil.getInsertText(from: item)
        textView.textView.replaceCharacters(in: replacementRange, with: insertText)

        // Set cursor position to end of inserted text
        let newCursorRange = NSRange(location: replacementRange.location + insertText.count, length: 0)
        textView.setCursorPositions([CursorPosition(range: newCursorRange)])
    }

    func completionWindowDidSelect(item: CodeSuggestionEntry) { }

    func completionWindowDidClose() {
        currentNode = nil
        currentFilterText = ""
    }
}
