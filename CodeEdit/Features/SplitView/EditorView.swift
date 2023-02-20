//
//  EditorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI

struct EditorView: View {
    var tabgroup: TabGroup

    var body: some View {
        switch tabgroup {
        case .one(let detailTabGroup):
            WorkspaceTabGroupView(tabgroup: detailTabGroup)
        case .vertical(let data), .horizontal(let data):
            SubEditorView(data: data)
        }
    }

    struct SubEditorView: View {
        @ObservedObject var data: WorkspaceSplitViewData

        var body: some View {
            switch data.axis {
            case .vertical:
                VSplitView {
                    splitView
                }
            case .horizontal:
                HSplitView {
                    splitView
                }
            }
        }

        var splitView: some View {
            ForEach(Array(data.tabgroups.enumerated()), id: \.offset) { index, item in
                EditorView(tabgroup: item)
                    .environment(\.splitEditor) { edge, newTabGroup in
                        data.split(edge, at: index, new: newTabGroup)
                    }
            }
        }
    }
}
