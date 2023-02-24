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

    @Environment(\.isBelowToolbar) private var isBelowToolbar

    var toolbarHeight: CGFloat {
        window.contentView?.safeAreaInsets.top ?? .zero
    }

    var body: some View {
        switch tabgroup {
        case .one(let detailTabGroup):
            WorkspaceTabGroupView(tabgroup: detailTabGroup)
                .transformEnvironment(\.edgeInsets) { insets in
                    if isBelowToolbar {
                        insets.top += toolbarHeight
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
            .edgesIgnoringSafeArea(.top)
        }

        var splitView: some View {
            ForEach(Array(data.tabgroups.enumerated()), id: \.offset) { index, item in
                EditorView(tabgroup: item)
                    .transformEnvironment(\.isBelowToolbar, transform: { belowToolbar in
                        belowToolbar = calcIsBelowToolbar(isBelowToolbar: belowToolbar, index: index)
                    })
                    .environment(\.splitEditor) { edge, newTabGroup in
                        data.split(edge, at: index, new: newTabGroup)
                    }
            }
        }

        func calcIsBelowToolbar(isBelowToolbar: Bool, index: Int) -> Bool {
            switch data.axis {
            case .horizontal:
                return isBelowToolbar
            case .vertical:
                return isBelowToolbar && index == .zero
            }
        }
    }
}

private struct BelowToolbarEnvironmentKey: EnvironmentKey {
    static var defaultValue = true
}

extension EnvironmentValues {
    fileprivate var isBelowToolbar: BelowToolbarEnvironmentKey.Value {
        get { self[BelowToolbarEnvironmentKey.self] }
        set { self[BelowToolbarEnvironmentKey.self] = newValue }
    }
}
