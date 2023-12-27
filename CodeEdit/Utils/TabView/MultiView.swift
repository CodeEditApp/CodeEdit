//
//  MultiView.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

extension TabViewTabBar {
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
            .buttonStyle(.icon(isActive: tab.tag == selection, size: CGFloat?.none))
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
