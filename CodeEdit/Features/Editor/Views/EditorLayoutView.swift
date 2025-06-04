//
//  EditorLayoutView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI

struct EditorLayoutView: View {
    var layout: EditorLayout

    @FocusState.Binding var focus: Editor?

    @Environment(\.window.value)
    private var window

    @Environment(\.isAtEdge)
    private var isAtEdge

    var toolbarHeight: CGFloat {
        window?.contentView?.safeAreaInsets.top ?? .zero
    }

    var body: some View {
        VStack {
            switch layout {
            case .one(let detailEditor):
                EditorAreaView(editor: detailEditor, focus: $focus)
                    .transformEnvironment(\.edgeInsets) { insets in
                        switch isAtEdge {
                        case .all:
                            insets.top += toolbarHeight
                            insets.bottom += StatusBarView.height + 5
                        case .top:
                            insets.top += toolbarHeight
                        case .bottom:
                            insets.bottom += StatusBarView.height + 5
                        default:
                            return
                        }
                    }
            case .vertical(let data), .horizontal(let data):
                SubEditorLayoutView(data: data, focus: $focus)
            }
        }
    }

    struct SubEditorLayoutView: View {
        @Environment(\.colorScheme)
        private var colorScheme

        @ObservedObject var data: SplitViewData
        @FocusState.Binding var focus: Editor?

        var body: some View {
            SplitView(axis: data.axis, dividerStyle: .editorDivider) {
                splitView
            }
            .edgesIgnoringSafeArea([.top, .bottom])
        }

        var splitView: some View {
            ForEach(Array(data.editorLayouts.enumerated()), id: \.offset) { index, item in
                EditorLayoutView(layout: item, focus: $focus)
                   .transformEnvironment(\.isAtEdge) { belowToolbar in
                       calcIsAtEdge(current: &belowToolbar, index: index)
                   }
                   .environment(\.splitEditor) { [weak data] edge, newEditor in
                       data?.split(edge, at: index, new: newEditor)
                   }
            }
        }

        func calcIsAtEdge(current: inout VerticalEdge.Set, index: Int) {
            if case .vertical = data.axis {
                guard data.editorLayouts.count != 1 else { return }
                if index == data.editorLayouts.count - 1 {
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
