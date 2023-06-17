//
//  InspectorSidebarView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarView: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @ObservedObject
    private var extensionManager = ExtensionManager.shared

    @EnvironmentObject
    private var tabManager: TabManager

    @AppSettings(\.general.inspectorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @State
    private var selection: InspectorTab? = .quickhelp

    var path: String? {
        tabManager.activeTabGroup.selected?.fileDocument?.fileURL?.path(percentEncoded: false)
    }

    var fileTreeAndGitHistory: [InspectorTab] {
        guard let workspaceURL = workspace.fileURL, let path else {
            return []
        }

        return [
            .file(workspaceURL: workspaceURL, fileURL: path),
            .gitHistory(workspaceURL: workspaceURL, fileURL: path)
        ]
    }

    private var items: [InspectorTab] {
        fileTreeAndGitHistory + [InspectorTab.quickhelp] +
        extensionManager
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

    var body: some View {
        VStack {
            if let selection {
                selection
            } else {
                NoSelectionInspectorView()
            }
        }
        .clipShape(Rectangle())
        .frame(
            minWidth: CodeEditWindowController.minSidebarWidth,
            idealWidth: 300,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .safeAreaInset(edge: .trailing, spacing: 0) {
            if sidebarPosition == .side {
                HStack(spacing: 0) {
                    Divider()
                    AreaTabBar(items: items, selection: $selection, position: sidebarPosition)
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
        .formStyle(.grouped)
    }
}
