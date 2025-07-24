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
    private var completionItems: [CompletionItem] = []

    init(_ file: CEWorkspaceFile) {
        self.file = file
    }

    private func fetchCompletions(position: Position) async -> [CompletionItem] {
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
                return completionItems
            case .optionB(let completionList):
                return completionList.items
            case .none:
                return []
            }
        } catch {
            return []
        }
    }

    /// Filters completion items based on the current partial token input
    private func filterCompletionItems(_ items: [CompletionItem]) -> [CompletionItem] {
        guard !currentFilterText.isEmpty else {
            return items
        }

        let items = items.filter { item in
            let insertText = LSPCompletionItemsUtil.getInsertText(from: item)
            let label = item.label.lowercased()
            let filterText = currentFilterText.lowercased()
            if insertText.lowercased().hasPrefix(filterText) {
                return true
            }
            if label.hasPrefix(filterText) {
                return true
            }
            return false
        }

        return items
    }
}

extension AutoCompleteCoordinator: CodeSuggestionDelegate {
    @MainActor
    func completionSuggestionsRequested(
        textView: TextViewController,
        cursorPosition: CursorPosition
    ) async -> (windowPosition: CursorPosition, items: [CodeSuggestionEntry])? {
        let tokenSubstringCount = findTreeSitterNodeAtPosition(textView: textView, cursorPosition: cursorPosition)
        currentFilterText = ""

        var textPosition = Position(line: cursorPosition.line - 1, character: cursorPosition.column - 1)
        var cursorPosition = cursorPosition
        // If we are asking for completions in the middle of a token, then
        // query the language server for completion items at the start of the token
        if currentNode != nil {
            textPosition = Position(
                line: cursorPosition.line - 1,
                character: cursorPosition.column - tokenSubstringCount - 1
            )
            cursorPosition = CursorPosition(line: textPosition.line + 1, column: textPosition.character + 1)
        }
        completionItems = await fetchCompletions(position: textPosition)
        return (cursorPosition, completionItems)
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
        guard var currentNode = currentNode, !completionItems.isEmpty else {
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
        cursorPosition: CursorPosition
    ) {
        guard let item = item as? CompletionItem else { return }

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
