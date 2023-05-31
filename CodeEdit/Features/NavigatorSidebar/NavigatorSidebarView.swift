//
//  NavigatorSidebarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import CodeEditKit

struct NavigatorSidebarView: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    @ObservedObject
    private var extensionManager = ExtensionManager.shared

    @State
    private var selection: NavigatorTab.ID = NavigatorTab.fileTree.id

    private var items: [NavigatorTab] {
        [.fileTree, .sourceControl, .search]
        + extensionManager
            .extensions
            .map { ext in
                ext.availableFeatures.compactMap {
                    if case .sidebarItem(let data) = $0, data.kind == .navigator {
                        return NavigatorTab.uiExtension(endpoint: ext.endpoint, data: data)
                    }
                    return nil
                }
            }
            .joined()
    }

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    @AppSettings(\.general.navigatorTabBarPosition) var sidebarPosition: SettingsData.SidebarTabBarPosition

    var body: some View {
        VStack {
            switch items.first(where: { $0.id == selection }) {
            case .fileTree:
                ProjectNavigatorView()
            case .sourceControl:
                SourceControlNavigatorView()
            case .search:
                FindNavigatorView()
            case let .uiExtension(endpoint, data):
                ExtensionSceneView(with: endpoint, sceneID: data.sceneID)
            case .none:
                NoSelectionInspectorView()
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side {
                NavigatorSidebarTabBar(items: items, selection: $selection, position: sidebarPosition)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                NavigatorSidebarTabBar(items: items, selection: $selection, position: sidebarPosition)
            } else {
                Divider()
            }
        }
        .environmentObject(workspace)
    }
}
