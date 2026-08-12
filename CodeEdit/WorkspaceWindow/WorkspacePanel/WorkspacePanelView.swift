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

    init(
        viewModel: ViewModel,
        selectedTabID: Binding<String?>,
        tabItems: Binding<[any WorkspacePanelContribution]>,
        sidebarPosition: GeneralSettings.SidebarTabBarPosition,
        darkDivider: Bool = false
    ) {
        self.viewModel = viewModel
        self._selectedTabID = selectedTabID
        self._tabItems = tabItems
        self.sidebarPosition = sidebarPosition
        self.darkDivider = darkDivider
    }

    private var selectedTab: (any WorkspacePanelContribution)? {
        guard let selectedTabID else { return nil }
        return tabItems.first { $0.id == selectedTabID }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let selection = selectedTab {
                selection.content
            } else {
                CEContentUnavailableView("No Selection")
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side {
                HStack(spacing: 0) {
                    WorkspacePanelTabBar(items: $tabItems, selectionID: $selectedTabID, position: sidebarPosition)
                    Divider()
                        .overlay(Color(nsColor: darkDivider && colorScheme == .dark ? .black : .clear))
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                VStack(spacing: 0) {
                    Divider()
                    WorkspacePanelTabBar(items: $tabItems, selectionID: $selectedTabID, position: sidebarPosition)
                    Divider()
                }
            } else if !darkDivider {
                Divider()
            }
        }
    }
}
