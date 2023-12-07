//
//  CEOutlineGroup.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/27/23.
//

import SwiftUI

// This view replaces OutlineGroup, which lacks support for controlling the expanded state.

struct CEOutlineGroup<DataElement, ID, Leaf>: View where DataElement: Identifiable, ID: Hashable, Leaf: View {
    let root: DataElement
    var expandedIds: Binding<[ID: Bool]>?
    @State var expanded: Bool = false
    let defaultExpanded: Bool?
    let childrenKeyPath: KeyPath<DataElement, [DataElement]?>
    let idKeyPath: KeyPath<DataElement, ID>
    let content: (DataElement) -> Leaf

    public init(
        _ root: DataElement,
        id: KeyPath<DataElement, ID>,
        defaultExpanded: Bool? = false,
        expandedIds: Binding<[ID: Bool]>? = nil,
        children: KeyPath<DataElement, [DataElement]?>,
        @ViewBuilder content: @escaping (DataElement) -> Leaf
    ) {
        self.root = root
        self.expandedIds = expandedIds
        self.childrenKeyPath = children
        self.idKeyPath = id
        self.defaultExpanded = defaultExpanded
        self.content = content
        let rootId = root[keyPath: id]
        _expanded = State(
            initialValue: expandedIds?.wrappedValue[rootId] ?? defaultExpanded ?? false
        )
    }

    var itemView: some View {
        content(root)
            .id(root[keyPath: idKeyPath])
            .tag(root[keyPath: idKeyPath])
    }

    var body: some View {
        switch root[keyPath: childrenKeyPath] {
        case .none:
            itemView
        case .some(let children):
            DisclosureGroup(isExpanded: Binding(
                get: {
                    self.expanded
                },
                set: { isExpanded in
                    self.expanded = isExpanded
                    let id = root[keyPath: idKeyPath]
                    expandedIds?.wrappedValue[id] = isExpanded
                }
            )) {
                ForEach(children, id: idKeyPath) {
                    CEOutlineGroup(
                        $0,
                        id: idKeyPath,
                        defaultExpanded: defaultExpanded,
                        expandedIds: expandedIds,
                        children: childrenKeyPath,
                        content: content
                    )
                }
            } label: {
                itemView
            }
        }
    }
}
