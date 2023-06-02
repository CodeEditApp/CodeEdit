//
//  InspectorTab.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 02/06/2023.
//

import SwiftUI
import CodeEditKit
import ExtensionFoundation

enum InspectorTab: TabBar {
    case file(workspaceURL: URL, fileURL: String)
    case gitHistory(workspaceURL: URL, fileURL: String)
    case quickhelp
    case uiExtension(endpoint: AppExtensionIdentity, data: ResolvedSidebar.SidebarStore)

    var systemImage: String {
        switch self {
        case .file:
            return "doc"
        case .gitHistory:
            return "clock"
        case .quickhelp:
            return "questionmark.circle"
        case .uiExtension(_, let data):
            return data.icon ?? "e.square"
        }
    }

    var id: String {
        if case .uiExtension(let endpoint, let data) = self {
            return endpoint.bundleIdentifier + data.sceneID
        }
        return title
    }

    var title: String {
        switch self {
        case .file:
            return "File Inspector"
        case .gitHistory:
            return "History Inspector"
        case .quickhelp:
            return "Quick Help Inspector"
        case .uiExtension(_, let data):
            return data.help ?? data.sceneID
        }
    }

    var body: some View {
        switch self {
        case let .file(workspaceURL, fileURL):
            FileInspectorView(workspaceURL: workspaceURL, fileURL: fileURL)
        case let .gitHistory(workspaceURL, fileURL):
            HistoryInspectorView(workspaceURL: workspaceURL, fileURL: fileURL)
        case .quickhelp:
            QuickHelpInspectorView().padding(5)
        case let .uiExtension(endpoint, data):
            ExtensionSceneView(with: endpoint, sceneID: data.sceneID)
        }
    }
}
