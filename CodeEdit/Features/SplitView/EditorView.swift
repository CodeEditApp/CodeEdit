//
//  EditorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI

struct EditorView: View {
    var tabgroup: TabGroup

    var isBelowToolbar = false

    var body: some View {
        switch tabgroup {
        case .one(let detailTabGroup):
            WorkspaceTabGroupView(tabgroup: detailTabGroup, isBelowToolbar: isBelowToolbar)
        case .vertical(let data), .horizontal(let data):
            SubEditorView(data: data, isBelowToolbar: isBelowToolbar)
        }
    }

    struct SubEditorView: View {
        @ObservedObject var data: WorkspaceSplitViewData

        var isBelowToolbar = false

        var body: some View {
            SplitView(axis: data.axis) {
                splitView
            }
            .edgesIgnoringSafeArea(.top)
        }

        var splitView: some View {
            ForEach(Array(data.tabgroups.enumerated()), id: \.offset) { index, item in
                EditorView(tabgroup: item, isBelowToolbar: calcIsBelowToolbar(index: index))
                    .environment(\.splitEditor) { edge, newTabGroup in
                        data.split(edge, at: index, new: newTabGroup)
                    }
            }
        }

        func calcIsBelowToolbar(index: Int) -> Bool {
            switch data.axis {
            case .horizontal:
                return isBelowToolbar
            case .vertical:
                return isBelowToolbar && index == .zero
            }
        }
    }
}
