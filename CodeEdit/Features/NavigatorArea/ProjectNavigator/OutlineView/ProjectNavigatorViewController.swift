//
//  OutlineViewController.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import AppKit
import SwiftUI

/// A `NSViewController` that handles the **ProjectNavigatorView** in the **NavigatorArea**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
final class ProjectNavigatorViewController: NSViewController {

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    /// Gets the folder structure
    ///
    /// Also creates a top level item "root" which represents the projects root directory and automatically expands it.
    var content: [CEWorkspaceFile] {
        guard let folderURL = workspace?.workspaceFileManager?.folderUrl else { return [] }
        guard let root = workspace?.workspaceFileManager?.getFile(folderURL.path) else { return [] }
        return [root]
    }

    weak var workspace: WorkspaceDocument?

    var iconColor: SettingsData.FileIconStyle = .color {
        willSet {
            if newValue != iconColor {
                outlineView.reloadData()
            }
        }
    }

    var fileExtensionsVisibility: SettingsData.FileExtensionsVisibility = .showAll
    var shownFileExtensions: SettingsData.FileExtensions = .default
    var hiddenFileExtensions: SettingsData.FileExtensions = .default

    var rowHeight: Double = 22 {
        willSet {
            if newValue != rowHeight {
                outlineView.rowHeight = newValue
                outlineView.reloadData()
            }
        }
    }

    /// This helps determine whether or not to send an `openTab` when the selection changes.
    /// Used b/c the state may update when the selection changes, but we don't necessarily want
    /// to open the file a second time.
    var shouldSendSelectionUpdate: Bool = true

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.scrollView.hasVerticalScroller = true
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = workspace?.workspaceFileManager?.folderUrl.path ?? ""
        self.outlineView.headerView = nil
        self.outlineView.menu = ProjectNavigatorMenu(sender: self.outlineView)
        self.outlineView.menu?.delegate = self
        self.outlineView.doubleAction = #selector(onItemDoubleClicked)

        self.outlineView.setAccessibilityIdentifier("ProjectNavigator")
        self.outlineView.setAccessibilityLabel("Project Navigator")

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        outlineView.setDraggingSourceOperationMask(.move, forLocal: false)
        outlineView.registerForDraggedTypes([.fileURL])

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        outlineView.expandItem(outlineView.item(atRow: 0))
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        outlineView?.removeFromSuperview()
        scrollView?.removeFromSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Forces to reveal the selected file through the command regardless of the auto reveal setting
    @objc
    func revealFile(_ sender: Any) {
        updateSelection(itemID: workspace?.editorManager?.activeEditor.selectedTab?.file.id, forcesReveal: true)
    }

    /// Updates the selection of the ``outlineView`` whenever it changes.
    ///
    /// Most importantly when the `id` changes from an external view.
    /// - Parameter itemID: The id of the file or folder.
    /// - Parameter forcesReveal: The boolean to indicates whether or not it should force to reveal the selected file.
    func updateSelection(itemID: String?, forcesReveal: Bool = false) {
        guard let itemID else {
            outlineView.deselectRow(outlineView.selectedRow)
            return
        }
        self.select(by: .codeEditor(itemID), forcesReveal: forcesReveal)
    }

    /// Expand or collapse the folder on double click
    @objc
    private func onItemDoubleClicked() {
        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? CEWorkspaceFile else { return }

        if item.isFolder {
            if outlineView.isItemExpanded(item) {
                outlineView.collapseItem(item)
            } else {
                outlineView.expandItem(item)
            }
        } else if Settings[\.navigation].navigationStyle == .openInTabs {
            workspace?.editorManager?.activeEditor.openTab(file: item, asTemporary: false)
        }
    }

    /// Get the appropriate color for the items icon depending on the users preferences.
    /// - Parameter item: The `FileItem` to get the color for
    /// - Returns: A `NSColor` for the given `FileItem`.
    private func color(for item: CEWorkspaceFile) -> NSColor {
        if !item.isFolder && iconColor == .color {
            return NSColor(item.iconColor)
        } else {
            return .secondaryLabelColor
        }
    }

    // TODO: File filtering
}
