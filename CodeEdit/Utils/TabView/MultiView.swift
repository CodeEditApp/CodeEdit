//
//  MultiView.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

extension TabViewTabBar {
    struct MultiView: View {
        let items: [Tab]
        let size: CGSize
        let position: SettingsData.SidebarTabBarPosition

        @Binding var selection: TabID

        /// Indicates the index for the new drop target.
        /// The index is calculated based on where the item would be dropped in the view.
        @State var dropTargetIndex: Int?

        /// Widths of all tabs
        @State private var tabWidth: [Tab: CGFloat] = [:]

        /// The original index and current destination index of the dragged item.
        @State var itemOffset: (Int, Int)?

        /// The offset of the item that is being dragged.
        @State var draggedItemOffset: (CGFloat, Tab.ID?) = (.zero, nil)
        
        /// The tab for which the local drag gesture is disabled.
        /// This is used so that the system drag gesture can be enabled.
        @State var disableLocalDragGestureForTab: Tab.ID?

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

        /// If an icon is currently being dragged, this will return the items rearranged accordingly.
        /// If no drag occurs, this just returns the items.
        var draggedItems: [Tab] {
            guard let itemOffset else { return items }
            guard itemOffset.1 >= 0 && itemOffset.1 <= items.count else { return items }
            var items = self.items
            let indexSet = IndexSet(integer: itemOffset.0)
            items.move(fromOffsets: indexSet, toOffset: itemOffset.1)
            return items
        }

        /// All tabs plus an inserted spacer, which is used when a new drop target enters the view.
        var tabs: [TabOrSpacer] {
            var mapped: [TabOrSpacer] = draggedItems.map { .tab($0) }
            if let dropTargetIndex {
                mapped.insert(.spacer, at: dropTargetIndex)
            }
            return mapped
        }


        var body: some View {
            let layout = position == .top
                ? AnyLayout(HStackLayout(spacing: 0))
                : AnyLayout(VStackLayout(spacing: 0))

            layout {
                ForEach(Array(tabs.enumerated()), id: \.element) { index, icon in
                    switch icon {
                    case .tab(let icon):
                        IconView(tab: icon, size: size, selection: $selection, isVertical: position == .side)
                            .offset(
                                x: position == .top && draggedItemOffset.1 == icon.id ? draggedItemOffset.0 : 0,
                                y: position == .side && draggedItemOffset.1 == icon.id ? draggedItemOffset.0 : 0
                            )
                            .background(makeTabItemGeometryReader(tab: icon))
                            .highPriorityGesture(
                                icon.onMove == nil || disableLocalDragGestureForTab == icon.id ? nil : tabDragGesture(
                                    index: index,
                                    tab: icon
                                )
                            )
                    case .spacer:
                        Rectangle()
                            .frame(width: 20, height: 20)
                            .hidden()
                    }
                }
            }
            .coordinateSpace(name: "TabBarItems")
            .animation(.easeInOut, value: draggedItems)
            .onDrop(
                of: items[0].onInsert?.supportedContentTypes ?? [],
                delegate: Delegate(
                    tabwidths: items.map { tabWidth[$0] },
                    onInsert: items[0].onInsert,
                    tempIndex: $dropTargetIndex
                )
            )
        }

        func dynamicViewCount(with id: Int) -> Int {
            items.filter { $0.dynamicViewID == id }.count
        }

        private func tabDragGesture(index: Int, tab: Tab) -> some Gesture {
            DragGesture(minimumDistance: 2, coordinateSpace: .named("TabBarItems"))
                .onChanged { value in
                    let (signedTranslation, perpendicularSignedTranslation) = position == .top ?
                    (value.translation.width, value.translation.height) :
                    (value.translation.height, value.translation.width)

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

                    if abs(perpendicularSignedTranslation) > 50 {
                        disableLocalDragGestureForTab = tab.id

                        self.itemOffset = nil
                        withAnimation(.spring) {
                            draggedItemOffset = (.zero, nil)
                        }
                    }
                }
                .onEnded { _ in
                    if let itemOffset, let dynamicViewID = tab.dynamicViewID {
                        let firstindex = items.firstIndex { $0.dynamicViewID == tab.dynamicViewID } ?? 0
                        var toIndex = itemOffset.1 - firstindex
                        toIndex = max(0, min(toIndex, dynamicViewCount(with: dynamicViewID)))
                        tab.onMove?(IndexSet(integer: itemOffset.0 - firstindex), toIndex)
                    }
                    self.itemOffset = nil
                    withAnimation(.spring) {
                        draggedItemOffset = (.zero, nil)
                    }
                }
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
