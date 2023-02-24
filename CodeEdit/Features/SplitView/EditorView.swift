//
//  EditorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI

struct EditorView: View {
    var tabgroup: TabGroup

    @Environment(\.window) private var window

    @Environment(\.isAtEdge) private var isAtEdge

    var toolbarHeight: CGFloat {
        window.contentView?.safeAreaInsets.top ?? .zero
    }

    var body: some View {
        switch tabgroup {
        case .one(let detailTabGroup):
            WorkspaceTabGroupView(tabgroup: detailTabGroup)
                .transformEnvironment(\.edgeInsets) { insets in
                    switch isAtEdge {
                    case .all:
                        insets.top += toolbarHeight
                        insets.bottom += StatusBarView.height
                    case .top:
                        insets.top += toolbarHeight
                    case .bottom:
                        insets.bottom += StatusBarView.height
                    default:
                        return
                    }
                }
        case .vertical(let data), .horizontal(let data):
            SubEditorView(data: data)
        }
    }

    struct SubEditorView: View {
        @ObservedObject var data: WorkspaceSplitViewData

        var body: some View {
            SplitView(axis: data.axis) {
                splitView
            }
            .edgesIgnoringSafeArea([.top, .bottom])
        }

        var splitView: some View {
            ForEach(Array(data.tabgroups.enumerated()), id: \.offset) { index, item in
                EditorView(tabgroup: item)
                    .transformEnvironment(\.isAtEdge) { belowToolbar in
                        calcIsAtEdge(current: &belowToolbar, index: index)
                    }
                    .environment(\.splitEditor) { edge, newTabGroup in
                        data.split(edge, at: index, new: newTabGroup)
                    }
            }
        }

        func calcIsAtEdge(current: inout VerticalEdge.Set, index: Int) {
            if case .vertical = data.axis {
                guard data.tabgroups.count != 1 else { return }
                if index == data.tabgroups.count - 1 {
                    current.remove(.top)
                } else if index == 0 {
                    current.remove(.bottom)
                } else {
                    current = []
                }
            }
        }
    }
}

private struct BelowToolbarEnvironmentKey: EnvironmentKey {
    static var defaultValue: VerticalEdge.Set = .all
}

extension EnvironmentValues {
    fileprivate var isAtEdge: BelowToolbarEnvironmentKey.Value {
        get { self[BelowToolbarEnvironmentKey.self] }
        set { self[BelowToolbarEnvironmentKey.self] = newValue }
    }
}
