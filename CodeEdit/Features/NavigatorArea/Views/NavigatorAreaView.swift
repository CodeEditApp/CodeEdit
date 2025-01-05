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
    @ObservedObject public var viewModel: NavigatorAreaViewModel

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @AppSettings(\.sourceControl.general.sourceControlIsEnabled)
    private var sourceControlIsEnabled: Bool

    init(workspace: WorkspaceDocument, viewModel: NavigatorSidebarViewModel) {
        self.workspace = workspace
        self.viewModel = viewModel
        updateTabItems()
    }

    var body: some View {
        WorkspacePanelView(
            viewModel: viewModel,
            selectedTab: $viewModel.selectedTab,
            tabItems: $viewModel.tabItems,
            sidebarPosition: sidebarPosition
        )
        .environmentObject(workspace)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("navigator")
        .onChange(of: sourceControlIsEnabled) { _ in
            updateTabItems()
        }
    }

    private func updateTabItems() {
        viewModel.tabItems = [.project] +
            (sourceControlIsEnabled ? [.sourceControl] : []) +
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
