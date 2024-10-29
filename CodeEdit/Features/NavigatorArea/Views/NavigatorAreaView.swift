//
//  NavigatorAreaView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorAreaView: View {
    @ObservedObject private var workspace: WorkspaceDocument
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: NavigatorSidebarViewModel

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @AppSettings(\.sourceControl.general.enableSourceControl)
    private var enableSourceControl: Bool

    init(workspace: WorkspaceDocument, viewModel: NavigatorSidebarViewModel) {
        self.workspace = workspace
        self.viewModel = viewModel
        updateTabItems()
    }

    var body: some View {
        VStack {
            if let selection = viewModel.selectedTab {
                selection
            } else {
                NoSelectionInspectorView()
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side {
                HStack(spacing: 0) {
                    AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab, position: sidebarPosition)
                    Divider()
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                VStack(spacing: 0) {
                    Divider()
                    AreaTabBar(items: $viewModel.tabItems, selection: $viewModel.selectedTab, position: sidebarPosition)
                    Divider()
                }
            } else {
                Divider()
            }
        }
        .environmentObject(workspace)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("navigator")
        .onChange(of: enableSourceControl) { _ in
            updateTabItems()
        }
    }

    private func updateTabItems() {
        viewModel.tabItems = [.project] +
            (enableSourceControl ? [.sourceControl] : []) +
            [.search] +
            extensionManager
                .extensions
                .flatMap { ext in
                    ext.availableFeatures.compactMap {
                        if case .sidebarItem(let data) = $0, data.kind == .navigator {
                            return NavigatorTab.uiExtension(endpoint: ext.endpoint, data: data)
                        }
                        return nil
                    }
                }
        if let selectedTab = viewModel.selectedTab,
            !viewModel.tabItems.isEmpty &&
            !viewModel.tabItems.contains(selectedTab) {
            viewModel.selectedTab = viewModel.tabItems[0]
        }
    }
}
