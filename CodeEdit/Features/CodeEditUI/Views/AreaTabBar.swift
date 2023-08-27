//
//  AreaTabBar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

protocol AreaTab: View, Identifiable, Hashable {
    var title: String { get }
    var systemImage: String { get }
}

struct AreaTabBar<Tab: AreaTab>: View {
    @Environment(\.controlActiveState)
    private var activeState

    @State var items: [Tab]

    @Binding var selection: Tab?

    var position: SettingsData.SidebarTabBarPosition

    @State private var tabLocations: [Tab: CGRect] = [:]
    @State private var tabWidth: [Tab: CGFloat] = [:]
    @State private var tabOffsets: [Tab: CGFloat] = [:]

    /// The tab currently being dragged.
    ///
    /// It will be `nil` when there is no tab dragged currently.
    @State private var draggingTab: Tab?

    /// The start location of dragging.
    ///
    /// When there is no tab being dragged, it will be `nil`.
    @State private var draggingStartLocation: CGFloat?

    /// The last location of dragging.
    ///
    /// This is used to determine the dragging direction.
    /// - TODO: Check if I can use `value.translation` instead.
    @State private var draggingLastLocation: CGFloat?

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
        .frame(idealWidth: 40, maxHeight: .infinity)
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        layout {
            ForEach(items) { icon in
                makeIcon(tab: icon, size: size)
                    .offset(
                        x: (position == .top) ? (tabOffsets[icon] ?? 0) : 0,
                        y: (position == .side) ? (tabOffsets[icon] ?? 0) : 0
                    )
                    .background(makeTabItemGeometryReader(tab: icon))
                    .simultaneousGesture(makeAreaTabDragGesture(tab: icon))
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
            selection = tab
        } label: {
            getSafeImage(named: tab.systemImage, accessibilityDescription: tab.title)
                .font(.system(size: 12.5))
                .symbolVariant(tab == selection ? .fill : .none)
                .frame(
                    width: position == .side ? 40 : 24,
                    height: position == .side ? 28 : size.height,
                    alignment: .center
                )
                .help(tab.title)
        }
        .buttonStyle(.icon(isActive: tab == selection, size: nil))
    }

    private func makeAreaTabDragGesture(tab: Tab) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .onChanged({ value in
                if draggingTab != tab {
                    initializeDragGesture(value: value, for: tab)
                }

                // Get the current cursor location
                let currentLocation = (position == .top) ? value.location.x : value.location.y
                guard let startLocation = draggingStartLocation,
                      let currentIndex = items.firstIndex(of: tab),
                      let currentTabWidth = tabWidth[tab],
                      let lastLocation = draggingLastLocation
                else { return }

                let dragDifference = currentLocation - lastLocation
                let previousIndex = currentIndex > 0 ? currentIndex - 1 : nil
                let nextIndex = currentIndex < items.count - 1 ? currentIndex + 1 : nil

                tabOffsets[tab] = currentLocation - startLocation

                swapWithPreviousTab(
                    tab: tab,
                    currentIndex: currentIndex,
                    currentLocation: currentLocation,
                    dragDifference: dragDifference,
                    currentTabWidth: currentTabWidth
                )
                swapWithNextTab(
                    tab: tab,
                    currentIndex: currentIndex,
                    currentLocation: currentLocation,
                    dragDifference: dragDifference,
                    currentTabWidth: currentTabWidth
                )

                // Update the last dragging location if there's enough offset
                let currentLocationOnAxis = ((position == .top) ? value.location.x : value.location.y)
                if draggingLastLocation == nil || abs(currentLocationOnAxis - draggingLastLocation!) >= 10 {
                    draggingLastLocation = (position == .top) ? value.location.x : value.location.y
                }
            })
            .onEnded({ _ in
                draggingStartLocation = nil
                draggingLastLocation = nil
                withAnimation(.easeInOut(duration: 0.25)) {
                    tabOffsets = [:]
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    draggingTab = nil
                }
            })
    }

    private func initializeDragGesture(value: DragGesture.Value, for tab: Tab) {
        draggingTab = tab
        let initialLocation = position == .top ? value.startLocation.x : value.startLocation.y
        draggingStartLocation = initialLocation
        draggingLastLocation = initialLocation
    }

    private func swapWithPreviousTab(
        tab: Tab, currentIndex: Int, currentLocation: CGFloat, dragDifference: CGFloat, currentTabWidth: CGFloat
    ) {
        guard let previousIndex = currentIndex > 0 ? currentIndex - 1 : nil,
              dragDifference < 0 else { return }

        let previousTab = items[previousIndex]
        guard let previousTabLocation = tabLocations[previousTab],
              let previousTabWidth = tabWidth[previousTab]
        else { return }

        var isWithinBounds = false

        if position == .top {
            isWithinBounds = currentLocation < max(
                previousTabLocation.maxX - previousTabWidth * 0.1,
                previousTabLocation.minX + previousTabWidth * 0.9
            )
        } else {
            isWithinBounds = currentLocation < max(
                previousTabLocation.maxY - previousTabWidth * 0.1,
                previousTabLocation.minY + previousTabWidth * 0.9
            )
        }

        if isWithinBounds {
            let changing = previousTabWidth - 1
            draggingStartLocation! -= changing
            withAnimation {
                tabOffsets[tab]! += changing
                items.swapAt(currentIndex, previousIndex)
            }
            return
        }
    }

    private func swapWithNextTab(
        tab: Tab, currentIndex: Int, currentLocation: CGFloat, dragDifference: CGFloat, currentTabWidth: CGFloat
    ) {
        guard let nextIndex = currentIndex < items.count - 1 ? currentIndex + 1 : nil,
              dragDifference > 0 else { return }

        let nextTab = items[nextIndex]
        guard let nextTabLocation = tabLocations[nextTab],
              let nextTabWidth = tabWidth[nextTab]
        else { return }

        var isWithinBounds = false

        if position == .top {
            isWithinBounds = currentLocation > min(
                nextTabLocation.minX + nextTabWidth * 0.1,
                nextTabLocation.maxX - currentTabWidth * 0.9
            )
        } else {
            isWithinBounds = currentLocation > min(
                nextTabLocation.minY + nextTabWidth * 0.1,
                nextTabLocation.maxY - currentTabWidth * 0.9
            )
        }

        if isWithinBounds {
            let changing = nextTabWidth - 1
            draggingStartLocation! += changing
            withAnimation {
                tabOffsets[tab]! -= changing
                items.swapAt(currentIndex, nextIndex)
            }
        }
    }

    private func makeTabItemGeometryReader(tab: Tab) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.clear)
                .onAppear {
                    self.tabWidth[tab] = geometry.size.width
                    self.tabLocations[tab] = geometry.frame(in: .global)
                }
                .onChange(of: geometry.frame(in: .global)) { newFrame in
                    self.tabLocations[tab] = newFrame
                }
                .onChange(of: geometry.size.width) { newWidth in
                    self.tabWidth[tab] = newWidth
                }
        }
    }

    private func getSafeImage(named: String, accessibilityDescription: String?) -> Image {
        // We still use the NSImage init to check if a symbol with the name exists.
        if NSImage(systemSymbolName: named, accessibilityDescription: nil) != nil {
            return Image(systemName: named)
        } else {
            return Image(symbol: named)
        }
    }
}
