//
//  WorkspacePanelTabBar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI

protocol WorkspacePanelTab: View, Identifiable, Hashable {
    var title: String { get }
    var systemImage: String { get }
}

struct WorkspacePanelTabBar<Tab: WorkspacePanelTab>: View {
    @Binding var items: [Tab]
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

    @ViewBuilder var topBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.default, value: items)
        }
        .clipped()
        .if(.tahoe) {
            $0.frame(maxWidth: .infinity, idealHeight: 28).padding(.horizontal, 8)
        } else: {
            $0.frame(maxWidth: .infinity, idealHeight: 27)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder var sideBody: some View {
        GeometryReader { proxy in
            iconsView(size: proxy.size)
                .if(!.tahoe) {
                    $0.padding(.vertical, 5).frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .animation(.default, value: items)
        }
        .clipped()
        .if(.tahoe) {
            $0.frame(idealWidth: 26, maxHeight: .infinity)
        } else: {
            $0.frame(idealWidth: 40, maxHeight: .infinity)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))

        layout {
            if #available(macOS 26, *) {
                ForEach(Array(items.enumerated()), id: \.element) { (idx, tab) in
                    tabViewTahoe(tab, next: items[safe: idx + 1], size: size)
                }
            } else {
                ForEach(items) { tab in
                    tabView(tab, size: size)
                }
            }

            if position == .side, #unavailable(macOS 26) {
                Spacer()
            }
        }
        .if(.tahoe) {
            if #available(macOS 14.0, *) {
                $0.background(GlassEffectView(tintColor: .secondarySystemFill)).clipShape(Capsule())
            }
        }
    }

    @ViewBuilder
    private func tabView(_ tab: Tab, size: CGSize) -> some View {
        IconButton(tab: tab, size: size, position: position, selection: $selection)
            .offset(
                x: (position == .top) ? (tabOffsets[tab] ?? 0) : 0,
                y: (position == .side) ? (tabOffsets[tab] ?? 0) : 0
            )
            .background(makeTabItemGeometryReader(tab: tab))
            .simultaneousGesture(makeAreaTabDragGesture(tab: tab))
    }

    @available(macOS 26, *)
    @ViewBuilder
    private func tabViewTahoe(_ tab: Tab, next: Tab?, size: CGSize) -> some View {
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        let paddingDirection: Edge.Set = position == .top
            ? .vertical
            : .horizontal
        let paddingAmount: CGFloat = position == .top
            ? 5
            : 2

        IconButton(tab: tab, size: size, position: position, selection: $selection)
            .offset(
                x: (position == .top) ? (tabOffsets[tab] ?? 0) : 0,
                y: (position == .side) ? (tabOffsets[tab] ?? 0) : 0
            )
            .background(makeTabItemGeometryReader(tab: tab))
            .simultaneousGesture(makeAreaTabDragGesture(tab: tab))
            .overlay { // overlay to avoid layout adjustment when appearing/disappearing
                layout {
                    Spacer()
                    if tab != items.last && selection != tab && next != selection {
                        Divider().padding(paddingDirection, paddingAmount)
                    }
                }
            }
    }
}

// MARK: - Drag Gesture

private extension WorkspacePanelTabBar {
    func makeAreaTabDragGesture(tab: Tab) -> some Gesture {
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
                tabOffsets[tab] = currentLocation - startLocation

                // Check for swaps between adjacent tabs
                // Left tab
                swapTab(
                    tab: tab,
                    currentIndex: currentIndex,
                    currentLocation: currentLocation,
                    dragDifference: dragDifference,
                    currentTabWidth: currentTabWidth,
                    direction: .previous
                )
                // Right tab
                swapTab(
                    tab: tab,
                    currentIndex: currentIndex,
                    currentLocation: currentLocation,
                    dragDifference: dragDifference,
                    currentTabWidth: currentTabWidth,
                    direction: .next
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

    func initializeDragGesture(value: DragGesture.Value, for tab: Tab) {
        draggingTab = tab
        let initialLocation = position == .top ? value.startLocation.x : value.startLocation.y
        draggingStartLocation = initialLocation
        draggingLastLocation = initialLocation
    }

    enum SwapDirection {
        case previous
        case next
    }

    // swiftlint:disable:next function_parameter_count
    func swapTab(
        tab: Tab,
        currentIndex: Int,
        currentLocation: CGFloat,
        dragDifference: CGFloat,
        currentTabWidth: CGFloat,
        direction: SwapDirection
    ) {
        // Determine the index to swap with based on direction
        var swapIndex: Int?
        if direction == .previous {
            if currentIndex > 0 {
                swapIndex = currentIndex - 1
            }
        } else {
            if currentIndex < items.count - 1 {
                swapIndex = currentIndex + 1
            }
        }

        // Validate the drag direction
        let isValidDragDir = (direction == .previous && dragDifference < 0) ||
                             (direction == .next && dragDifference > 0)
        guard let swapIndex = swapIndex, isValidDragDir else { return }

        // Get info about the tab to swap with
        let swapTab = items[swapIndex]
        guard let swapTabLocation = tabLocations[swapTab],
              let swapTabWidth = tabWidth[swapTab]
        else { return }

        let isWithinBounds: Bool
        if position == .top {
            isWithinBounds = direction == .previous ?
                isWithinPrevTopBounds(currentLocation, swapTabLocation, swapTabWidth) :
                isWithinNextTopBounds(currentLocation, swapTabLocation, swapTabWidth, currentTabWidth)
        } else {
            isWithinBounds = direction == .previous ?
                isWithinPrevBottomBounds(currentLocation, swapTabLocation, swapTabWidth) :
                isWithinNextBottomBounds(currentLocation, swapTabLocation, swapTabWidth, currentTabWidth)
        }

        // Swap tab positions
        if isWithinBounds {
            let changing = swapTabWidth - 1
            draggingStartLocation! += direction == .previous ? -changing : changing
            tabOffsets[tab]! += direction == .previous ? changing : -changing
            items.swapAt(currentIndex, swapIndex)
        }
    }

    func isWithinPrevTopBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat
    ) -> Bool {
        return curLocation < max(
            swapLocation.maxX - swapWidth * 0.1,
            swapLocation.minX + swapWidth * 0.9
        )
    }

    func isWithinNextTopBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat, _ curWidth: CGFloat
    ) -> Bool {
        return curLocation > min(
            swapLocation.minX + swapWidth * 0.1,
            swapLocation.maxX - curWidth * 0.9
        )
    }

    func isWithinPrevBottomBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat
    ) -> Bool {
        return curLocation < max(
            swapLocation.maxY - swapWidth * 0.1,
            swapLocation.minY + swapWidth * 0.9
        )
    }

    func isWithinNextBottomBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat, _ curWidth: CGFloat
    ) -> Bool {
        return curLocation > min(
            swapLocation.minY + swapWidth * 0.1,
            swapLocation.maxY - curWidth * 0.9
        )
    }

    func makeTabItemGeometryReader(tab: Tab) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.clear)
                .onAppear {
                    self.tabWidth[tab] = (position == .top) ? geometry.size.width : geometry.size.height
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
}
