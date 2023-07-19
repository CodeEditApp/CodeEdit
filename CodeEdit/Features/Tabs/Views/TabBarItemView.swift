//
//  TabBarItemView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct TabBarItemView: View {

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.controlActiveState)
    private var activeState

    @Environment(\.isActiveTabGroup)
    private var isActiveTabGroup

    @Environment(\.isFullscreen)
    private var isFullscreen

    @EnvironmentObject private var tabManager: TabManager

    @AppSettings(\.general.tabBarStyle)
    var tabBarStyle

    @AppSettings(\.general.fileIconStyle)
    var fileIconStyle

    /// Is cursor hovering over the entire tab.
    @State private var isHovering: Bool = false

    /// Is cursor hovering over the close button.
    @State private var isHoveringClose: Bool = false

    /// Is entire tab being pressed.
    @State private var isPressing: Bool = false

    /// Is close button being pressed.
    @State private var isPressingClose: Bool = false

    /// A bool state for going-in animation.
    ///
    /// By default, this value is `false`. When the root view is appeared, it turns `true`.
    @State private var isAppeared: Bool = false

    /// The expected tab width in native tab bar style.
    private var expectedWidth: CGFloat

    /// The id associating with the tab that is currently being dragged.
    ///
    /// When `nil`, then there is no tab being dragged.
    private var draggingTabId: CEWorkspaceFile.ID?

    private var onDragTabId: CEWorkspaceFile.ID?

    @Binding private var closeButtonGestureActive: Bool

    @EnvironmentObject private var tabgroup: TabGroupData

    /// The item associated with the current tab.
    ///
    /// You can get tab-related information from here, like `label`, `icon`, etc.
    private var item: CEWorkspaceFile

    var index: Int

    private var isTemporary: Bool {
        tabgroup.temporaryTab == item
    }

    /// Is the current tab the active tab.
    private var isActive: Bool {
        item == tabgroup.selected
    }

    /// Is the current tab being dragged.
    private var isDragging: Bool {
        draggingTabId == item.id
    }

    /// Is the current tab being held (by click and hold, not drag).
    ///
    /// I use the name `inHoldingState` to avoid any confusion with `isPressing` and `isDragging`.
    private var inHoldingState: Bool {
        isPressing || isDragging
    }

    /// Switch the active tab to current tab.
    private func switchAction() {
        // Only set the `selectedId` when they are not equal to avoid performance issue for now.
        tabManager.activeTabGroup = tabgroup
        if tabgroup.selected != item {
            tabgroup.selected = item
            tabgroup.history.removeFirst(tabgroup.historyOffset)
            tabgroup.history.prepend(item)
            tabgroup.historyOffset = 0
        }
    }

    /// Close the current tab.
    func closeAction() {
        isAppeared = false
        tabgroup.closeTab(item: item)
    }

    init(
        expectedWidth: CGFloat,
        item: CEWorkspaceFile,
        index: Int,
        draggingTabId: CEWorkspaceFile.ID?,
        onDragTabId: CEWorkspaceFile.ID?,
        closeButtonGestureActive: Binding<Bool>
    ) {
        self.expectedWidth = expectedWidth
        self.item = item
        self.index = index
        self.draggingTabId = draggingTabId
        self.onDragTabId = onDragTabId
        self._closeButtonGestureActive = closeButtonGestureActive
    }

    @ViewBuilder var content: some View {
        HStack(spacing: 0.0) {
            TabDivider()
                .opacity(
                    (isActive || inHoldingState)
                    && tabBarStyle == .xcode ? 0.0 : 1.0
                )
                .padding(.top, isActive && tabBarStyle == .native ? 1.22 : 0)
            // Tab content (icon and text).
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: item.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(
                        fileIconStyle == .color
                        && activeState != .inactive && isActiveTabGroup
                        ? item.iconColor
                        : .secondary
                    )
                    .frame(width: 12, height: 12)
                Text(item.name)
                    .font(
                        isTemporary
                        ? .system(size: 11.0).italic()
                        : .system(size: 11.0)
                    )
                    .lineLimit(1)
            }
            .frame(
                // To horizontally max-out the given width area ONLY in native tab bar style.
                maxWidth: tabBarStyle == .native ? .infinity : nil,
                // To max-out the parent (tab bar) area.
                maxHeight: .infinity
            )
            .padding(.horizontal, tabBarStyle == .native ? 28 : 23)
            .overlay {
                ZStack {
                    // Switch Tab Shortcut:
                    // Using an invisible button to contain the keyboard shortcut is simply
                    // because the keyboard shortcut has an unexpected bug when working with
                    // custom buttonStyle. This is an workaround and it works as expected.
                    if index < 10 {
                        Button(
                            action: switchAction,
                            label: { EmptyView() }
                        )
                        .frame(width: 0, height: 0)
                        .keyboardShortcut(
                            KeyEquivalent(Character(String(index))),
                            modifiers: [.command]
                        )
                        .hidden()
                    }
                    // Close Button
                    TabBarItemCloseButton(
                        isActive: isActive,
                        isHoveringTab: isHovering,
                        isDragging: draggingTabId != nil || onDragTabId != nil,
                        closeAction: closeAction,
                        closeButtonGestureActive: $closeButtonGestureActive
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .opacity(
                // Inactive states for tab bar item content.
                activeState != .inactive
                ? 1.0
                : (
                    isActive
                    ? (tabBarStyle == .xcode ? 0.6 : 0.35)
                    : (tabBarStyle == .xcode ? 0.4 : 0.55)
                )
            )
            TabDivider()
                .opacity(
                    (isActive || inHoldingState)
                    && tabBarStyle == .xcode ? 0.0 : 1.0
                )
                .padding(.top, isActive && tabBarStyle == .native ? 1.22 : 0)
        }
        .overlay(alignment: .top) {
            // Only show NativeTabShadow when `tabBarStyle` is native and this tab is not active.
            TabBarTopDivider()
                .opacity(tabBarStyle == .native && !isActive ? 1 : 0)
        }
        .foregroundColor(
            isActive && isActiveTabGroup
            ? (
                tabBarStyle == .xcode && colorScheme != .dark
                ? Color(nsColor: .controlAccentColor)
                : .primary
            )
            : (
                tabBarStyle == .xcode
                ? .primary
                : .secondary
            )
        )
        .frame(maxHeight: .infinity) // To vertically max-out the parent (tab bar) area.
        .contentShape(Rectangle()) // Make entire area clickable.
        .onHover { hover in
            isHovering = hover
            DispatchQueue.main.async {
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }

    var body: some View {
        Button(action: switchAction) {
            ZStack {
                content
            }
            .background {
                if tabBarStyle == .xcode {
                    TabBarItemBackground(isActive: isActive, isPressing: isPressing, isDragging: isDragging)
                        .animation(.easeInOut(duration: 0.08), value: isHovering)
                } else {
                    if isFullscreen && isActive {
                        TabBarNativeActiveMaterial()
                    } else {
                        TabBarNativeMaterial()
                    }
                    ZStack {
                        // Native inactive tab background dim.
                        TabBarNativeInactiveBackgroundColor()
                        // Native inactive tab hover state.
                        Color(nsColor: colorScheme == .dark ? .white : .black)
                            .opacity(isHovering ? (colorScheme == .dark ? 0.08 : 0.05) : 0.0)
                            .animation(.easeInOut(duration: 0.10), value: isHovering)
                    }
                    .padding(.horizontal, 1)
                    .opacity(isActive ? 0 : 1)
                }
            }
            // TODO: Enable the following code snippet when dragging-out behavior should be allowed.
            // Since we didn't handle the drop-outside event, dragging-out is disabled for now.
            //            .onDrag({
            //                onDragTabId = item.tabID
            //                return .init(object: NSString(string: "\(item.tabID)"))
            //            })
        }
        .buttonStyle(TabBarItemButtonStyle(isPressing: $isPressing))
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    if isTemporary {
                        tabgroup.temporaryTab = nil
                    }
                }
        )
        .padding(
            // This padding is to avoid background color overlapping with top divider.
            .top, tabBarStyle == .xcode ? 1 : 0
        )
//        .offset(
//            x: isAppeared || tabBarStyle == .native ? 0 : -14,
//            y: 0
//        )
//        .opacity(isAppeared && onDragTabId != item.id ? 1.0 : 0.0)
        .zIndex(
            isActive
            ? (tabBarStyle == .native ? -1 : 2)
            : (isDragging ? 3 : (isPressing ? 1 : 0))
        )
        .frame(
            width: (
                // Constrain the width of tab bar item for native tab style only.
                tabBarStyle == .native
                ? max(expectedWidth.isFinite ? expectedWidth : 0, 0)
                : nil
            )
        )
        .onAppear {
            withAnimation(
                .easeOut(duration: tabBarStyle == .native ? 0.15 : 0.20)
            ) {
//                isAppeared = true
            }
        }
        .id(item.id)
        .tabBarContextMenu(item: item, isTemporary: isTemporary)
    }
}
