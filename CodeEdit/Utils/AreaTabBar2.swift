//
//  AreaTabBar2.swift
//  CodeEdit
//
//  Created by Wouter on 21/10/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct AreaTabBarAlt<TabID: Hashable>: View {

    struct Tab: Identifiable, Hashable {
        let title: String?
        let image: Image
        let id: AnyHashable
        let tag: TabID?
        let onMove: ((IndexSet, Int) -> Void)?
        let onDelete: ((IndexSet) -> Void)?
        let onInsert: OnInsertConfiguration?
        let dynamicViewID: Int?
        let dynamicViewContentOffset: Int?

        // We only want to compare ID so view updates are correctly animated
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: AreaTabBarAlt<TabID>.Tab, rhs: AreaTabBarAlt<TabID>.Tab) -> Bool {
            lhs.id == rhs.id
        }
    }

    @Environment(\.controlActiveState)
    private var activeState

    var items: [Tab]
    @Binding var selection: TabID

    var position: SettingsData.SidebarTabBarPosition

    var body: some View {
        if position == .top {
            topBody
        } else {
            sideBody
        }
    }

    var topBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.default, value: items)
        }
        .clipped()
        .frame(maxWidth: .infinity, idealHeight: 27)
        .fixedSize(horizontal: false, vertical: true)
    }

    var sideBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.default, value: items)
        }
        .clipped()
        .frame(idealWidth: 40, maxHeight: .infinity)
        .fixedSize(horizontal: true, vertical: false)
    }

    enum ItemRepresentation: Hashable {
        case single(Tab)
        case multi(Int, [Tab])
    }

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
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        layout {
            // We need to use offset because we don't have another stable identity for the multi views (the dynamicViewID will change each time)
            ForEach(Array(draggedItemsSplit.enumerated()), id: \.offset) { index, teee in
                switch teee {
                case .single(let icon):
                    makeIcon(tab: icon, size: size)
                case .multi(_, let icons):
                    MultiView(icons: icons, size: size, position: position, selection: $selection)
                }
            }

            if position == .side {
                Spacer()
            }
        }
    }

    private func makeIcon(
        tab: Tab,
        scale: Image.Scale = .medium,
        size: CGSize
    ) -> some View {
        Button {
            if let tag = tab.tag {
                selection = tag
            }
        } label: {
            tab.image
                .accessibilityLabel(tab.title ?? "")
                .font(.system(size: 12.5))
                .symbolVariant(tab.tag == selection ? .fill : .none)
                .frame(
                    width: position == .side ? 40 : 24,
                    height: position == .side ? 28 : size.height,
                    alignment: .center
                )
                .help(tab.title ?? "")
                .draggable {
                    print("Started dragging")
                    if let offset = tab.dynamicViewContentOffset {
                        withAnimation(.spring) {
                            tab.onDelete?(IndexSet(integer: offset))
                        }
                    }
                    return tab.title ?? ""
                }
        }
        .buttonStyle(.icon(isActive: tab.tag == selection, size: nil))
    }


}

private struct DraggableClosureViewModifier<T: Transferable>: ViewModifier {

    let payload: () -> T

    var helper: T {
        payload()
    }

    func body(content: Content) -> some View {
        content.draggable(helper)
    }
}

extension View {
    func draggable<T: Transferable>(_ payload: @escaping () -> T) -> some View {
        modifier(DraggableClosureViewModifier(payload: payload))
    }
}

extension AreaTabBarAlt {
    struct Delegate: DropDelegate {
        let tabwidths: [CGFloat?]
        let onInsert: OnInsertConfiguration?

        @Binding var tempIndex: Int?

        func dropExited(info: DropInfo) {
            withAnimation(.spring) {
                tempIndex = nil
            }
        }

        func dropUpdated(info: DropInfo) -> DropProposal? {
            var width = info.location.x
            var index = 0
            while index < tabwidths.count && width > (tabwidths[index]!/2) {
                width -= tabwidths[index]!
                index += 1
            }
            withAnimation(.spring) {
                tempIndex = index
            }
            return .some(.init(operation: .copy))
        }

        func performDrop(info: DropInfo) -> Bool {
            var width = info.location.x
            var index = 0
            while index < tabwidths.count && width > (tabwidths[index]!/2) {
                width -= tabwidths[index]!
                index += 1
            }

            if let onInsert {
                onInsert.action(index, info.itemProviders(for: onInsert.supportedContentTypes))
                return true
            }
            return false
        }

        func validateDrop(info: DropInfo) -> Bool {
            guard let onInsert else { return false }
            return info.hasItemsConforming(to: onInsert.supportedContentTypes)
        }
    }
}

extension AreaTabBarAlt {
    struct MultiView: View {
        let icons: [Tab]
        let size: CGSize
        let position: SettingsData.SidebarTabBarPosition

        @Binding var selection: TabID

        @State var tempIndex: Int?

        @State private var tabWidth: [Tab: CGFloat] = [:]

        /// The original index and current destination index of the dragged item.
        @State var itemOffset: (Int, Int)?

        /// The offset of the item that is being dragged.
        @State var draggedItemOffset: (CGFloat, Tab.ID?) = (.zero, nil)

        enum TabOrSpacer: Identifiable, Hashable {
            case tab(Tab)
            case spacer

            var id: AnyHashable {
                switch self {
                case .tab(let tab):
                    tab.id
                case .spacer:
                    UUID()
                }
            }
        }

        var draggedItems: [Tab] {
            guard let itemOffset else { return icons }
            guard itemOffset.1 >= 0 && itemOffset.1 <= icons.count else { return icons }
            var items = self.icons
            let indexSet = IndexSet(integer: itemOffset.0)
            items.move(fromOffsets: indexSet, toOffset: itemOffset.1)
            return items
        }

        var tabs: [TabOrSpacer] {
            guard let tempIndex else { return draggedItems.map { .tab($0) } }
            return draggedItems[..<tempIndex].map { .tab($0) } + [.spacer] + draggedItems[tempIndex...].map { .tab($0) }
        }

        @State var disableGesture: Tab.ID?

        var body: some View {
            let layout = position == .top
                ? AnyLayout(HStackLayout(spacing: 0))
                : AnyLayout(VStackLayout(spacing: 0))

            layout {
                ForEach(Array(tabs.enumerated()), id: \.element) { index, icon in
                    switch icon {
                    case .tab(let icon):
                        makeIcon(tab: icon, size: size)
                            .offset(
                                x: position == .top && draggedItemOffset.1 == icon.id ? draggedItemOffset.0 : 0,
                                y: position == .side && draggedItemOffset.1 == icon.id ? draggedItemOffset.0 : 0
                            )
                            .background(makeTabItemGeometryReader(tab: icon))
                            .highPriorityGesture(icon.onMove == nil || disableGesture == icon.id ? nil : makeAreaTabDragGesture(index: index, tab: icon))
                    case .spacer:
                        Rectangle()
                            .frame(width: 20)
                            .hidden()
                    }
                }
            }
            .coordinateSpace(name: "TabBarItems")
            .animation(.easeInOut, value: draggedItems)
            .onDrop(
                of: icons[0].onInsert?.supportedContentTypes ?? [],
                delegate: Delegate(tabwidths: icons.map { tabWidth[$0] }, onInsert: icons[0].onInsert, tempIndex: $tempIndex)
            )
        }

        func dynamicViewCount(with id: Int) -> Int {
            icons.filter { $0.dynamicViewID == id }.count
        }

        private func makeAreaTabDragGesture(index: Int, tab: Tab) -> some Gesture {
            return DragGesture(minimumDistance: 2, coordinateSpace: .named("TabBarItems"))
                .onChanged({ value in
                    let signedTranslation = position == .top ? value.translation.width : value.translation.height
                    var translation = abs(signedTranslation)
                    let originalIndex = itemOffset?.0 ?? index
                    var endIndex = originalIndex
                    let isPositive = signedTranslation > 0
                    let tresholdWidth = -tabWidth[draggedItems[originalIndex]]!/2

                    while translation > tresholdWidth && endIndex >= 0 && endIndex < draggedItems.count {
                        let width = tabWidth[draggedItems[endIndex]]!
                        translation -= width
                        endIndex += isPositive ? 1 : -1
                    }

                    itemOffset = (originalIndex, isPositive ? endIndex : endIndex + 1)

                    if originalIndex + 1 != endIndex {
                        if isPositive {
                            let off = draggedItems[originalIndex+1..<endIndex].map { tabWidth[$0]! }.reduce(0, +)
                            draggedItemOffset = (signedTranslation - off, tab.id)
                        } else {
                            let off = draggedItems[endIndex+1..<originalIndex].map { tabWidth[$0]! }.reduce(0, +)
                            draggedItemOffset = (signedTranslation + off, tab.id)
                        }
                    } else {
                        draggedItemOffset = (signedTranslation, tab.id)
                    }

                    if abs(value.translation.height) > 50 {
                        disableGesture = tab.id

                        self.itemOffset = nil
                        withAnimation(.spring) {
                            draggedItemOffset = (.zero, nil)
                        }
                    }
                })
                .onEnded({ _ in
                    if let itemOffset, let dynamicViewID = tab.dynamicViewID {
                        let firstindex = icons.firstIndex { $0.dynamicViewID == tab.dynamicViewID } ?? 0
                        var toIndex = itemOffset.1 - firstindex
                        toIndex = max(0, min(toIndex, dynamicViewCount(with: dynamicViewID)))
                        tab.onMove?(IndexSet(integer: itemOffset.0 - firstindex), toIndex)
                    }
                    self.itemOffset = nil
                    withAnimation(.spring) {
                        draggedItemOffset = (.zero, nil)
                    }
                })
        }

        private func makeIcon(
            tab: Tab,
            scale: Image.Scale = .medium,
            size: CGSize
        ) -> some View {
            Button {
                if let tag = tab.tag {
                    selection = tag
                }
            } label: {
                tab.image
                    .accessibilityLabel(tab.title ?? "")
                    .font(.system(size: 12.5))
                    .symbolVariant(tab.tag == selection ? .fill : .none)
                    .frame(
                        width: position == .side ? 40 : 24,
                        height: position == .side ? 28 : size.height,
                        alignment: .center
                    )
                    .help(tab.title ?? "")
                    .draggable {
                        print("Started dragging")
                        if let offset = tab.dynamicViewContentOffset {
                            withAnimation(.spring) {
                                tab.onDelete?(IndexSet(integer: offset))
                            }
                        }
                        return tab.title ?? ""
                    }
            }
            .buttonStyle(.icon(isActive: tab.tag == selection, size: nil))
        }

        private func makeTabItemGeometryReader(tab: Tab) -> some View {
            GeometryReader { geometry in
                let width: CGFloat = position == .top ? geometry.size.width : geometry.size.height

                Rectangle()
                    .hidden()
                    .onAppear {
                        tabWidth[tab] = width
                    }
                    .onChange(of: width) {
                        tabWidth[tab] = $0
                    }
            }
        }
    }
}
