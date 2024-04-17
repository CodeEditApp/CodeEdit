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
        guard let lastSplitView = splitViewController.splitViewItems.last else { return }

        if let toolbar = window?.toolbar,
           lastSplitView.isCollapsed,
           !toolbar.items.map(\.itemIdentifier).contains(.itemListTrackingSeparator) {
            window?.toolbar?.insertItem(withItemIdentifier: .itemListTrackingSeparator, at: 4)
        }
        NSAnimationContext.runAnimationGroup { _ in
            lastSplitView.animator().isCollapsed.toggle()
        } completionHandler: { [weak self] in
            if lastSplitView.isCollapsed {
                self?.window?.animator().toolbar?.removeItem(at: 4)
            }
        }

        if let codeEditSplitVC = splitViewController as? CodeEditSplitViewController {
            codeEditSplitVC.saveInspectorCollapsedState(isCollapsed: lastSplitView.isCollapsed)
            codeEditSplitVC.hideInspectorToolbarBackground()
        }
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

    @IBAction func openWorkspaceSettings(_ sender: Any) {
        guard let workspaceSettings, let window = window, let workspace = workspace else {
            return
        }

        if let workspaceSettingsWindow, workspaceSettingsWindow.isVisible {
            workspaceSettingsWindow.makeKeyAndOrderFront(self)
        } else {
            let settingsWindow = NSWindow()
            self.workspaceSettingsWindow = settingsWindow
            let contentView = CEWorkspaceSettingsView(
                settings: workspaceSettings,
                window: settingsWindow,
                workspace: workspace
            )

            settingsWindow.contentView = NSHostingView(rootView: contentView)
            settingsWindow.titlebarAppearsTransparent = true
            settingsWindow.setContentSize(NSSize(width: 515, height: 515))
            settingsWindow.makeKeyAndOrderFront(self)

            window.addCenteredChildWindow(settingsWindow, over: window)
        }
    }
}

extension NSToolbarItem.Identifier {
    static let toggleFirstSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleFirstSidebarItem")
    static let toggleLastSidebarItem: NSToolbarItem.Identifier = NSToolbarItem.Identifier("ToggleLastSidebarItem")
    static let itemListTrackingSeparator = NSToolbarItem.Identifier("ItemListTrackingSeparator")
    static let branchPicker: NSToolbarItem.Identifier = NSToolbarItem.Identifier("BranchPicker")
}
