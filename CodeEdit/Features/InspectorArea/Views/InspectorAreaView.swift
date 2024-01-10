//
//  InspectorAreaView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorAreaView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    @ObservedObject private var extensionManager = ExtensionManager.shared
    @ObservedObject public var viewModel: InspectorAreaViewModel

    @EnvironmentObject private var editorManager: EditorManager

    @AppSettings(\.general.inspectorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    init(viewModel: InspectorAreaViewModel) {
        self.viewModel = viewModel

        viewModel.tabItems = [.file, .gitHistory]
        viewModel.tabItems += extensionManager
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

    func getExtension(_ id: String) -> ExtensionInfo? {
        return extensionManager.extensions.first(
            where: { $0.endpoint.bundleIdentifier == id }
        )
    }

    var sidebarPositionEdge: Edge {
        switch sidebarPosition {
        case .top:
            return .top
        case .side:
            return .trailing
        }
    }

    var body: some View {
        Group {
            if viewModel.tabItems.isEmpty {
                Text("Tab not found")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: .zero) {
                    Divider()
                    ReorderableTabView(selection: $viewModel.selectedTab, tabPosition: sidebarPositionEdge) {
                        ForEach(viewModel.tabItems) { item in
                            item
                                .tabTitle(item.title)
                                .tabIcon(Image(systemName: item.systemImage))
                                .tag(InspectorTab?.some(item))
                        }
                        .onMove(perform: move)
                    }
                    .formStyle(.grouped)
                }
            }
        }
        .frame(
            minWidth: CodeEditWindowController.minSidebarWidth,
            idealWidth: 300,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
    }

    func move(from indices: IndexSet, to index: Int) {
        viewModel.tabItems.move(fromOffsets: indices, toOffset: index)
    }
}
