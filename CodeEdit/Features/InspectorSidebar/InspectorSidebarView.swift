//
//  InspectorSidebarView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarView: View {

    @ObservedObject
    private var extensionManager = ExtensionManager.shared

    @ObservedObject
    private var workspace: WorkspaceDocument

    @EnvironmentObject
    private var tabManager: TabManager

    @State
    private var selection: InspectorTab = .file

    private var items: [InspectorTab] {
        [.file, .gitHistory, .quickhelp]
        + extensionManager
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

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            if let path = tabManager.activeTabGroup.selected?.fileDocument?.fileURL?.path(percentEncoded: false) {
                switch selection {
                case .file:
                    FileInspectorView(
                        workspaceURL: workspace.fileURL!,
                        fileURL: path
                    )
                case .gitHistory:
                    HistoryInspectorView(
                        workspaceURL: workspace.fileURL!,
                        fileURL: path
                    )
                case .quickhelp:
                    QuickHelpInspectorView().padding(5)
                case let .uiExtension(endpoint, data):
                    ExtensionSceneView(with: endpoint, sceneID: data.sceneID)
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .frame(
            minWidth: CodeEditWindowController.minSidebarWidth,
            idealWidth: 260,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .safeAreaInset(edge: .top, spacing: 0) {
            InspectorSidebarToolbarTop(items: items, selection: $selection)
                .background(.ultraThinMaterial)
        }
    }
}
