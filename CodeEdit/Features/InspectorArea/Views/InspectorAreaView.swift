//
//  InspectorAreaView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorAreaView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var editorManager: EditorManager
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: InspectorAreaViewModel

    @EnvironmentObject private var editorManager: EditorManager

    @AppSettings(\.sourceControl.general.sourceControlIsEnabled)
    private var sourceControlIsEnabled: Bool

    @AppSettings(\.general.inspectorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    init(viewModel: InspectorAreaViewModel) {
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
        .formStyle(.grouped)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("inspector")
        .onChange(of: sourceControlIsEnabled) { _ in
            updateTabItems()
        }
    }

    private func updateTabItems() {
        viewModel.tabItems = [.file] +
            (sourceControlIsEnabled ? [.gitHistory] : []) +
            extensionManager
                .extensions
                .flatMap { ext in
                    ext.availableFeatures.compactMap {
                        if case .sidebarItem(let data) = $0, data.kind == .inspector {
                            return InspectorTab.uiExtension(endpoint: ext.endpoint, data: data)
                        }
                        return nil
                    }
                }
        if let selectedTab = selection,
            !viewModel.tabItems.isEmpty &&
            !viewModel.tabItems.contains(selectedTab) {
            selection = viewModel.tabItems[0]
        }
    }
}
