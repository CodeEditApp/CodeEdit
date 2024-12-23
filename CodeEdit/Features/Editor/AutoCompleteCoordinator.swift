//
//  AutoCompleteCoordinator.swift
//  CodeEdit
//
//  Created by Abe Malla on 9/20/24.
//

import AppKit
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
    /// The `ItemBoxWindowController` lets us display the autocomplete items
    private var itemBoxController: ItemBoxWindowController?

    init(_ file: CEWorkspaceFile) {
        self.file = file
    }

    func prepareCoordinator(controller: TextViewController) {
        itemBoxController = ItemBoxWindowController()
        itemBoxController?.delegate = self
        itemBoxController?.close()
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
              let itemBoxController = itemBoxController
        else {
            return
        }

        Task {
            let textPosition = Position(line: cursorPos.line - 1, character: cursorPos.column - 1)
            let completionItems = await fetchCompletions(position: textPosition)
            itemBoxController.items = completionItems

            let cursorRect = textView.firstRect(forCharacterRange: cursorPos.range, actualRange: nil)
            itemBoxController.constrainWindowToScreenEdges(cursorRect: cursorRect)
            itemBoxController.showWindow(attachedTo: window)
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

    deinit {
        itemBoxController?.close()
        if let localEventMonitor = localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }
}

extension AutoCompleteCoordinator: ItemBoxDelegate {
    /// Takes a `CompletionItem` and modifies the text view with the new string
    func applyCompletionItem(_ item: CompletionItem) {
        guard let cursorPos = textViewController?.cursorPositions.first,
              let textView = textViewController?.textView else {
            return
        }

        let textPosition = Position(
            line: cursorPos.line - 1,
            character: cursorPos.column - 1
        )
        var textEdits = LSPCompletionItemsUtil.getCompletionItemEdits(
            startPosition: textPosition,
            item: item
        )
        // Appropriately order the text edits
        textEdits = TextEdit.makeApplicable(textEdits)

        // Make the updates
        textView.undoManager?.beginUndoGrouping()
        for textEdit in textEdits {
            textView.replaceString(
                in: cursorPos.range,
                with: textEdit.newText
            )
        }
        textView.undoManager?.endUndoGrouping()

        // Set the cursor to the end of the completion
        let insertText = LSPCompletionItemsUtil.getInsertText(from: item)
        guard let newCursorPos = cursorPos.range.shifted(by: insertText.count) else {
            return
        }
        textViewController?.setCursorPositions([CursorPosition(range: newCursorPos)])

//        do {
//            let token = try textViewController?.treeSitterClient?.nodesAt(range: cursorPos.range)
//            guard let token = token?.first else {
//                return
//            }
//            print("Token \(token)")
//        } catch {
//            print("\(error)")
//            return
//        }
    }
}
