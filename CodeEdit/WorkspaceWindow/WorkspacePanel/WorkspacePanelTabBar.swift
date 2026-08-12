//
//  WorkspacePanelTabBar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/25/23.
//

import SwiftUI
import CodeEditSettings
import CodeEditUI

struct WorkspacePanelTabBar: View {
    @Binding var items: [any WorkspacePanelContribution]
    @Binding var selectionID: String?

    var position: GeneralSettings.SidebarTabBarPosition

    @State private var tabLocations: [String: CGRect] = [:]
    @State private var tabWidth: [String: CGFloat] = [:]
    @State private var tabOffsets: [String: CGFloat] = [:]

    /// The id of the tab currently being dragged.
    ///
    /// It will be `nil` when there is no tab dragged currently.
    @State private var draggingTabID: String?

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
                .animation(.default, value: items.map(\.id))
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
                .animation(.default, value: items.map(\.id))
        }
        .clipped()
        .frame(idealWidth: 40, maxHeight: .infinity)
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    func iconsView(size: CGSize) -> some View {
        let layout = position == .top
            ? AnyLayout(HStackLayout(spacing: 0))
            : AnyLayout(VStackLayout(spacing: 0))
        layout {
            ForEach(items, id: \.id) { tab in
                makeIcon(tab: tab, size: size)
                    .offset(
                        x: (position == .top) ? (tabOffsets[tab.id] ?? 0) : 0,
                        y: (position == .side) ? (tabOffsets[tab.id] ?? 0) : 0
                    )
                    .background(makeTabItemGeometryReader(tab: tab))
                    .simultaneousGesture(makeAreaTabDragGesture(tab: tab))
            }
            if position == .side {
                Spacer()
            }
        }
    }

    private func makeIcon(
        tab: any WorkspacePanelContribution,
        scale: Image.Scale = .medium,
        size: CGSize
    ) -> some View {
        Button {
            selectionID = tab.id
        } label: {
            getSafeImage(named: tab.systemImage, accessibilityDescription: tab.title)
                .font(.system(size: 12.5))
                .symbolVariant(tab.id == selectionID ? .fill : .none)
                .help(tab.title)
        }
        .buttonStyle(
            .icon(
                isActive: tab.id == selectionID,
                size: CGSize(
                    width: position == .side ? 40 : 24,
                    height: position == .side ? 28 : size.height
                )
            )
        )
        .focusable(false)
        .accessibilityIdentifier("WorkspacePanelTab-\(tab.title)")
        .accessibilityLabel(tab.title)
    }

    private func makeAreaTabDragGesture(tab: any WorkspacePanelContribution) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .onChanged({ value in
                if draggingTabID != tab.id {
                    initializeDragGesture(value: value, for: tab)
                }

                // Get the current cursor location
                let currentLocation = (position == .top) ? value.location.x : value.location.y
                guard let startLocation = draggingStartLocation,
                      let currentIndex = items.firstIndex(where: { $0.id == tab.id }),
                      let currentTabWidth = tabWidth[tab.id],
                      let lastLocation = draggingLastLocation
                else { return }

                let dragDifference = currentLocation - lastLocation
                tabOffsets[tab.id] = currentLocation - startLocation

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
                    draggingTabID = nil
                }
            })
    }

    private func initializeDragGesture(value: DragGesture.Value, for tab: any WorkspacePanelContribution) {
        draggingTabID = tab.id
        let initialLocation = position == .top ? value.startLocation.x : value.startLocation.y
        draggingStartLocation = initialLocation
        draggingLastLocation = initialLocation
    }

    enum SwapDirection {
        case previous
        case next
    }

    // swiftlint:disable:next function_parameter_count
    private func swapTab(
        tab: any WorkspacePanelContribution,
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
        guard let swapTabLocation = tabLocations[swapTab.id],
              let swapTabWidth = tabWidth[swapTab.id]
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
            tabOffsets[tab.id]! += direction == .previous ? changing : -changing
            items.swapAt(currentIndex, swapIndex)
        }
    }

    private func isWithinPrevTopBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat
    ) -> Bool {
        return curLocation < max(
            swapLocation.maxX - swapWidth * 0.1,
            swapLocation.minX + swapWidth * 0.9
        )
    }

    private func isWithinNextTopBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat, _ curWidth: CGFloat
    ) -> Bool {
        return curLocation > min(
            swapLocation.minX + swapWidth * 0.1,
            swapLocation.maxX - curWidth * 0.9
        )
    }

    private func isWithinPrevBottomBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat
    ) -> Bool {
        return curLocation < max(
            swapLocation.maxY - swapWidth * 0.1,
            swapLocation.minY + swapWidth * 0.9
        )
    }

    private func isWithinNextBottomBounds(
        _ curLocation: CGFloat, _ swapLocation: CGRect, _ swapWidth: CGFloat, _ curWidth: CGFloat
    ) -> Bool {
        return curLocation > min(
            swapLocation.minY + swapWidth * 0.1,
            swapLocation.maxY - curWidth * 0.9
        )
    }

    private func makeTabItemGeometryReader(tab: any WorkspacePanelContribution) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .foregroundColor(.clear)
                .onAppear {
                    self.tabWidth[tab.id] = (position == .top) ? geometry.size.width : geometry.size.height
                    self.tabLocations[tab.id] = geometry.frame(in: .global)
                }
                .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                    self.tabLocations[tab.id] = newFrame
                }
                .onChange(of: geometry.size.width) { _, newWidth in
                    self.tabWidth[tab.id] = newWidth
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
