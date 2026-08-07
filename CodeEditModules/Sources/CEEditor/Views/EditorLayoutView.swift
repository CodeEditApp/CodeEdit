//
//  EditorLayoutView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI
import CodeEditUI

public struct EditorLayoutView: View {
    public var layout: EditorLayout

    @FocusState.Binding var focus: Editor?

    @Environment(\.window.value)
    private var window

    @Environment(\.isEditorLayoutAtEdge)
    private var isAtEdge

    var toolbarHeight: CGFloat {
        window?.contentView?.safeAreaInsets.top ?? .zero
    }

    public init(layout: EditorLayout, focus: FocusState<Editor?>.Binding) {
        self.layout = layout
        self._focus = focus
    }

    public var body: some View {
        VStack {
            switch layout {
            case .one(let detailEditor):
                EditorAreaView(editor: detailEditor, focus: $focus)
                    .transformEnvironment(\.edgeInsets) { insets in
                        switch isAtEdge {
                        case .all:
                            insets.top += toolbarHeight
                            insets.bottom += LayoutMetrics.statusBarHeight + 5
                        case .top:
                            insets.top += toolbarHeight
                        case .bottom:
                            insets.bottom += LayoutMetrics.statusBarHeight + 5
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
                   .transformEnvironment(\.isEditorLayoutAtEdge) { belowToolbar in
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

public struct BelowToolbarEnvironmentKey: EnvironmentKey {
    nonisolated(unsafe) public static var defaultValue: VerticalEdge.Set = .all
}

public extension EnvironmentValues {
    /// The vertical edges at which this editor layout borders the window, used to adjust chrome near the toolbar.
    var isEditorLayoutAtEdge: BelowToolbarEnvironmentKey.Value {
        get { self[BelowToolbarEnvironmentKey.self] }
        set { self[BelowToolbarEnvironmentKey.self] = newValue }
    }
}
