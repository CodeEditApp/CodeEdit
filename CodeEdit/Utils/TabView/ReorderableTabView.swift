//
//  BasicTabView.swift
//  CodeEdit
//
//  Created by Wouter on 20/10/23.
//

import SwiftUI
import Engine
import UniformTypeIdentifiers

struct ReorderableTabView<Content: View, Selected: Hashable>: View {
    @Binding var selection: Selected

    var tabPosition: Edge = .top

    @ViewBuilder var content: Content

    var body: some View {
        VariadicViewAdapter {
            content
        } content: { view in
            let children = view.children

            if !children.isEmpty {
                let items: [TabViewTabBar<Selected>.Tab] = children.map {
                    .init(
                        title: $0[TabTitle.self],
                        image: $0[TabIcon.self] ?? Image(systemName: "questionmark.app.fill"),
                        id: $0.id,
                        tag: $0.tag(as: Selected.self),
                        onMove: $0.onMove,
                        onDelete: $0.onDelete,
                        onInsert: $0.onInsert,
                        dynamicViewID: $0.dynamicViewContentID,
                        dynamicViewContentOffset: $0.contentOffset
                    )
                }

                let layout = tabPosition == .bottom || tabPosition == .top ?
                AnyLayout(VStackLayout(spacing: .zero)) :
                AnyLayout(HStackLayout(spacing: .zero))

                // Flip the axis.
                // When the tabbar position is top or bottom, it's axis (orientation) will be horizontal (HStack)
                let tabBarAxis: Axis = tabPosition == .bottom || tabPosition == .top ? .horizontal : .vertical

                layout {
                    if tabPosition == .top || tabPosition == .leading {
                        TabViewTabBar(items: items, selection: $selection, axis: tabBarAxis)
                        Divider()
                    }

                    InternalBasicTabView(children: children, selected: children.firstIndex {
                        $0.tag(as: Selected.self) == self.selection
                    })

                    if tabPosition == .bottom || tabPosition == .trailing {
                        Divider()
                        TabViewTabBar(items: items, selection: $selection, axis: tabBarAxis)
                    }
                }
            }
        }
    }
}
