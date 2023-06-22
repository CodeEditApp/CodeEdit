//
//  NavigatorSidebarView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct NavigatorSidebarView: View {
    @ObservedObject private var workspace: WorkspaceDocument

    @ObservedObject private var extensionManager = ExtensionManager.shared

    @AppSettings(\.general.navigatorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @State private var selection: NavigatorTab? = .project

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    private var items: [NavigatorTab] {
        [.project, .sourceControl, .search] +
        extensionManager
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

    var body: some View {
        VStack {
            if let selection {
                selection
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
    }
}
