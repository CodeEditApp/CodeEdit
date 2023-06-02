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

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @State
    private var selection: AreaTab?

    private var items: [AreaTab] {
        [
            .init(id: "project", title: "Project Navigator", systemImage: "folder") {
                ProjectNavigatorView()
            },
            .init(id: "history", title: "Source Control Navigator", systemImage: "vault") {
                SourceControlNavigatorView()
            },
            .init(id: "find", title: "Find Navigator", systemImage: "magnifyingglass") {
                FindNavigatorView()
            },
        ] + extensionManager.extensions.flatMap { ext in
            ext.availableFeatures.compactMap { feature in
                if case .sidebarItem(let data) = feature, data.kind == .navigator {
                    return AreaTab(
                        id: "ext:\(ext.endpoint.bundleIdentifier)(\(data.sceneID))",
                        title: data.help ?? data.sceneID,
                        systemImage: data.icon
                    ) {
                        ExtensionSceneView(with: ext.endpoint, sceneID: data.sceneID)
                    }
                }
                return nil
            }
        }
    }

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            if selection != nil {
                selection!.contentView()
            } else {
                NoSelectionInspectorView()
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            if sidebarPosition == .side {
                HStack(spacing: 0) {
                    AreaTabBar(items: items, selection: $selection, position: sidebarPosition)
                    Divider()
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if sidebarPosition == .top {
                VStack(spacing: 0) {
                    Divider()
                    AreaTabBar(items: items, selection: $selection, position: sidebarPosition)
                    Divider()
                }
            } else {
                Divider()
            }
        }
        .environmentObject(workspace)
        .onAppear {
            selection = items.first!
        }
    }
}
