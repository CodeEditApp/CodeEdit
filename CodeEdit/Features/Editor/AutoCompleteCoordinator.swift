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

class AutoCompleteCoordinator: TextViewCoordinator {
    /// A reference to the `TextViewController`, to be able to make edits
    private weak var textViewController: TextViewController?
    /// A reference to the file we are working with, to be able to query file information
    private unowned var file: CEWorkspaceFile
    /// The event monitor that looks for the keyboard shortcut to bring up the autocomplete menu
    private var localEventMonitor: Any?
    /// The `SuggestionController` lets us display the autocomplete items
    private var suggestionController: SuggestionController?
    /// The current TreeSitter node that the main cursor is at
    private var currentNode: SwiftTreeSitter.Node?

    init(_ file: CEWorkspaceFile) {
        self.file = file
    }

    func prepareCoordinator(controller: TextViewController) {
        suggestionController = SuggestionController()
        suggestionController?.delegate = self
        suggestionController?.close()
        self.textViewController = controller

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // `ctrl + space` keyboard shortcut listener for the item box to show
            if event.modifierFlags.contains(.control) && event.charactersIgnoringModifiers == " " {
                Task {
                    await self.showAutocompleteWindow()
                }
                return nil
            }
            return event
        }
    }

    /// Will query the language server for autocomplete suggestions and then display the window.
    @MainActor
    func showAutocompleteWindow() {
        guard let cursorPos = textViewController?.cursorPositions.first,
              let textView = textViewController?.textView,
              let window = NSApplication.shared.keyWindow,
              let suggestionController = suggestionController
        else {
            return
        }

        do {
            if let token = try textViewController?.treeSitterClient?.nodesAt(range: cursorPos.range).first {
                if tokenIsActionable(token.node) {
                    currentNode = token.node
                }

                // Get the string from the start of the token to the location of the cursor
                if cursorPos.range.location > token.node.range.location {
                    let selectedRange = NSRange(
                        location: token.node.range.location,
                        length: cursorPos.range.location - token.node.range.location
                    )
                    let tokenSubstring = textView.textStorage?.substring(from: selectedRange)
//                    print("Token word: \(String(describing: tokenSubstring))")
                }
            }
        } catch {
            print("Error getting TreeSitter node: \(error)")
        }

        Task {
            let textPosition = Position(line: cursorPos.line - 1, character: cursorPos.column - 1)
            // If we are asking for completions in the middle of a token, then
            // query the language server for completion items at the start of the token
//            if let currentNode = currentNode, tokenIsActionable(currentNode) {
//                if let newPos = textView.lspRangeFrom(nsRange: currentNode.range) {
//                    _currentNode
//                }
//            }
            print("Getting completion items at token position: \(textPosition)")

            let completionItems = await fetchCompletions(position: textPosition)
            suggestionController.items = completionItems

            let cursorRect = textView.firstRect(forCharacterRange: cursorPos.range, actualRange: nil)
            suggestionController.constrainWindowToScreenEdges(cursorRect: cursorRect)
            suggestionController.showWindow(attachedTo: window)
        }
    }

    private func fetchCompletions(position: Position) async -> [CompletionItem] {
        let workspace = await file.fileDocument?.findWorkspace()
        guard let workspacePath = workspace?.fileURL?.absoluteURL.path() else { return [] }
        guard let language = await file.fileDocument?.getLanguage().lspLanguage else { return [] }

        @Service var lspService: LSPService
        guard let client = await lspService.languageClient(
            for: language,
            workspacePath: workspacePath
        ) else {
            return []
        }

        do {
            let completions = try await client.requestCompletion(
                for: file.url.absoluteURL.path(),
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

    /// Determines if a TreeSitter node is a type where we can build featues off of. This helps filter out
    /// nodes that represent blank spaces or other information that is not useful.
    private func tokenIsActionable(_ node: SwiftTreeSitter.Node) -> Bool {
        // List of node types that should have their text be replaced
        let replaceableTypes: Set<String> = [
            "identifier",
            "property_identifier",
            "field_identifier",
            "variable_name",
            "method_name",
            "function_name",
            "type_identifier"
        ]
        return replaceableTypes.contains(node.nodeType ?? "")
    }

    deinit {
        suggestionController?.close()
        if let localEventMonitor = localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }
}

extension AutoCompleteCoordinator: SuggestionControllerDelegate {
    /// Takes a `CompletionItem` and modifies the text view with the new string
    func applyCompletionItem(item: CompletionItem) {
        guard let cursorPos = textViewController?.cursorPositions.first,
              let textView = textViewController?.textView else {
            return
        }

        // Get the token the cursor is currently on. Here we will check if we want to
        // replace the current token we are on or just add text onto it.
        var replacementRange = cursorPos.range
        do {
            if let token = try textViewController?.treeSitterClient?.nodesAt(range: cursorPos.range).first {
                if tokenIsActionable(token.node) {
                    replacementRange = token.node.range
                }
            }
        } catch {
            print("Error getting TreeSitter node: \(error)")
        }

        // Make the updates
        let insertText = LSPCompletionItemsUtil.getInsertText(from: item)
        textView.undoManager?.beginUndoGrouping()
        textView.replaceString(in: replacementRange, with: insertText)
        textView.undoManager?.endUndoGrouping()

        // Set cursor position to end of inserted text
        let newCursorRange = NSRange(location: replacementRange.location + insertText.count, length: 0)
        textViewController?.setCursorPositions([CursorPosition(range: newCursorRange)])

        self.onCompletion()
    }

    func onCompletion() {

    }

    func onCursorMove() {
        guard let cursorPos = textViewController?.cursorPositions.first,
              let suggestionController = suggestionController,
              let textView = self.textViewController?.textView,
              suggestionController.isVisible
        else {
            return
        }
        guard let currentNode = currentNode,
              !suggestionController.items.isEmpty else {
            self.suggestionController?.close()
            return
        }

        do {
            if let token = try textViewController?.treeSitterClient?.nodesAt(range: cursorPos.range).first {
                // Moving to a new token requires a new call to the language server
                // We extend the range so that the `contains` can include the end value of
                // the token, since its check is exclusive.
                let adjustedRange = currentNode.range.shifted(endBy: 1)
                if let adjustedRange = adjustedRange,
                   !adjustedRange.contains(cursorPos.range.location) {
                    suggestionController.close()
                    return
                }

                // 1. Print cursor position and token range
                print("Current node: \(String(describing: currentNode))")
                print("Cursor pos: \(cursorPos.range.location) : Line: \(cursorPos.line) Col: \(cursorPos.column)")

                // Get the token string from the start of the token to the location of the cursor
//                print("Token contains cursor position: \(String(describing: currentNode.range.contains(cursorPos.range.location)))")
//                print("Token info: \(String(describing: tokenSubstring)) Range: \(String(describing: adjustedRange))")
//                print("Current cursor position: \(cursorPos.range)")
            }
        } catch {
            print("Error getting TreeSitter node: \(error)")
        }
    }

    func onItemSelect(item: LanguageServerProtocol.CompletionItem) {

    }

    func onClose() {
        currentNode = nil
    }
}
