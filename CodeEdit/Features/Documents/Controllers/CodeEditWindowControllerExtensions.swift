//
//  CodeEditWindowControllerExtensions.swift
//  CodeEdit
//
//  Created by Austin Condiff on 10/14/23.
//

import SwiftUI
import Combine

extension CodeEditWindowController {
    @objc
    func toggleFirstPanel() {
        guard let firstSplitView = splitViewController.splitViewItems.first else { return }
        firstSplitView.animator().isCollapsed.toggle()
        if let codeEditSplitVC = splitViewController as? CodeEditSplitViewController {
            codeEditSplitVC.saveNavigatorCollapsedState(isCollapsed: firstSplitView.isCollapsed)
        }
    }

    @objc
    func toggleLastPanel() {
        guard let codeEditSplitVC = splitViewController as? CodeEditSplitViewController else { return }
        guard let lastSplitView = codeEditSplitVC.splitViewItems.last else { return }

        NSAnimationContext.runAnimationGroup { _ in
            lastSplitView.animator().isCollapsed.toggle()
        } completionHandler: {
            if lastSplitView.isCollapsed {
                codeEditSplitVC.removeToolbarItemIfNeeded()
            }
        }

        codeEditSplitVC.insertToolbarItemIfNeeded()
        codeEditSplitVC.saveInspectorCollapsedState(isCollapsed: lastSplitView.isCollapsed)
        codeEditSplitVC.hideInspectorToolbarBackground()
    }

    /// These are example items that added as commands to command palette
    func registerCommands() {
        CommandManager.shared.addCommand(
            name: "Quick Open",
            title: "Quick Open",
            id: "quick_open",
            command: CommandClosureWrapper(closure: { self.openQuickly(self) })
        )

        CommandManager.shared.addCommand(
            name: "Toggle Navigator",
            title: "Toggle Navigator",
            id: "toggle_left_sidebar",
            command: CommandClosureWrapper(closure: { self.toggleFirstPanel() })
        )

        CommandManager.shared.addCommand(
            name: "Toggle Inspector",
            title: "Toggle Inspector",
            id: "toggle_right_sidebar",
            command: CommandClosureWrapper(closure: { self.toggleLastPanel() })
        )
    }

    // Listen to changes in all tabs/files
    internal func listenToDocumentEdited(workspace: WorkspaceDocument) {
        workspace.editorManager.$activeEditor
            .flatMap({ editor in
                editor.$tabs
            })
            .compactMap({ tab in
                Publishers.MergeMany(tab.elements.compactMap({ $0.file.fileDocumentPublisher }))
            })
            .switchToLatest()
            .compactMap({ fileDocument in
                fileDocument?.isDocumentEditedPublisher
            })
            .flatMap({ $0 })
            .sink { isDocumentEdited in
                if isDocumentEdited {
                    self.setDocumentEdited(true)
                    return
                }

                self.updateDocumentEdited(workspace: workspace)
            }
            .store(in: &cancellables)

        // Listen to change of tabs, if closed tab without saving content,
        // we also need to recalculate isDocumentEdited
        workspace.editorManager.$activeEditor
            .flatMap({ editor in
                editor.$tabs
            })
            .sink { _ in
                self.updateDocumentEdited(workspace: workspace)
            }
            .store(in: &cancellables)
    }

    // Recalculate documentEdited by checking if any tab/file is edited
    private func updateDocumentEdited(workspace: WorkspaceDocument) {
        let hasEditedDocuments = !workspace
            .editorManager
            .editorLayout
            .gatherOpenFiles()
            .filter({ $0.fileDocument?.isDocumentEdited == true })
            .isEmpty
        self.setDocumentEdited(hasEditedDocuments)
    }
}

extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let addSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("AddSidebarItem")
    static let stopTaskSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("StopTaskSidebarItem")
    static let startTaskSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("StartTaskSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let branchPicker: NSToolbarItem.Identifier = NSToolbarItem.Identifier("BranchPicker")
    static let activityViewer: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ActivityViewer")
}
