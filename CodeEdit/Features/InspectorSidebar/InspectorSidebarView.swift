//
//  InspectorSidebarView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarView: View {
    @ObservedObject
    private var workspace: WorkspaceDocument

    @ObservedObject
    private var extensionManager = ExtensionManager.shared

    @EnvironmentObject
    private var tabManager: TabManager

    @AppSettings(\.general.inspectorTabBarPosition)
    var sidebarPosition: SettingsData.SidebarTabBarPosition

    @State
    private var selection: AreaTab?

    var path: String? { tabManager.activeTabGroup.selected?.fileDocument?.fileURL?.path(percentEncoded: false)
    }

    private var items: [AreaTab] {
        [
            .init(id: "file", title: "File Inspector", systemImage: "doc") {
                FileInspectorView(
                    workspaceURL: workspace.fileURL!,
                    fileURL: path ?? ""
                )
            },
            .init(id: "history", title: "History Inspector", systemImage: "clock") {
                HistoryInspectorView(
                    workspaceURL: workspace.fileURL!,
                    fileURL: path ?? ""
                )
            },
            .init(id: "quick.help", title: "Quick Help Inspector", systemImage: "questionmark.circle") {
                QuickHelpInspectorView().padding(5)
            },
        ] + extensionManager.extensions.flatMap { ext in
            ext.availableFeatures.compactMap { feature in
                if case .sidebarItem(let data) = feature, data.kind == .inspector {
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

    func getExtension(_ id: String) -> ExtensionInfo? {
        return extensionManager.extensions.first(
            where: { $0.endpoint.bundleIdentifier == id }
        )
    }

    var body: some View {
        VStack {
            if path != nil && selection != nil {
                selection!.contentView()
            } else {
                NoSelectionInspectorView()
            }
        }
        .clipShape(Rectangle())
        .frame(
            minWidth: CodeEditWindowController.minSidebarWidth,
            idealWidth: 260,
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
        .onAppear {
            selection = items.first!
        }
    }
}
