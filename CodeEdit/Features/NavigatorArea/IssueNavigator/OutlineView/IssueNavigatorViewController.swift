//
//  IssueNavigatorViewController.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/15/25.
//

import OSLog
import AppKit
import SwiftUI

/// A `NSViewController` that handles the **IssueNavigatorView** in the **NavigatorArea**.
///
/// Adds a ``outlineView`` inside a ``scrollView`` which shows the issues in a project.
final class IssueNavigatorViewController: NSViewController {
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "",
        category: "IssueNavigatorViewController"
    )

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    /// A set of files with their issues expanded
    var expandedItems: Set<FileIssueNode> = []

    weak var workspace: WorkspaceDocument?
    weak var editor: Editor?

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

    /// Key for storing expansion state in UserDefaults
    private var expansionStateKey: String {
        guard let workspaceURL = workspace?.workspaceFileManager?.folderUrl else {
            return "IssueNavigatorExpansionState"
        }
        return "IssueNavigatorExpansionState_\(workspaceURL.path.hashValue)"
    }

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
        self.outlineView.menu = IssueNavigatorMenu(self)
        self.outlineView.menu?.delegate = self
        self.outlineView.doubleAction = #selector(onItemDoubleClicked)
        self.outlineView.allowsMultipleSelection = true

        self.outlineView.setAccessibilityIdentifier("IssueNavigator")
        self.outlineView.setAccessibilityLabel("Issue Navigator")

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        scrollView.documentView = outlineView
        scrollView.contentView.automaticallyAdjustsContentInsets = false
        scrollView.contentView.contentInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.scrollerStyle = .overlay
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        loadExpansionState()

        // Expand the project node by default
        DispatchQueue.main.async { [weak self] in
            if let rootItem = self?.outlineView.item(atRow: 0) {
                self?.outlineView.expandItem(rootItem)
            }
            self?.restoreExpandedState()
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        saveExpansionState()
        outlineView?.removeFromSuperview()
        scrollView?.removeFromSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Saves the current expansion state to UserDefaults
    private func saveExpansionState() {
        guard let viewModel = workspace?.issueNavigatorViewModel else { return }

        let expandedUris = viewModel.getExpandedFileUris()
        let urisArray = Array(expandedUris)

        UserDefaults.standard.set(urisArray, forKey: expansionStateKey)
    }

    /// Loads the expansion state from UserDefaults
    private func loadExpansionState() {
        guard let viewModel = workspace?.issueNavigatorViewModel else { return }

        if let urisArray = UserDefaults.standard.stringArray(forKey: expansionStateKey) {
            let expandedUris = Set(urisArray)
            viewModel.restoreExpandedFileUris(expandedUris)
        }
    }

    /// Restores the expanded state of items based on their model state
    public func restoreExpandedState() {
        // Expand root if it should be expanded
        if let rootItem = outlineView.item(atRow: 0) as? ProjectIssueNode,
           rootItem.isExpanded {
            outlineView.expandItem(rootItem)
        }

        // Expand file nodes based on their expansion state
        for row in 0..<outlineView.numberOfRows {
            if let fileItem = outlineView.item(atRow: row) as? FileIssueNode {
                if fileItem.isExpanded {
                    outlineView.expandItem(fileItem)
                    expandedItems.insert(fileItem)
                }
            }
        }
    }

    /// Expand or collapse the folder on double click
    @objc
    private func onItemDoubleClicked() {
        // If there are multiples items selected, don't do anything, just like in Xcode.
        guard outlineView.selectedRowIndexes.count == 1 else { return }

        guard let item = outlineView.item(atRow: outlineView.clickedRow) as? (any IssueNode) else { return }

        if let projectNode = item as? ProjectIssueNode {
            toggleExpansion(of: projectNode)
        } else if let fileNode = item as? FileIssueNode {
            toggleExpansion(of: fileNode)
            openFileTab(fileUri: fileNode.uri)
        } else if let diagnosticNode = item as? DiagnosticIssueNode {
            openFileTab(
                fileUri: diagnosticNode.fileUri,
                line: diagnosticNode.diagnostic.range.start.line,
                column: diagnosticNode.diagnostic.range.start.character
            )
        }
    }

    /// Toggles the expansion state of an item
    @inline(__always)
    private func toggleExpansion(of item: Any) {
        if outlineView.isItemExpanded(item) {
            outlineView.collapseItem(item)
        } else {
            outlineView.expandItem(item)
        }
    }

    /// Opens a file as a permanent tab, optionally at a specific line and column
    @inline(__always)
    private func openFileTab(fileUri: String, line: Int? = nil, column: Int? = nil) {
        guard let fileURL = URL(string: fileUri),
              let file = workspace?.workspaceFileManager?.getFile(fileURL.path) else {
            return
        }

        workspace?.editorManager?.activeEditor.openTab(file: file, asTemporary: false)
    }

    /// Called when view will disappear - save state
    override func viewWillDisappear() {
        super.viewWillDisappear()
        saveExpansionState()
    }
}
