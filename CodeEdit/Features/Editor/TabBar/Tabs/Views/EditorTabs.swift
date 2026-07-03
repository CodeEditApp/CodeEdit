//
//  EditorTabs.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/7/23.
//

import SwiftUI

// - TODO: EditorTabView drop-outside event handler.

struct EditorTabs: View {
    typealias TabID = CEWorkspaceFile.ID

    @Environment(\.colorScheme)
    private var colorScheme

    @EnvironmentObject var editor: Editor

    /// The tab id of current dragging tab.
    ///
    /// It will be `nil` when there is no tab dragged currently.
    @State var draggingTabId: TabID?

    @State private var onDragTabId: TabID?

    /// The start location of dragging.
    ///
    /// When there is no tab being dragged, it will be `nil`.
    /// - TODO: Check if I can use `value.startLocation` trustfully.
    @State var draggingStartLocation: CGFloat?

    /// The last location of dragging.
    ///
    /// This is used to determine the dragging direction.
    /// - TODO: Check if I can use `value.translation` instead.
    @State var draggingLastLocation: CGFloat?

    /// Current opened tabs.
    ///
    /// This is a copy of `editor.tabs`.
    /// I am making a copy of it because using state will hugely improve the dragging performance.
    /// Updating ObservedObject too often will generate lags.
    @State var openedTabs: [TabID] = []

    /// A map of tab width.
    ///
    /// All width are measured dynamically (so it can also fit the Xcode tab bar style).
    /// This is used to be added on the offset of current dragging tab in order to make a smooth
    /// dragging experience.
    @State var tabWidth: [TabID: CGFloat] = [:]

    /// A map of tab location (CGRect).
    ///
    /// All locations are measured dynamically.
    /// This is used to compute when we should swap two tabs based on current cursor location.
    @State var tabLocations: [TabID: CGRect] = [:]

    /// A map of tab offsets.
    ///
    /// This is used to determine the tab offset of every tab (by their tab id) while dragging.
    @State var tabOffsets: [TabID: CGFloat] = [:]

    /// This state is used to detect if the mouse is hovering over tabs.
    /// If it is true, then we do not update the expected tab width immediately.
    @State private var isHoveringOverTabs: Bool = false

    /// This state is used to detect if the dragging type should be changed from DragGesture to OnDrag.
    /// It is basically switched when vertical displacement is exceeding the threshold.
    @State var shouldOnDrag: Bool = false

    /// Is current `onDrag` over tabs?
    ///
    /// When it is true, then the `onDrag` is over the tabs, then we leave the space for dragged tab.
    /// When it is false, then the dragging cursor is outside the tab bar, then we should shrink the space.
    ///
    /// - TODO: The change of this state is overall incorrect. Should move it into workspace state.
    @State private var isOnDragOverTabs: Bool = false

    /// The last location of `onDrag`.
    ///
    /// It can be used on reordering algorithm of `onDrag` (detecting when should we switch two tabs).
    @State private var onDragLastLocation: CGPoint?

    @State var closeButtonGestureActive: Bool = false

    @State private var scrollOffset: CGFloat = 0

    @State private var scrollTrailingOffset: CGFloat? = 0

    private func makeTabItemGeometryReader(id: TabID) -> some View {
        GeometryReader { tabItemGeoReader in
            Rectangle()
                .foregroundColor(.clear)
                .onAppear {
                    tabWidth[id] = tabItemGeoReader.size.width
                    tabLocations[id] = tabItemGeoReader
                        .frame(in: .global)
                }
                .onChange(
                    of: tabItemGeoReader.frame(in: .global)
                ) { _, tabCGRect in
                    tabLocations[id] = tabCGRect
                }
                .onChange(
                    of: tabItemGeoReader.size.width
                ) { _, newWidth in
                    tabWidth[id] = newWidth
                }
        }
    }

    /// Called when the tab count changes or the temporary tab changes.
    /// - Parameter geometryProxy: The geometry proxy to calculate the new width using.
    private func updateForTabCountChange(geometryProxy: GeometryProxy) {
        openedTabs = editor.tabs.map(\.file.id)
    }

    var body: some View {
        GeometryReader { geometryProxy in
            TrackableScrollView(
                .horizontal,
                showIndicators: false,
                contentOffset: $scrollOffset,
                contentTrailingOffset: $scrollTrailingOffset
            ) {
                ScrollViewReader { scrollReader in
                    HStack(
                        alignment: .center,
                        spacing: -1 // Negative spacing for overlapping the divider.
                    ) {
                        ForEach(Array(openedTabs.enumerated()), id: \.element) { index, id in
                            if let item = editor.tabs.first(where: { $0.file.id == id }) {
                                if index != 0
                                    && editor.selectedTab?.file.id != id
                                    && editor.selectedTab?.file.id != openedTabs[index - 1] {
                                    EditorTabDivider()
                                }

                                EditorTabView(
                                    file: item.file,
                                    index: index,
                                    draggingTabId: draggingTabId,
                                    onDragTabId: onDragTabId,
                                    closeButtonGestureActive: $closeButtonGestureActive
                                )
                                .transition(
                                    .asymmetric(
                                        insertion: .offset(x: -14).combined(with: .opacity),
                                        removal: .opacity
                                    )
                                )
                                .frame(height: EditorTabBarView.height)
                                .background(makeTabItemGeometryReader(id: id))
                                .offset(x: tabOffsets[id] ?? 0, y: 0)
                                .simultaneousGesture(
                                    makeTabDragGesture(id: id),
                                    including: shouldOnDrag ? .subviews : .all
                                )
                                // TODO: Detect the onDrag outside of tab bar.
                                // Detect the drop action of each tab.
                                .onDrop(
                                    of: [.utf8PlainText], // TODO: Make a unique type for it.
                                    delegate: EditorTabOnDropDelegate(
                                        currentTabId: id,
                                        openedTabs: $openedTabs,
                                        onDragTabId: $onDragTabId,
                                        onDragLastLocation: $onDragLastLocation,
                                        isOnDragOverTabs: $isOnDragOverTabs,
                                        tabWidth: $tabWidth
                                    )
                                )

                                if index < openedTabs.count - 1
                                    && editor.selectedTab?.file.id != id
                                    && editor.selectedTab?.file.id != openedTabs[index + 1] {
                                    EditorTabDivider()
                                }
                            }
                        }
                    }
                    .onAppear {
                        openedTabs = editor.tabs.map(\.file.id)
                        // On first tab appeared, jump to the corresponding position.
                        scrollReader.scrollTo(editor.selectedTab)
                    }
                    .onChange(of: editor.tabs) { tabs, newValue in
                        if tabs.count == newValue.count {
                            updateForTabCountChange(geometryProxy: geometryProxy)
                        } else {
                            withAnimation(
                                .easeOut(duration: 0.20)
                            ) {
                                updateForTabCountChange(geometryProxy: geometryProxy)
                            }
                        }
                        Task {
                            try? await Task.sleep(for: .milliseconds(300))
                            withAnimation {
                                scrollReader.scrollTo(editor.selectedTab?.file.id)
                            }
                        }
                    }
                    // When selected tab is changed, scroll to it if possible.
                    .onChange(of: editor.selectedTab) { _, newValue in
                        withAnimation {
                            scrollReader.scrollTo(newValue?.file.id)
                        }
                    }

                    // When window size changes, re-compute the expected tab width.
                    .onChange(of: geometryProxy.size.width) { _, _ in
                        withAnimation {
                            scrollReader.scrollTo(editor.selectedTab?.file.id)
                        }
                    }
                    // When user is not hovering anymore, re-compute the expected tab width immediately.
                    .onHover { isHovering in
                        isHoveringOverTabs = isHovering
                    }
                    .frame(height: EditorTabBarView.height)
                }

                // To fill up the parent space of tab bar.
                .frame(maxWidth: .infinity)
            }
            .overlay(alignment: .leading) {
                EditorTabsOverflowShadow(
                    width: colorScheme == .dark ? 5 : 7,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(scrollOffset >= 0 ? 0 : 1)
            }
            .overlay(alignment: .trailing) {
                EditorTabsOverflowShadow(
                    width: colorScheme == .dark ? 5 : 7,
                    startPoint: .trailing,
                    endPoint: .leading
                )
                .opacity((scrollTrailingOffset ?? 0) <= 0 ? 0 : 1)
            }
            .if(.tahoe) {
                if #available(macOS 26.0, *) {
                    // Unfortunate triple if here due to needing to compile on
                    // earlier Xcodes.
#if compiler(>=6.2)
                    $0.background(GlassEffectView(tintColor: .tertiarySystemFill))
                        .clipShape(Capsule())
                        .clipped()
#else
                    $0
#endif
                }
            }
        }
    }
}
