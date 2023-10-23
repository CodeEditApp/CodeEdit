//
//  AreaTabBar2.swift
//  CodeEdit
//
//  Created by Wouter on 21/10/23.
//

import SwiftUI

struct AreaTabBarAlt<TabID: Hashable>: View {

    struct Tab: Identifiable, Hashable {
        let title: String?
        let image: Image
        let id: AnyHashable
        let tag: TabID?
        let onMove: ((IndexSet, Int) -> Void)?
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

    @State private var tabWidth: [Tab: CGFloat] = [:]

    /// The original index and current destination index of the dragged item.
    @State var itemOffset: (Int, Int)?

    /// The offset of the item that is being dragged.
    @State var draggedItemOffset: (CGFloat, Tab.ID?) = (.zero, nil)

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

    var draggedItems: [Tab] {
        guard let itemOffset else { return items }
        guard itemOffset.1 >= 0 && itemOffset.1 <= items.count else { return items }
        var items = self.items
        let indexSet = IndexSet(integer: itemOffset.0)
        items.move(fromOffsets: indexSet, toOffset: itemOffset.1)
        return items
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        layout {
            ForEach(Array(draggedItems.enumerated()), id: \.element) { index, icon in
                makeIcon(tab: icon, size: size)
                    .offset(
                        x: position == .top && draggedItemOffset.1 == icon.id ? draggedItemOffset.0 : 0,
                        y: position == .side && draggedItemOffset.1 == icon.id ? draggedItemOffset.0 : 0
                    )
                    .background(makeTabItemGeometryReader(tab: icon))
                    .simultaneousGesture(icon.onMove == nil ? nil : makeAreaTabDragGesture(index: index, tab: icon))
            }

            if position == .side {
                Spacer()
            }
        }
        .coordinateSpace(name: "TabBarItems")
        .animation(.easeInOut, value: draggedItems)
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
        }
        .buttonStyle(.icon(isActive: tab.tag == selection, size: nil))
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
            })
            .onEnded({ _ in
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
            })
    }

    func dynamicViewCount(with id: Int) -> Int {
        items.filter { $0.dynamicViewID == id }.count
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
