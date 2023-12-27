//
//  AreaTabBar2.swift
//  CodeEdit
//
//  Created by Wouter on 21/10/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct TabViewTabBar<TabID: Hashable>: View {

    enum ItemRepresentation: Hashable {
        case single(Tab)
        case multi(Int, [Tab])
    }

    @Environment(\.controlActiveState)
    private var activeState

    let items: [Tab]

    @Binding var selection: TabID

    let axis: Axis

    var body: some View {
        let isHorizontal = axis == .horizontal

        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.default, value: items)
        }
        .clipped()
        .frame(
            idealWidth: isHorizontal ? nil : 40,
            maxWidth: isHorizontal ? .infinity : nil,
            idealHeight: isHorizontal ? 27 : nil,
            maxHeight: isHorizontal ? nil : .infinity
        )
        .fixedSize(horizontal: !isHorizontal, vertical: isHorizontal)
    }

    // Loops over all the items inside the view and groups them together.
    // Views defined in a ForEach are grouped together in a multi group.
    // Single views are defined as a single group.
    var draggedItemsSplit: [ItemRepresentation] {
        var items: [ItemRepresentation] = []
        var toAddItem: ItemRepresentation?

        for item in self.items {
            switch (toAddItem, item.dynamicViewID) {
            case let (.single(tab), .some(id)):
                items.append(.single(tab))
                toAddItem = .multi(id, [item])

            case (.single(let tab), .none):
                items.append(.single(tab))
                toAddItem = .single(item)

            case (.multi(let int, var array), .some(let id)) where int == id:
                array.append(item)
                toAddItem = .multi(int, array)

            case let (.multi(int, array), .some(id)):
                items.append(.multi(int, array))
                toAddItem = .multi(id, [item])

            case let (.multi(int, array), .none):
                items.append(.multi(int, array))
                toAddItem = .single(item)

            case (nil, .some(let id)):
                toAddItem = .multi(id, [item])

            case (nil, .none):
                toAddItem = .single(item)
            }
        }

        if let toAddItem {
            items.append(toAddItem)
        }

        return items
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        let layout = axis == .horizontal
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        layout {
            // We need to use offset because we don't have another stable identity for the multi views 
            // (the dynamicViewID will change each time)
            ForEach(Array(draggedItemsSplit.enumerated()), id: \.offset) { _, item in
                switch item {
                case .single(let item):
                    IconView(tab: item, size: size, selection: $selection, isVertical: axis == .vertical)
                case .multi(_, let icons):
                    MultiView(items: icons, size: size, axis: axis, selection: $selection)
                }
            }

            if axis == .vertical {
                Spacer()
            }
        }
    }
}
