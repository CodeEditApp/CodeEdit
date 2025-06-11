//
//  OutlineViewController.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 07.04.22.
//

import AppKit
import SwiftUI
import OSLog

/// A `NSViewController` that handles the **ProjectNavigatorView** in the **NavigatorArea**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the folder structure of the
/// currently open project.
final class ProjectNavigatorViewController: NSViewController {
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "",
        category: "ProjectNavigatorViewController"
    )

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!
    var noResultsLabel: NSTextField!

    /// Gets the folder structure
    ///
    /// Also creates a top level item "root" which represents the projects root directory and automatically expands it.
    var content: [CEWorkspaceFile] {
        guard let folderURL = workspace?.workspaceFileManager?.folderUrl else { return [] }
        guard let root = workspace?.workspaceFileManager?.getFile(folderURL.path) else { return [] }
        return [root]
    }

    var filteredContentChildren: [CEWorkspaceFile: [CEWorkspaceFile]] = [:]
    var expandedItems: Set<CEWorkspaceFile> = []

    weak var workspace: WorkspaceDocument?
    weak var editor: Editor?

    var iconColor: SettingsData.FileIconStyle = .color {
        willSet {
            if newValue != iconColor {
                outlineView?.reloadData()
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

    var filterIsEmpty: Bool {
        workspace?.navigatorFilter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true
    }

    /// Setup the ``scrollView`` and ``outlineView``
    override func loadView() {
        self.scrollView = NSScrollView()
        self.scrollView.hasVerticalScroller = true
        self.view = scrollView

        self.outlineView = ProjectNavigatorNSOutlineView()
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
        self.outlineView.autosaveExpandedItems = true
        self.outlineView.autosaveName = workspace?.workspaceFileManager?.folderUrl.path ?? ""
        self.outlineView.headerView = nil
        self.outlineView.menu = ProjectNavigatorMenu(self)
        self.outlineView.menu?.delegate = self
        self.outlineView.doubleAction = #selector(onItemDoubleClicked)
        self.outlineView.allowsMultipleSelection = true

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

        /// Get autosave expanded items.
        for row in 0..<outlineView.numberOfRows {
            if let item = outlineView.item(atRow: row) as? CEWorkspaceFile {
                if outlineView.isItemExpanded(item) {
                    expandedItems.insert(item)
                }
            }
        }

        /// "No Filter Results" label.
        noResultsLabel = NSTextField(labelWithString: "No Filter Results")
        noResultsLabel.isHidden = true
        noResultsLabel.font = NSFont.systemFont(ofSize: 16)
        noResultsLabel.textColor = NSColor.secondaryLabelColor
        outlineView.addSubview(noResultsLabel)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultsLabel.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor)
        ])
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        outlineView?.removeFromSuperview()
        scrollView?.removeFromSuperview()
        noResultsLabel?.removeFromSuperview()
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
        /// If there are multiples items selected, don't do anything, just like in Xcode.
        guard outlineView.selectedRowIndexes.count == 1 else { return }

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

    func handleFilterChange() {
        filteredContentChildren.removeAll()
        outlineView.reloadData()

        guard let workspace else { return }

        /// If the filter is empty, show all items and restore the expanded state.
        if workspace.sourceControlFilter || !filterIsEmpty {
            outlineView.autosaveExpandedItems = false
            /// Expand all items for search.
            outlineView.expandItem(outlineView.item(atRow: 0), expandChildren: true)
        } else {
            restoreExpandedState()
            outlineView.autosaveExpandedItems = true
        }

        if let root = content.first(where: { $0.isRoot }), let children = filteredContentChildren[root] {
            if children.isEmpty {
                noResultsLabel.isHidden = false
                outlineView.hideRows(at: IndexSet(integer: 0))
            } else {
                noResultsLabel.isHidden = true
            }
        }
    }

    /// Checks if the given filter matches the name of the item or any of its children.
    func fileSearchMatches(_ filter: String, for item: CEWorkspaceFile, sourceControlFilter: Bool) -> Bool {
        guard !filterIsEmpty || sourceControlFilter else {
            return true
        }

        if sourceControlFilter {
            if item.gitStatus != nil && item.gitStatus != GitStatus.none &&
                (filterIsEmpty || item.name.localizedCaseInsensitiveContains(filter)) {
                saveAllContentChildren(for: item)
                return true
            }
        } else if item.name.localizedCaseInsensitiveContains(filter) {
            saveAllContentChildren(for: item)
            return true
        }

        if let children = workspace?.workspaceFileManager?.childrenOfFile(item) {
            return children.contains { fileSearchMatches(filter, for: $0, sourceControlFilter: sourceControlFilter) }
        }

        return false
    }

    /// Saves all children of a given folder item to the filtered content cache.
    /// This is specially useful when the name of a folder matches the search.
    /// Just like in Xcode, this shows all the content of the folder.
    private func saveAllContentChildren(for item: CEWorkspaceFile) {
        guard item.isFolder, filteredContentChildren[item] == nil else { return }

        if let children = workspace?.workspaceFileManager?.childrenOfFile(item) {
            filteredContentChildren[item] = children
            for child in children.filter({ $0.isFolder }) {
                saveAllContentChildren(for: child)
            }
        }
    }

    /// Restores the expanded state of items when finish searching.
    private func restoreExpandedState() {
        let copy = expandedItems
        outlineView.collapseItem(outlineView.item(atRow: 0), collapseChildren: true)

        for item in copy {
            expandParentsRecursively(of: item)
            outlineView.expandItem(item)
        }

        expandedItems = copy
    }

    /// Recursively expands all parent items of a given item in the outline view.
    /// The order of the items may get lost in the `expandedItems` set.
    /// This means that a children item might be expanded before its parent, causing it not to really expand.
    private func expandParentsRecursively(of item: CEWorkspaceFile) {
        if let parent = item.parent {
            expandParentsRecursively(of: parent)
            outlineView.expandItem(parent)
        }
    }
}
