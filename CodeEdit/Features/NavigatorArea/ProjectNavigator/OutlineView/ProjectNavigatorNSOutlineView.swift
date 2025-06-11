//
//  ProjectNavigatorNSOutlineView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/10/25.
//

import AppKit

final class ProjectNavigatorNSOutlineView: NSOutlineView, NSMenuItemValidation {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.window === window && window?.firstResponder === self else {
            return super.performKeyEquivalent(with: event)
        }

        if event.charactersIgnoringModifiers == "v"
            && event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
            guard let menu = menu as? ProjectNavigatorMenu else {
                return super.performKeyEquivalent(with: event)
            }
            menu.delegate?.menuNeedsUpdate?(menu)
            for fileItem in selectedRowIndexes.compactMap({ item(atRow: $0) as? CEWorkspaceFile }) {
                menu.item = fileItem
                menu.newFileFromClipboard()
            }
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(ProjectNavigatorMenu.newFileFromClipboard) {
            return !selectedRowIndexes.isEmpty
        }
        return false
    }
}
