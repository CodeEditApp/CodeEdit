//
//  TableView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 05.04.22.
//

import SwiftUI
import WorkspaceClient
import AppPreferences

class SidebarTableCellView: NSTableCellView {

    var label: NSTextField!
    var icon: NSImageView!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.label = NSTextField(frame: .zero)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.drawsBackground = false
        self.label.isBordered = false
        self.label.isEditable = false

        self.addSubview(label)
        self.textField = label

        self.icon = NSImageView(frame: .init(origin: .zero, size: .zero))
        self.icon.translatesAutoresizingMaskIntoConstraints = false
        self.icon.symbolConfiguration = .init(pointSize: 13, weight: .regular, scale: .medium)
        self.icon.imageScaling = .scaleProportionallyDown

        self.addSubview(icon)
        self.imageView = icon

        self.icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        self.icon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        self.icon.heightAnchor.constraint(equalToConstant: 19).isActive = true

        self.label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5).isActive = true
        self.label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

}

class SidebarOutlineViewController: NSViewController {

    var scrollView: NSScrollView!
    var outlineView: NSOutlineView!

    var content: [WorkspaceClient.FileItem] = []

    var workspace: WorkspaceDocument?

    var iconColor: AppPreferences.FileIconStyle = .color

    override func loadView() {
        self.scrollView = NSScrollView()
        self.view = scrollView

        self.outlineView = NSOutlineView()
        self.outlineView.delegate = self
        self.outlineView.dataSource = self
        self.outlineView.headerView = nil

        let column = NSTableColumn(identifier: .init(rawValue: "Cell"))
        column.title = "Cell"
        outlineView.addTableColumn(column)

        self.scrollView.documentView = outlineView
        reloadContent()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func updateSelection() {
        print("Update")
        guard let itemID = workspace?.selectionState.selectedId,
              let item = try? workspace?.workspaceClient?.getFileItem(itemID) else { return }

        let row = outlineView.row(forItem: item)
        print(item.fileName, row)
        outlineView.selectRowIndexes(.init(integer: row), byExtendingSelection: false)
    }

    func reloadContent() {
        self.content = workspace?.selectionState.fileItems.sortItems(foldersOnTop: true) ?? []
        outlineView.reloadData()
    }
}

extension SidebarOutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? WorkspaceClient.FileItem {
            return item.children?.count ?? 0
        }
        return content.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? WorkspaceClient.FileItem,
           let children = item.children {
            return children[index]
        }
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? WorkspaceClient.FileItem {
            return item.children != nil
        }
        return false
    }
}

extension SidebarOutlineViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowCellExpansionFor tableColumn: NSTableColumn?, item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

        guard let tableColumn = tableColumn else { return nil }

        let frameRect = NSRect(x: 0, y: 0, width: tableColumn.width, height: 20)

        let view = SidebarTableCellView(frame: frameRect)

        if let item = item as? WorkspaceClient.FileItem {
            let image = NSImage(systemSymbolName: item.systemImage, accessibilityDescription: nil)!
            view.icon.image = image
            view.icon.contentTintColor = color(for: item)

            view.label.stringValue = item.fileName
        }

        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }

        let selectedIndex = outlineView.selectedRow

        guard let item = outlineView.item(atRow: selectedIndex) as? WorkspaceClient.FileItem else { return }

        workspace?.openFile(item: item)
    }

    private func color(for item: WorkspaceClient.FileItem) -> NSColor {
        if item.children == nil {
            if iconColor == .color {
                return NSColor(item.iconColor)
            } else {
                return .secondaryLabelColor
            }
        } else {
            return .secondaryLabelColor
        }
    }
}

struct SidebarOutline: NSViewControllerRepresentable {

    @StateObject
    var workspace: WorkspaceDocument

    @StateObject
    var prefs: AppPreferencesModel = .shared

    typealias NSViewControllerType = SidebarOutlineViewController

    func makeNSViewController(context: Context) -> SidebarOutlineViewController {
        let controller = SidebarOutlineViewController()
        controller.workspace = workspace
        controller.iconColor = prefs.preferences.general.fileIconStyle

        return controller
    }

    func updateNSViewController(_ nsViewController: SidebarOutlineViewController, context: Context) {
        nsViewController.iconColor = prefs.preferences.general.fileIconStyle
        nsViewController.updateSelection()
        return
    }

}
