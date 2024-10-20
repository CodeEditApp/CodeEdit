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

    private let itemBoxController = ItemBoxWindowController()

    func prepareCoordinator(controller: TextViewController) {
        itemBoxController.close()
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
        guard let cursorPos = textViewController?.cursorPositions.last,
              let textView = textViewController?.textView,
              let window = NSApplication.shared.keyWindow,
              !itemBoxController.isVisible
        else {
            return
        }

        itemBoxController.items = [
            CompletionItem(label: "item1", kind: .class),
            CompletionItem(label: "item2", kind: .enum),
            CompletionItem(label: "item3", kind: .function),
            CompletionItem(label: "item4", kind: .color),
            CompletionItem(label: "item5", kind: .constant),
            CompletionItem(label: "item6", kind: .constructor),
            CompletionItem(label: "item7", kind: .enumMember),
            CompletionItem(label: "item8", kind: .field),
            CompletionItem(label: "item9", kind: .file),
            CompletionItem(label: "item10", kind: .folder),
            CompletionItem(label: "item11", kind: .snippet),
            CompletionItem(label: "item12", kind: .reference),
        ]

        // Reset the size of the window
        let windowSize = ItemBoxWindowController.DEFAULT_SIZE
        itemBoxController.window?.setContentSize(windowSize)

        let cursorRect = textView.firstRect(forCharacterRange: cursorPos.range, actualRange: nil)
        let screenFrame = window.screen!.visibleFrame
        let padding: CGFloat = 22
        var autocompleteWindowOrigin = NSPoint(
            x: cursorRect.origin.x,
            y: cursorRect.origin.y
        )

        // Keep the horizontal position within the screen and some padding
        let minX = screenFrame.minX + padding
        let maxX = screenFrame.maxX - windowSize.width - padding

        if autocompleteWindowOrigin.x < minX {
            autocompleteWindowOrigin.x = minX
        } else if autocompleteWindowOrigin.x > maxX {
            autocompleteWindowOrigin.x = maxX
        }

        // Check if the window will go below the screen
        // We determine whether the window drops down or upwards by choosing which
        // corner of the window we will position: `setFrameOrigin` or `setFrameTopLeftPoint`
        if autocompleteWindowOrigin.y - windowSize.height < screenFrame.minY {
            // If the cursor itself if below the screen, then position the window
            // at the bottom of the screen with some padding
            if autocompleteWindowOrigin.y < screenFrame.minY {
                autocompleteWindowOrigin.y = screenFrame.minY + padding
            } else {
                // Place above the cursor
                autocompleteWindowOrigin.y += cursorRect.height
            }

            itemBoxController.window?.setFrameOrigin(autocompleteWindowOrigin)
        } else {
            // If the window goes above the screen, position it below the screen with padding
            let maxY = screenFrame.maxY - padding
            if autocompleteWindowOrigin.y > maxY {
                autocompleteWindowOrigin.y = maxY
            }

            itemBoxController.window?.setFrameTopLeftPoint(autocompleteWindowOrigin)
        }

        itemBoxController.showWindow(attachedTo: window)
    }

    deinit {
        print("Destroyed AutoCompleteCoordinator")
        itemBoxController.close()
        if let localEventMonitor = localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }
}
