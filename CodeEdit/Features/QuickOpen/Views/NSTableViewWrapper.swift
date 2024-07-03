//
//  NSTableViewWrapper.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 18/03/2023.
//

import SwiftUI
import AppKit

struct NSTableViewWrapper<Content: View, Item: Identifiable & Hashable>: NSViewRepresentable {

    var data: [Item]
    var rowHeight: CGFloat = 50

    @Binding var selection: Item?

    var itemView: (Item) -> Content

    class NonRespondingScrollView: NSScrollView {
        override var acceptsFirstResponder: Bool { false }
    }

    class NonRespondingTableView: NSTableView {
        override var acceptsFirstResponder: Bool { false }
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NonRespondingScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.verticalScroller?.controlSize = .mini

        let tableView = NonRespondingTableView()
        tableView.headerView = nil

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("column"))
        column.width = tableView.frame.width

        tableView.addTableColumn(column)
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator

        scrollView.documentView = tableView

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.parent = self

        if let view = nsView.documentView as? NSTableView {
            view.reloadData()
            if let selection, let item = data.firstIndex(of: selection) {
                view.selectRowIndexes([item], byExtendingSelection: false)
                view.scrollRowToVisible(item)
            } else {
                view.selectRowIndexes([], byExtendingSelection: false)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {

        var parent: NSTableViewWrapper

        init(parent: NSTableViewWrapper) {
            self.parent = parent
        }

        func numberOfRows(in tableView: NSTableView) -> Int {
            return parent.data.count
        }

        class AlwaysActiveTableRowView: NSTableRowView {
            override var isEmphasized: Bool {
                get { true }
                set { }
            }
        }

        func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
            AlwaysActiveTableRowView()
        }

        func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
            parent.rowHeight
        }

        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let view = NSHostingView(rootView: parent.itemView(parent.data[row]))
            view.translatesAutoresizingMaskIntoConstraints = false

            let cell = NSTableCellView()
            cell.addSubview(view)

            NSLayoutConstraint.activate([
                .init(
                    item: view,
                    attribute: .centerY,
                    relatedBy: .equal,
                    toItem: cell,
                    attribute: .centerY,
                    multiplier: 1,
                    constant: 0
                ),
                .init(
                    item: view,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: cell,
                    attribute: .left,
                    multiplier: 1,
                    constant: 0
                ),
                .init(
                    item: view,
                    attribute: .right,
                    relatedBy: .equal,
                    toItem: cell,
                    attribute: .right,
                    multiplier: 1,
                    constant: 0
                )
            ])

            return cell
        }

        func tableViewSelectionDidChange(_ notification: Notification) {
            if let view = notification.object as? NSTableView {
                let newSelection = parent.data[safe: view.selectedRow]
                if newSelection != parent.selection {
                    parent.selection = newSelection
                }
            }
        }
    }
}
