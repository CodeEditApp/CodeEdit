//
//  WorkspacePanelView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/4/25.
//

import SwiftUI

struct WorkspacePanelView<Tab: WorkspacePanelTab, ViewModel: ObservableObject, BottomAccessory: View>: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var selectedTab: Tab?
    @Binding var tabItems: [Tab]

    @Environment(\.colorScheme)
    private var colorScheme

    var sidebarPosition: SettingsData.SidebarTabBarPosition
    var darkDivider: Bool
    let padSideItemVertically: Bool
    let sideOnTrailing: Bool
    let sidebarPadding: () -> (Edge.Set, CGFloat)
    let bottomAccessory: BottomAccessory

    init(
        viewModel: ViewModel,
        selectedTab: Binding<Tab?>,
        tabItems: Binding<[Tab]>,
        sidebarPosition: SettingsData.SidebarTabBarPosition,
        darkDivider: Bool = false,
        padSideItemVertically: Bool = false,
        sideOnTrailing: Bool = false,
        sidebarPadding: @escaping () -> (Edge.Set, CGFloat) = { ([], 0) },
        @ViewBuilder bottomAccessory: () -> BottomAccessory
    ) {
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._tabItems = tabItems
        self.sidebarPosition = sidebarPosition
        self.darkDivider = darkDivider
        self.padSideItemVertically = padSideItemVertically
        if #available(macOS 26, *) {
            self.sideOnTrailing = sideOnTrailing
        } else {
            self.sideOnTrailing = false
        }
        self.sidebarPadding = sidebarPadding
        self.bottomAccessory = bottomAccessory()
    }

    init(
        viewModel: ViewModel,
        selectedTab: Binding<Tab?>,
        tabItems: Binding<[Tab]>,
        sidebarPosition: SettingsData.SidebarTabBarPosition,
        darkDivider: Bool = false,
        padSideItemVertically: Bool = false,
        sidebarPadding: @escaping () -> (Edge.Set, CGFloat) = { ([], 0) },
        sideOnTrailing: Bool = false,
    ) where BottomAccessory == EmptyView {
        self.viewModel = viewModel
        self._selectedTab = selectedTab
        self._tabItems = tabItems
        self.sidebarPosition = sidebarPosition
        self.darkDivider = darkDivider
        self.padSideItemVertically = padSideItemVertically
        if #available(macOS 26, *) {
            self.sideOnTrailing = sideOnTrailing
        } else {
            self.sideOnTrailing = false
        }
        self.sidebarPadding = sidebarPadding
        self.bottomAccessory = EmptyView()
    }

    var body: some View {
        VStack(spacing: 0) {
            if let selection = selectedTab {
                selection
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        if #unavailable(macOS 26) {
                            bottomAccessory
                        }
                    }
            } else {
                CEContentUnavailableView("No Selection")
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side && !sideOnTrailing {
                sideTabBar.padding(sidebarPadding().0, sidebarPadding().1)
            }
        }
        .safeAreaInset(edge: .trailing, spacing: 0) {
            if sidebarPosition == .side && sideOnTrailing {
                sideTabBar.padding(sidebarPadding().0, sidebarPadding().1)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                VStack(spacing: 0) {
                    if #unavailable(macOS 26) {
                        Divider()
                    }

                    WorkspacePanelTabBar(items: $tabItems, selection: $selectedTab, position: sidebarPosition)

                    if #unavailable(macOS 26) {
                        Divider()
                    }
                }
                .padding(sidebarPadding().0, sidebarPadding().1)
            } else if !darkDivider, #unavailable(macOS 26) {
                Divider()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if #available(macOS 26, *) {
                bottomAccessory
            }
        }
    }

    @ViewBuilder private var sideTabBar: some View {
        HStack(spacing: 0) {
            WorkspacePanelTabBar(items: $tabItems, selection: $selectedTab, position: sidebarPosition)
                .if(.tahoe) {
                    $0.padding(.vertical, padSideItemVertically ? 8 : 0)
                        .padding(sideOnTrailing ? .trailing : .leading, 8)
                }
            if #unavailable(macOS 26) {
                Divider()
                    .overlay(Color(nsColor: darkDivider && colorScheme == .dark ? .black : .clear))
            }
        }
    }
}
