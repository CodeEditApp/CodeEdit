//
//  InspectorAreaView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI
import CodeEditSettings

struct InspectorAreaView: View {
    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: InspectorAreaViewModel

    @AppSettings(\.general.inspectorTabBarPosition)
    var sidebarPosition: GeneralSettings.SidebarTabBarPosition

    @AppSettings(\.developerSettings.showInternalDevelopmentInspector)
    var showInternalDevelopmentInspector

    init(viewModel: InspectorAreaViewModel) {
        self.viewModel = viewModel
    }

    private func updateTabs() {
        var tabs: [InspectorTab] = [.file, .gitHistory]

        if showInternalDevelopmentInspector {
            tabs.append(.internalDevelopment)
        }

        viewModel.tabItems = tabs + extensionManager
            .extensions
            .map { ext in
                ext.availableFeatures.compactMap {
                    if case .sidebarItem(let data) = $0, data.kind == .inspector {
                        return InspectorTab.uiExtension(endpoint: ext.endpoint, data: data)
                    }
                    return nil
                }
            }
            .joined()
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
        // Seeded here, not in `init`: `showInternalDevelopmentInspector` reads the environment,
        // which SwiftUI only populates once the view is in the hierarchy. Called from `init` it
        // silently returned the section default — invisible while settings came from a singleton,
        // and a hard trap now that they come from the environment.
        .onAppear {
            updateTabs()
        }
        .onChange(of: showInternalDevelopmentInspector) { _, _ in
            updateTabs()
        }
    }
}
