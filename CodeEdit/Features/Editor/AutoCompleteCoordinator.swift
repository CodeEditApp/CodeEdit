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
    private weak var textViewController: TextViewController?
    private var localEventMonitor: Any?

    private var itemBoxController: ItemBoxWindowController?

    func prepareCoordinator(controller: TextViewController) {
        itemBoxController = ItemBoxWindowController()
        itemBoxController?.delegate = self
        itemBoxController?.close()
        self.textViewController = controller

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // `ctrl + space` keyboard shortcut listener for the item box to show
            if event.modifierFlags.contains(.control) && event.charactersIgnoringModifiers == " " {
                self.showAutocompleteWindow()
                return nil
            }
            return event
        }
    }

    func showAutocompleteWindow() {
        guard let cursorPos = textViewController?.cursorPositions.first,
              let textView = textViewController?.textView,
              let window = NSApplication.shared.keyWindow,
              let itemBoxController = itemBoxController,
              !itemBoxController.isVisible
        else {
            return
        }

        @Service var lspService: LSPService

//        lspService.

        itemBoxController.items = [
            CompletionItem(label: "CETable", kind: .class),
            CompletionItem(label: "CETask", kind: .enum),
            CompletionItem(label: "CETarget", kind: .function),
            CompletionItem(label: "CEItem", kind: .color),
            CompletionItem(label: "tableView", kind: .constant),
            CompletionItem(label: "itemBoxController", kind: .constructor),
            CompletionItem(label: "showAutocompleteWindow", kind: .enumMember),
            CompletionItem(label: "NSApplication", kind: .field),
            CompletionItem(label: "CECell", kind: .file),
            CompletionItem(label: "Item10", kind: .folder),
            CompletionItem(label: "Item11", kind: .snippet),
            CompletionItem(label: "Item12", kind: .reference),
        ]

        let cursorRect = textView.firstRect(forCharacterRange: cursorPos.range, actualRange: nil)
        itemBoxController.constrainWindowToScreenEdges(cursorRect: cursorRect)
        itemBoxController.showWindow(attachedTo: window)
    }

    deinit {
        itemBoxController?.close()
        if let localEventMonitor = localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }
}

extension MarkupContent {
    public init(kind: MarkupKind, value: String) {
        do {
            let dictionary: [String: Any] = ["kind": kind.rawValue, "value": value]
            let data = try JSONSerialization.data(withJSONObject: dictionary)
            self = try JSONDecoder().decode(MarkupContent.self, from: data)
        } catch {
            print("Failed to create MarkupContent: \(error)")
            // swiftlint:disable:next force_try
            self = try! JSONDecoder().decode(MarkupContent.self, from: """
                {"kind": "plaintext", "value": ""}
                """.data(using: .utf8)!)
        }
    }
}

extension AutoCompleteCoordinator: ItemBoxDelegate {
    func applyCompletionItem(_ item: CompletionItem) {
        guard let cursorPos = textViewController?.cursorPositions.first else {
            return
        }

        do {
            let token = try textViewController?.treeSitterClient?.nodesAt(range: cursorPos.range)
            guard let token = token?.first else {
                return
            }
            print("Token \(token)")
        } catch {
            print("\(error)")
            return
        }
    }
}
