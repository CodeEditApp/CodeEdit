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
            if let selection = selectedTab {
                selection
            } else {
                CEContentUnavailableView("No Selection")
            }
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
