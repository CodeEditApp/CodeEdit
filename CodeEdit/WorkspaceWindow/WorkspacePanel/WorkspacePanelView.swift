//
//  WorkspacePanelView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 1/4/25.
//

import SwiftUI
import CodeEditSettings
import CodeEditUI

struct WorkspacePanelView<ViewModel: ObservableObject>: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var selectedTabID: String?
    @Binding var tabItems: [any WorkspacePanelContribution]

    @Environment(\.colorScheme)
    private var colorScheme

    var sidebarPosition: GeneralSettings.SidebarTabBarPosition
    var darkDivider: Bool
    let padSideItemVertically: Bool
    let sideOnTrailing: Bool
    let sidebarPadding: () -> (Edge.Set, CGFloat)

    init(
        viewModel: ViewModel,
        selectedTabID: Binding<String?>,
        tabItems: Binding<[any WorkspacePanelContribution]>,
        sidebarPosition: GeneralSettings.SidebarTabBarPosition,
        darkDivider: Bool = false,
        padSideItemVertically: Bool = false,
        sideOnTrailing: Bool = false,
        sidebarPadding: @escaping () -> (Edge.Set, CGFloat) = { ([], 0) }
    ) {
        self.viewModel = viewModel
        self._selectedTabID = selectedTabID
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
    }

    private var selectedTab: (any WorkspacePanelContribution)? {
        guard let selectedTabID else { return nil }
        return tabItems.first { $0.id == selectedTabID }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let selection = selectedTab {
                selection.content
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        // Pre-Tahoe the accessory sits inside the tab's own content; from macOS 26 it
                        // spans the panel, below the tab bar. See the matching inset at the bottom.
                        if #unavailable(macOS 26) {
                            selection.bottomView
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

                    WorkspacePanelTabBar(items: $tabItems, selectionID: $selectedTabID, position: sidebarPosition)

                    if #unavailable(macOS 26) {
                        Divider()
                    }
                }
                .padding(sidebarPadding().0, sidebarPadding().1)
            } else if !darkDivider, #unavailable(macOS 26) {
                Divider()
            }
        }
        .if(.tahoe) {
            $0.clipped()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if #available(macOS 26, *), let selection = selectedTab {
                selection.bottomView
            }
        }
    }

    @ViewBuilder private var sideTabBar: some View {
        HStack(spacing: 0) {
            WorkspacePanelTabBar(items: $tabItems, selectionID: $selectedTabID, position: sidebarPosition)
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
