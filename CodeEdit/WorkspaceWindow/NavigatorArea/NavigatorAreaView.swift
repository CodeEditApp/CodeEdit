//
//  NavigatorAreaView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import CodeEditCore
import CodeEditSettings

struct NavigatorAreaView: View {
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: NavigatorAreaViewModel

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: GeneralSettings.SidebarTabBarPosition

    init(viewModel: NavigatorAreaViewModel, navigator: WorkspaceNavigator) {
        self.viewModel = viewModel

        viewModel.tabItems = navigatorContributions(
            extensionManager: extensionManager,
            navigator: navigator
        )
    }

    var body: some View {
        WorkspacePanelView(
            viewModel: viewModel,
            selectedTabID: $viewModel.selectedTabID,
            tabItems: $viewModel.tabItems,
            sidebarPosition: sidebarPosition
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("navigator")
    }
}
