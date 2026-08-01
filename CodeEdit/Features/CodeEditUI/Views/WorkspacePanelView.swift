//
//  WorkspacePanelView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/4/25.
//

import SwiftUI

struct WorkspacePanelView<Tab: WorkspacePanelTab, ViewModel: ObservableObject>: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var selectedTab: Tab?
    @Binding var tabItems: [Tab]

    @Environment(\.colorScheme)
    private var colorScheme

    var sidebarPosition: SettingsData.SidebarTabBarPosition
    var darkDivider: Bool

    init(
        viewModel: ViewModel,
        selectedTab: Binding<Tab?>,
        tabItems: Binding<[Tab]>,
        sidebarPosition: SettingsData.SidebarTabBarPosition,
        darkDivider: Bool = false
    ) {
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._tabItems = tabItems
        self.sidebarPosition = sidebarPosition
        self.darkDivider = darkDivider
    }

    var body: some View {
        VStack(spacing: 0) {
            // Keep every sidebar panel mounted so expand/scroll state survives tab switches (#711).
            // Hiding with opacity (instead of swapping `if selectedTab`) preserves NSOutlineView state.
            ZStack {
                ForEach(tabItems) { tab in
                    let isSelected = selectedTab == tab
                    tab
                        .opacity(isSelected ? 1 : 0)
                        .allowsHitTesting(isSelected)
                        .accessibilityHidden(!isSelected)
                        .zIndex(isSelected ? 1 : 0)
                }

                if selectedTab == nil {
                    CEContentUnavailableView("No Selection")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side {
                HStack(spacing: 0) {
                    WorkspacePanelTabBar(items: $tabItems, selection: $selectedTab, position: sidebarPosition)
                    Divider()
                        .overlay(Color(nsColor: darkDivider && colorScheme == .dark ? .black : .clear))
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                VStack(spacing: 0) {
                    Divider()
                    WorkspacePanelTabBar(items: $tabItems, selection: $selectedTab, position: sidebarPosition)
                    Divider()
                }
            } else if !darkDivider {
                Divider()
            }
        }
    }
}
